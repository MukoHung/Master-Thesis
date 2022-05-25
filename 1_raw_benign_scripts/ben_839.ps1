 <#
.SYNOPSIS
  Configures a secure WinRM listener over HTTPS to enable
  SSL-based WinRM communications. This script has not been
  tested on Windows Server 2003R2 or earier, and may not
  work on these OSes for a variety of reasons.

  If Windows Remote Management is disabled (e.g. service
  stopped, GPO Policy, etc.), this script will likely fail.
.DESCRIPTION
  This script is designed to be used in two ways:

  1. Fire on 1001 or 1006 event ids in the 
     CertificateServicesClient-Lifecycle-System event log
  2. Use the -FindCert parameter to select the most recent
     valid certificate created from the 'WinRM' certificate template.

  This script is designed to take parameters from the
  CertificateServicesClient-Lifecycle-System event log.
  This can be used gracefuly with Task Scheduler provided
  you add a bit of custom XML code to your event trigger(s).
  The easiest way to generate the proper XML for a task is to:
  
  1. Create the task in the Task Scheduler GUI. Set everything
     else you would otherwise need in the Task.
  2. Export the task to a file. Remove the task you created in
     Step 1.
  3. Add whatever XML you need. Boilerplate XML is outlined below.
  4. Save the modified XML file and mport the task into Task Scheduler.

  Supported Event IDs
  1001 - Replace
  1006 - New/Enroll

  In order to use event properties as variables to the script,
  you must use the add the <ValueQueries> element under
  each <EventTrigger> used to fire off your script like so:

  <Triggers>
    <EventTrigger>
      <ValueQueries>
        <Value name="Template">
          Event/UserData/CertNotificationData/CertificateDetails/Template/@Name
        </Value>
        <Value name="Thumbprint">
          Event/UserData/CertNotificationData/CertificateDetails/@Thumbprint
        </Value>
        <Value name="Context">
          Event/UserData/CertNotificationData/@Context
        </Value>
        <Value name="EventID">
          Event/System/EventID
        </Value>
      </ValueQueries>
    </EventTrigger>
  </Triggers>

  The way this works is that the text of the <Value> element is actually
  XPATH syntax corresponding to an element or attribute value. If you inspect
  the XML tab of an event log entry, you can see how these paths correlate.
  
  Each <Value> element can be referenced by name in the Action arguments.
  For example, in the new action window:

  Program/script: \path\to\Configure-SecureWinRM.ps1
  Add arguments: -Template '$(Template)' -Thumbprint '$(Thumbprint)' -Context '$(Context)' -EventID '$(EventID)'

  Notice how the variable names correspond to the @name
  attribute of <Value>.

  Event triggers will not work prior to OS version 6.2 
  as the certificate lifecycle events were introduced in 
  Win8/WS2012. However, there is a secondary parameter
  which can be used for older servers, which looks for the
  any certificate generated from the WinRM certificate
  template and selects the certificate with the furthest
  expiry date (as long as the Valid From date has already
  passed). However, there should generally only be one
  WinRM certificate generated at a time.
.PARAMETER Template
  The name of the template used to generate the certificate which
  will be used for WinRM. Should come from the following XML path
  in the event log entry:

  Event/UserData/CertNotificationData/CertificateDetails/Template/@Name

  The template must be 'WinRM' or the script will stop executing by design.
.PARAMETER Thumbprint
  The thumbprint of the certificate to be used for WinRM. Should
  come from the following XML path in the event log entry:

  Event/UserData/CertNotificationData/CertificateDetails/@Thumbprint
.PARAMETER Context
  The context into which the certifcate was installed (e.g. User, Machine, etc.)
  If this value is  anything but 'Machine' the script will stop executing by design.
  Should come from the following XPATH of the event log entry:

  Event/UserData/CertNotificationData/@Context
.PARAMETER EventID
  The EventID which triggered the task calling this script. Must be 1001 or 1006
  or the script will stop executing by design. Should come from the following
  XML path of the event log entry:

  Event/System/EventID  
.PARAMETER FindCert
  When this parameter is used, the previous parameters are not required.
  When -FindCert is specified, the script will search the certificate store path
  specified by -CertStoreLocation for any currently valid certificates that were
  generated using the 'WinRM' template. If more than one suitable certificate is
  found, it will select the certificate which has the furthest expiry date. 
.PARAMETER CertStoreLocation
  A string (or array of strings) representing certificate store paths which
  will be searched for suitable certificates. Set to 'Cert:\LocalMachine\My'
  by default.
#>

