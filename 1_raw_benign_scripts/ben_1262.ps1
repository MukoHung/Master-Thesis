

# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned


# See http://www.lewisroberts.com/2016/01/30/powershell-for-ddns-dyndns-org/


# If you want to see what the script is doing, uncomment this.
#$VerbosePreference = "Continue"

# List of Servers to update, all are updated to the detected external IP of the machine running the script.
$Servers = @("example.dtdns.net")

# User Agent string to send to DtDNS.
$UserAgent = "PowerShellDtDnsUpdater"

# Get the credentials for the update.
$Creds = Import-Clixml -Path "$PSScriptRoot\DtDNS-$env:COMPUTERNAME.xml"

# To create your credential file, use the command:
# Get-Credential | Export-Clixml "DtDNS-$env:COMPUTERNAME.xml"

# If you're running this as a scheduled task, you must do it under the context of the same user that creates the credential file.
# "Security options" -> "Run whether user is logged on or not"

# Control Panel -> Administrative Tools -> Task Scheduler

# Program/Script: Powershell.exe
# Arguments: -File "C:\Users\MyUser\dtdns.ps1"

# Run Task at Startup. Repeat task every 5 minutes indefinitely. Initial Delay for 5 minutes.

Function Get-ExternalIP()
{
    Try 
    {
        $ExternalIP = Invoke-RestMethod -Uri "https://api.ipify.org/"
    }
    Catch 
    { 
        Return $false 
    }

    $IPregex='(?<Address>(\b(([01]?\d?\d|2[0-4]\d|25[0-5])\.){3}([01]?\d?\d|2[0-4]\d|25[0-5])\b))'

    If ($ExternalIP -Match $IPregex) 
    {
        Return $Matches.Address
    }
    Else 
    {
        Return $false
    }
}

Function Set-DDNSUpdate 
{
    param([parameter(Mandatory=$true)][string] $HostAddress,
          [parameter(Mandatory=$true)][pscredential] $Credentials,
          [parameter(Mandatory=$true)][ipaddress] $IP
    )

    Try 
    {
        $UserName = $Credentials.UserName
        $Password = $Credentials.GetNetworkCredential().Password

        $Result = Invoke-RestMethod -Uri "https://www.dtdns.com/api/autodns.cfm?id=$HostAddress&pw=$Password&ip=$IP" -UserAgent $UserAgent

        Return $Result
    }
    Catch 
    { 
        Return $false 
    }
}

Function Is-FirstDay
{
    $Today = Get-Date

    If (($Today.Day -eq 1) -and ($Today.Hour -eq 1))
    {
        Write-Verbose "First day of the month. Forcing update."
        Return $true 
    }

    Return $false 
}


# Get the Actual External IP address of this machine.
$ActualIP = Get-ExternalIP

If (!($ActualIP) -or ($ActualIP -eq $null)) 
{
    Write-Verbose "An error occurred getting the current IP. Quitting."
    Break
}
Else
{
    Write-Verbose "Detected $ActualIP"
}

# For each host...
Foreach ($DDNSHost in $Servers) 
{
    Write-Verbose "Processing $DDNSHost"

    # Check for force update
    $ForceUpdate = Is-FirstDay
    
    # Lookup host's current DNS IP address
    Try 
    {
        $DNSIP = [System.Net.Dns]::GetHostAddresses($DDNSHost) | Select-Object -ExpandProperty IPAddressToString

        Write-Verbose "Resolved $DNSIP"
    }
    Catch 
    {
        Write-Verbose "Can't check the current IP so skipping host `"$DDNSHost`"."
        Continue
    }
 
    # If the DNS lookup failed, report and continue to next host.
    If (!$DNSIP) 
    {
        Write-Verbose "DNS lookup for `"$DDNSHost`" returned nothing?"
        Continue
    }
    
    # If the detected IP and current host DNS IP are not equal, an update is required.
    If (($ActualIP -ne $DNSIP) -or ($ForceUpdate)) 
    {
        Write-Verbose "[UPDATE] for $DDNSHost to $ActualIP"
        
        # Perform an update for this host
        $Result = Set-DDNSUpdate -HostAddress $DDNSHost -IP $ActualIP -Credentials $Creds
 
        # If the response is not as expected, output an error (only visible if verbose is on!)
        If (!($Result -match "Host $DDNSHost now points to $ActualIP.")) 
        {
            Write-Verbose "[ERROR] An error occurred updating the IP address. Response from DtDns:"
            Write-Verbose "[ERROR] $Result"
        }
        Else
        {
            Write-Verbose "$Result"
        }
    }
    # If the current external IP and the host DNS IP are the same, just say nothing happened.
    Else 
    {
        Write-Verbose "[INFO] No update required. [ACTUAL] $ActualIP [DNS] $DNSIP"
    }
}