[CmdletBinding()]
Param(
    [Parameter(ParameterSetName='FromEventLog', Mandatory=$true)]
    [string]$Template,
    [Parameter(ParameterSetName='FromEventLog', Mandatory=$true)]
    [string]$Thumbprint,
    [Parameter(ParameterSetName='FromEventLog', Mandatory=$true)]
    [string]$Context,
    [Parameter(ParameterSetName='FromEventLog', Mandatory=$true)]
    [int]$EventID,
    [Parameter(ParameterSetName='AutoCert')]
    [switch]$FindCert,
    [string[]]$CertStoreLocation = 'Cert:\LocalMachine\My'
)

# Event log IDs
$REPLACE_EVENT = 1001
$ENROLL_EVENT = 1006

## BEGIN FUNCTIONS ##

function checkParams {
    if ( -Not $FindCert ) {
        if ( -Not $Template -And -Not $Thumbprint -And -Not $Context -And -Not $EventID ) {
            throw 'This script cannot be run without arguments'
        }
        if ( $Template.ToLower() -ne 'winrm' ) {
            Write-Verbose 'WARNING: Refusing to act on certificate sourced from non-WinRM certificate template.'
            # Exit cleanly here, as this script could be fired off when other certs are renewed or enrolled
            exit 0
        }
        if ( $Context.ToLower() -ne 'machine' ) {
            Write-Verbose 'WARNING: Refusing to act on non-LocalMachine certificate'
            # Exit cleanly here, as this script could be fired off when other certs are renewed or enrolled
            exit 0
        }
        if ( ( $EventID -ne $REPLACE_EVENT ) -And ( $EventID -ne $ENROLL_EVENT ) ) {
            Write-Verbose ( "WARNING: Refusing to act on any EventID other than {0} or {1}" -f $REPLACE_EVENT, $ENROLL_EVENT )
            # Exit cleanly here, as this script could be fired off when other certs are renewed or enrolled
            exit 0
        }
        if ( $Thumbprint -eq $null ) {
            Write-Error "-Thumbprint cannot be null"
            # If this is null something is wrong, trigger a failure
            exit 1
        }
    }
    
    # Enforce -CertStoreLocation paths being rooted under Cert:\LocalMachine
    if ( ( $CertStoreLocation | Where-Object { $_.ToLower().StartsWith('cert:\localmachine') } ).Count -ne $CertStoreLocation.Count ) {
        Write-Error 'All -CertStoreLocation paths must be rooted under Cert:\LocalMachine'
        exit 2
    }
}

function execute {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Command,
        [switch]$SuppressOutput,
        [switch]$ThrowOnError
    )
    Write-Debug ( "EXECUTE>> {0}" -f $Command )
    if ( $SuppressOutput ) {
        Invoke-Expression $Command -ErrorVariable execute_error | Out-Null
    } else {
        Invoke-Expression $Command -ErrorVariable execute_error | Write-Host
    }

    if ( $ThrowOnError -And $execute_error ) { throw $execute_error }
    # Invoke-Expression always makes $? $true
    ( $result = ( -Not $LASTEXITCODE ) )
    Write-Debug ( "Result of last command: {0}" -f $result )
}

function getFQDN {
    Write-Verbose 'Checking FQDN'
    $shortname = ( Get-WmiObject win32_computersystem ).DNSHostName
    if ( ( Get-WmiObject win32_computersystem ).PartOfDomain ) {
        "{0}.{1}" -f $shortname, ( Get-WmiObject win32_computersystem ).Domain
    } else {
        $shortname
    }
}

function certExists {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Thumbprint,
        [Parameter(Mandatory=$true)]
        [string[]]$CertStoreLocation
    )
    Write-Verbose ( "Checking {1} for certificate with thumbprint {0}" -f $Thumbprint, ( $CertStoreLocation -Join ', ' ) )
    $cert = Get-ChildItem $CertStoreLocation | Where-Object { $_.Thumbprint -eq $Thumbprint }
    [bool]$cert
}

function listenerExists {
    Write-Verbose 'Checking if secure WinRM listener is already configured'
    $command = 'winrm get winrm/config/listener?Address=*+Transport=HTTPS'
    execute -Command $command
}

# Creates secure WinRM listener. Returns $true if success and $false if failed
function createSecureListener {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$CertificateThumbprint,
        [Parameter(Mandatory=$true)]
        [string]$FQDN,
        [int]$Port = 5986
    )
    Write-Host ( "Creating new secure listener for WinRM on port {0}" -f $Port )
    Write-Verbose ( "Setting WinRM Hostname property to {0}" -f $FQDN )
    Write-Verbose ( "Setting WinRM CertificateThumbprint property to {0}" -f $CertificateThumbprint )
    $command = "winrm create winrm/config/listener?Address=*+Transport=HTTPS"
    $configItems = "`"@{ Hostname=```"$FQDN```"; CertificateThumbprint=```"$CertificateThumbprint```"; Port=```"$Port```" }`""
    execute -Command ( "{0} {1}" -f $command, $configItems )
}

# Updates the secure WinRM listener. Returns $true on success and $false on $failure
function updateSecureListener {
    Param(
        [string]$CertificateThumbprint,
        [string]$FQDN,
        [int]$Port
    )
    if ( $CertificateThumbprint -Or $FQDN -Or $Port ) {
        Write-Host 'Updating existing secure listener for WinRM'

        $configItems = New-Object System.Collections.Generic.List[string]
        if ( $CertificateThumbprint ) {
            Write-Verbose ( "Setting WinRM CertificateThumbprint property to {0}" -f $CertificateThumbprint )
            $configItems.Add( "CertificateThumbprint=```"{0}```"" -f $CertificateThumbprint )
        }
        if ( $FQDN ) {
            Write-Verbose ( "Setting WinRM Hostname property to {0}" -f $FQDN )
            $configItems.Add( "Hostname=```"{0}```"" -f $FQDN )
        }
        if ( $Port ) {
            Write-Verbose ( "Setting Winrm Port property to {0}" -f $Port )
            $configItems.Add( "Port=```"{0}```"" -f $Port )
        }
        $command = "winrm set winrm/config/listener?Address=*+Transport=HTTPS `"@{{ {0} }}`"" -f ( $configItems -Join '; ' )
        execute $command
    } else {
        Write-Verbose 'WARNING: No parameters were specified. No configuration was updated.'
        $true
    }
}

# Locates a suitable WinRM certificate based off of the certificate template.
# Used in the event that the certificate exists before the scheduled task was
# created (AKA first time run after the certificate template was already applied).
# If more than one certificate is found, the certificate with the latest expiration
# is used (as long as the current time is between NotBefore and NotAfter).
# Returns a suitable certificate object for use with WinRM.
function findWinRMCert {
    Param(
        [Parameter(Mandatory=$true)]
        [string[]]$CertStoreLocation
    )
    $templateNameField = 'Certificate Template Information'
    # Get certs that have been applied with a certificate template and currently valid (by date)
    Write-Verbose ( "Searching for suitable certificates in {0}" -f ( $CertStoreLocation -Join ', ' ) )
    $now = Get-Date
    $certs = Get-ChildItem $CertStoreLocation | Where-Object {
        $_.Extensions.Oid.FriendlyName -eq $templateNameField `
          -And $now -ge $_.NotBefore -And $now -le $_.NotAfter
    } | Sort-Object -Property NotAfter -Descending

    $winrm_certs = New-Object System.Collections.Generic.List[System.Security.Cryptography.X509Certificates.X509Certificate2]
    # Sorcery to check the template name
    $certs | Foreach-Object {
        $temp = $_.Extensions | Where-Object { $_.Oid.FriendlyName -eq $templateNameField }
        $templateName = ( $temp.Format($true) -Split "`r`n" | Where-Object { $_.StartsWith('Template=') } ) -Replace 'Template=', ''
        if ( $templateName.ToLower().StartsWith('winrm') ) {
            $winrm_certs.Add( $_ )
        }
    }
    if ( $winrm_certs ) {
        $winrm_certs[0]
    } else {
        $null
    }
}

## END FUNCTIONS ##

$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"

try {
    checkParams

    $fqdn = getFQDN
    Write-Verbose ( "Using detected FQDN of {0}" -f $fqdn )
    if ( -Not $FindCert ) {
        if ( -Not ( certExists $Thumbprint ) ) { throw ( "Certificate thumbprint {0} not found" -f $Thumbprint ) }
    } else {
        $foundCert = ( findWinRMCert $CertStoreLocation )
        if ( $foundCert ) {
            $Thumbprint = $foundCert.Thumbprint
        } else {
            $Thumbprint = $null
        }
        if ( -Not $Thumbprint ) { throw 'Could not find a suitable certificate for use with WinRM' }
    }
    
    if ( -Not ( listenerExists ) ) {
        $ret = createSecureListener -CertificateThumbprint $Thumbprint -FQDN $fqdn
        if ( -Not $ret ) { throw "createSecureListener failed" }
    } else {
        $ret = updateSecureListener -CertificateThumbprint $Thumbprint -FQDN $fqdn
        if ( -Not $ret ) { throw "updateSecureListener failed" }
    }
} finally {
    $ErrorActionPreference = $OldErrorActionPreference
}
