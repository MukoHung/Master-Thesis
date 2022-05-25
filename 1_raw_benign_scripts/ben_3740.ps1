<#
.SYNOPSIS
    A script to automate Site Discovery.
.DESCRIPTION
    This script automates site discovery on VMware. It prompts the user for
    a vCenter to connect to. The user selects the resource pool they want
    to discover. Next, the script prompts the user to enter Okta credentials
    for parkplaceintl.okta.com. The script then asks the user which credentials
    to use from Thycotic for AD and DMZ server access. The script then copies
    LocalDiscovery.ps1 to all of the powered on Windows servers, and runs the
    local discovery in parallel to speed up data collection. After collecting
    the data, the script outputs the information into the folder the user
    selected.
.NOTES
    File Name  : Site-Discovery.ps1
    Author     : Dan Gill - dgill@gocloudwave.com
    Requires   : LocalDiscovery.ps1, User-Prompts.ps1, and Install-PowerCLI.ps1
                 in the same directory.
.LINK
    https://xkln.net/blog/multithreading-in-powershell--running-a-specific-number-of-threads/
.EXAMPLE
    ./Site-Discovery.ps1
.INPUTS
   None. Site-Discovery.ps1 will prompt the user for all needed informaiton.
.OUTPUTS
   Outputs several files based on local discovery to a folder named after the
   user's selected resource pool under the folder the user selected.
.EXAMPLE
   PS> .\Site-Discovery.ps1
#>

$Settings = Get-Content "$PSScriptRoot\settings.json" -Raw | ConvertFrom-Json
$reNoMatchRPs = '^(?:Infrastructure|Resources)$'
$reVMs = '^.*Windows.*$'
$ADcreds = $null
$DMZcreds = $null
$VMScriptPath = $Settings.RemoteScriptWorkingDir
$vCenters = $Settings.vCenters
# Create synchronized hashtable
$Configuration = [hashtable]::Synchronized(@{})
$Configuration.ScriptResults = @()
$Configuration.ScriptErrors = @()
$Configuration.VIServer = $null
$Configuration.DiscoveryScript = "$PSScriptRoot\LocalDiscovery.ps1"

# Base path to Secret Server
$ssUri = $Settings.ssUri

# Install Thycotic.SecretServer PowerShell module if not installed
if (!(Get-Module -ListAvailable -Name Thycotic.SecretServer)) {
    Install-Module -Name Thycotic.SecretServer -Scope CurrentUser
}

if (!(Get-Module -Name VMware.PowerCLI -ListAvailable)) {
    # Call Install-PowerCLI.ps1
    Invoke-Expression -Command "$PSScriptRoot\Install-PowerCLI.ps1"
}

# Load User-Prompts functions
. "$PSScriptRoot\User-Prompts.ps1"

# Enhanced root level folder searches for Thycotic
Function Search-TssFolders {
    <#
    .SYNOPSIS
    Search secret folders

    .DESCRIPTION
    Search secret folders

    .EXAMPLE
    $session = New-TssSession -SecretServer https://alpha -Credential $ssCred
    Search-TssFolders -TssSession $session -ParentFolderId 54

    Return all child folders found under root folder 54

    .NOTES
    Requires TssSession object returned by New-TssSession
    #>
    [CmdletBinding()]
    [OutputType('Thycotic.PowerShell.Folders.Summary')]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [Thycotic.PowerShell.Authentication.Session]
        $TssSession,

        # Parent Folder Id
        [Alias('FolderId')]
        [int]
        $ParentFolderId,
        
        # Search by text value
        [string]
        $SearchText,
        
        # Filter based on folder permission (Owner, Edit, AddSecret, View). Default: View
        [ValidateSet('Owner', 'Edit', 'AddSecret', 'View')]
        [string[]]
        $PermissionRequired,
        
        # Sort by specific property, default FolderPath
        [string]
        $SortBy = 'Id',

        # Search Root Folders Only, default False
        [bool]
        $TopLevelOnly = $false
    )
    begin {
        $tssParams = $PSBoundParameters
    }
    process {
        #Get-TssInvocation $PSCmdlet.MyInvocation
        if ($tssParams.ContainsKey('TssSession') -and $TssSession.IsValidSession()) {
            #Compare-TssVersion $TssSession '10.9.000000' $PSCmdlet.MyInvocation
            $restResponse = $null

            $uri = $TssSession.ApiUrl, 'folders' -join '/'
            $uri = $uri, "sortBy[0].direction=asc&sortBy[0].name=$SortBy&take=$($TssSession.Take)" -join '?'

            $filters = @()
            if ($tssParams.ContainsKey('ParentFolderId')) {
                $filters += "filter.parentFolderId=$ParentFolderId"
            }
            if ($tssParams.ContainsKey('SearchText')) {
                $filters += "filter.searchText=$SearchText"
            }
            if ($tssParams.ContainsKey('PermissionRequired')) {
                foreach ($perm in $PermissionRequired) {
                    $filters += "filter.permissionRequired=$perm"
                }
            }
            if ($filters) {
                $uriFilter = $filters -join '&'
                Write-Verbose "Filters: $uriFilter"
                $uri = $uri, $uriFilter -join '&'
            }

            $invokeParams = @{
                Uri                 = $uri
                Method              = 'GET'
                PersonalAccessToken = $TssSession.AccessToken
            }
            Write-Verbose "Performing the operation $($invokeParams.Method) $($invokeParams.Uri)"
            $Error.Clear()
            try {
                $apiResponse = Invoke-TssRestApi @invokeParams -ErrorAction Stop
                $restResponse = $apiResponse
            } catch {
                Write-Warning 'Issue on search request'
                #$err = $_
                #. $ErrorHandling $err
            } finally {
                $Error.Clear()
            }

            if ($restResponse.records.Count -le 0 -and $restResponse.records.Length -eq 0) {
                Write-Warning 'No Folder found'
            }
            if ($TopLevelOnly) { return $restResponse.records | Where-Object { $_.parentFolderId -eq -1 } }
            else { return $restResponse.records }
        } else {
            Write-Warning 'No valid session found'
        }
    }
}

Function Get-VMToolsStatus {
    <#
    .SYNOPSIS
        This will check the status of the VMware vmtools status.
        Properties include Name, Status, UpgradeStatus and Version
     
    .NOTES
        Name: Get-VMToolsStatus
        Author: theSysadminChannel
        Version: 1.0
        DateCreated: 2020-Sep-1
     
    .LINK
        https://thesysadminchannel.com/powercli-check-vmware-tools-status/ -
     
    .EXAMPLE
        Please refer to the -Online version
        help Get-VMToolsStatus -Online
     
    #>
     
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            ParameterSetName = 'NonPipeline'
        )]
        [Alias('VM', 'ComputerName', 'VMName')]
        [string[]]  $Name,
     
     
        [Parameter(
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Pipeline'
        )]
        [PSObject[]]  $InputObject
    )
     
    BEGIN {
        if (-not $Global:DefaultVIServer) {
            Write-Error 'Unable to continue.  Please connect to a vCenter Server.' -ErrorAction Stop
        }
     
        #Verifying the object is a VM
        if ($PSBoundParameters.ContainsKey('Name')) {
            $InputObject = Get-VM $Name
        }
     
        $i = 1
        $Count = $InputObject.Count
    }
     
    PROCESS {
        if (($null -eq $InputObject.VMHost) -and ($null -eq $InputObject.MemoryGB)) {
            Write-Error 'Invalid data type. A virtual machine object was not found' -ErrorAction Stop
        }
     
        foreach ($Object in $InputObject) {
            $Error.Clear()
            try {
                [PSCustomObject]@{
                    Name          = $Object.name
                    Status        = $Object.ExtensionData.Guest.ToolsStatus
                    UpgradeStatus = $Object.ExtensionData.Guest.ToolsVersionStatus2
                    Version       = $Object.ExtensionData.Guest.ToolsVersion
                }
            } catch {
                Write-Error $_.Exception.Message
     
            } finally {
                if ($PSBoundParameters.ContainsKey('Name')) {
                    $PercentComplete = ($i / $Count).ToString('P')
                    Write-Progress -Id 1 -Activity "Processing VM: $($Object.Name)" -Status "$i/$count : $PercentComplete Complete" -PercentComplete $PercentComplete.Replace('%', '')
                    $i++
                } else {
                    Write-Progress -Id 1 -Activity "Processing VM: $($Object.Name)" -Status "Completed: $i"
                    $i++
                }
                $Error.Clear()
            }
        }
        Write-Progress -Id 1 -Activity 'Processing VM Tools' -Completed
    }
     
    END {}
}

# The script needs to run on an OH or TX Engineer Desktop
if ($env:computername -notmatch '^(?:(?:[Oo][Hh][Oo][Ss]|[Oo][Pp][Ss][Uu][Ss])-[Ee][Nn][Gg]-|[Tt][Xx][Oo][Ss]-[Ee][Nn][Gg])\d{2}$') {
    Write-Error -Message "You must run this script from a VDI in OH or TX.`r`nExamples: OPSUS-ENG-12, OHOS-ENG-35, or TXOS-ENG97" -Category PermissionDenied

    # Exiting script
    Exit 10
}

# Warn if the Certificate is invalid, but continue
$null = Set-PowerCLIConfiguration -InvalidCertificateAction Warn -Scope Session -Confirm:$false

# Prompt user for parent directory to place customer folder in
Add-Type -AssemblyName System.Windows.Forms
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$FolderBrowser.Description = 'Select a parent folder to create the customer folder within. Do not create a folder for a customer.'
[void]$FolderBrowser.ShowDialog()
$folder = $FolderBrowser.SelectedPath

# Default to Desktop if the user does not select a directory.
if ( !$folder ) { $folder = "$Env:USERPROFILE\Desktop" }

# Prompt user for vCenter to connect to
$vCenter = myDialogBox -Title 'Select a vCenter:' -Prompt 'Please select a vCenter:' -Values $vCenters

# Connect to vCenter selected using logged on user credentials
while (!$Configuration.VIServer) { $Configuration.VIServer = Connect-VIServer $vCenter }

# Retrieve list of Resource Pools
$RPs = $null
$RPs = (Get-ResourcePool -Server $VIServer -VM *-OV65CLLCTR*).Name | Where-Object { $_.Name -notmatch $reNoMatchRPs } | Sort-Object

# Select customer and create customer directory
$RP = myDialogBox -Title 'Select a Resource Pool:' -Prompt 'Please select a Resource Pool:' -Values $RPs -Height 300
$SavePath = $folder + '\' + $RP
$Configuration.LocalPath = "$SavePath\Individual\"

# Run Get-Date early just in case date cycles by end of script
$ShareInfoCSV = "$SavePath\$(Get-Date -Format FileDateUniversal)-ShareInfo.csv"
$PrinterInfoCSV = "$SavePath\$(Get-Date -Format FileDateUniversal)-PrinterInfo.csv"
$VMsCSV = "$SavePath\$(Get-Date -Format FileDateUniversal)-VMs.csv"
$PhysicalServersCSV = "$SavePath\$(Get-Date -Format FileDateUniversal)-PhysicalServers.csv"
$PrinterConfigCSV = "$SavePath\$(Get-Date -Format FileDateUniversal)-PrinterConfig.csv"
$ServerDiscovery_ReportTXT = "$SavePath\$(Get-Date -Format FileDateUniversal)-ServerDiscoveryReport.txt"
$AllsoftwareCSV = "$SavePath\$(Get-Date -Format FileDateUniversal)-Allsoftware.csv"
$ScriptOutput = "$SavePath\$(Get-Date -Format FileDateUniversal)-ScriptResults.txt"
$ScriptErrors = "$SavePath\$(Get-Date -Format FileDateUniversal)-ScriptErrors.log"

$ShareInfoFilter = "Individual\$(Get-Date -f yyyy-MM-dd)-*-ShareInfo.csv"
$PrinterInfoFilter = "Individual\$(Get-Date -f yyyy-MM-dd)-*-PrinterInfo.csv"
$VMsFilter = "Individual\$(Get-Date -f yyyy-MM-dd)-*-VMs.csv"
$PhysicalServersFilter = "Individual\$(Get-Date -f yyyy-MM-dd)-*-PhysicalServers.csv"
$PrinterConfigFilter = "Individual\$(Get-Date -f yyyy-MM-dd)-*-PrinterConfig.csv"
$ServerDiscovery_ReportFilter = "Individual\$(Get-Date -f yyyy-MM-dd)-*-ServerDiscoveryReport.txt"
$AllsoftwareFilter = "Individual\$(Get-Date -f yyyy-MM-dd)-*-Allsoftware.csv"

# Delete path if it already exists
if (Test-Path -Path $SavePath) { Remove-Item -Path "$SavePath" -Recurse -Force }
$null = New-Item -Path "$SavePath" -ItemType Directory -Force

# Retrieve list of powered on Windows VMs for this customer. Order the list by CPU usage
$VMs = $null
$VMs = Get-VM -Server $Configuration.VIServer -Location $RP | Where-Object { $_.PowerState -eq 'PoweredOn' -and $_.Guest.OSFullName -match $reVMs }
$OrderedVMs = $VMs | Select-Object Name, @{Name = 'CpuUsageAvg'; Expression = { [Math]::Round((($_ | Get-Stat -Realtime -Stat cpu.usage.average | Measure-Object Value -Average).Average), 2) } } | Sort-Object -Property CpuUsageAvg -Descending
$MaxRunspaces = [math]::ceiling($VMs.Count / 4)

# Get VM Tools status for all VMs
$VMsToolsStatus = Get-VMToolsStatus -Name $VMs
foreach ($VMtoolsStatus in $VMsToolsStatus) {
    if ($VMtoolsStatus.UpgradeStatus -ne 'guestToolsCurrent') {
        $Configuration.ScriptErrors += "WARNING: The version of VMware Tools on VM '$($VMtoolsStatus.Name)' is out of date and may cause the script to work improperly."
    }
}

# Prompt for parkplaceintl.okta.com credentials, these match Thycotic Secret Server (TSS) credentials
$ppiOktaCreds = $null
while (!$ppiOktaCreds) {
    $ppiOktaCreds = Get-Credential -Message 'Please enter your parkplaceintl.okta.com credentials:' -UserName "PARKPLACEINTL\$Env:USERNAME"
}

$Error.Clear()
try {
    # Create a session on TSS
    $session = New-TssSession -SecretServer $ssUri -Credential $ppiOktaCreds -ErrorAction Stop
} catch [System.Exception] {
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("ERROR: Login to $ssUri failed. Please check credentials and try again.", 0, 'Failed login', 0)
    Exit 5
} finally { $Error.Clear() }
# Find folders in TSS that match Mnemonic from RP in vCenter
$folders = $null
# Mnemonic appears before dash, find dash
$refcharacter = $RP.IndexOf('-')
try {
    # Eliminate whitespaces
    $mnemonic = ($RP.Substring(0, $refcharacter)).Trim()
    $folders = Search-TssFolders -TssSession $session -TopLevelOnly $true -SearchText $mnemonic -ErrorAction Stop
} catch [System.Management.Automation.MethodInvocationException] {
    $folders = Search-TssFolders -TssSession $session -TopLevelOnly $true
    $Configuration.ScriptErrors += 'No dash found in Resource Pool. Displaying all root level TSS folders.'
} catch {
    $folders = Search-TssFolders -TssSession $session -TopLevelOnly $true
    $Configuration.ScriptErrors += 'WARNING: Unknown error. Displaying all root level TSS folders. Details below:'
    $Configuration.ScriptErrors += $Error[0].Exception.GetType().FullName
    $Configuration.ScriptErrors += "Error Message: $($_.Exception.Message)"
    $Configuration.ScriptErrors += "Error in Line $($_.InvocationInfo.ScriptLineNumber): $($_.InvocationInfo.Line)"
}

# This is a fuzzy search. Some mnemonics match other portions of customer names.
# If one match occurs, don't prompt for further clarification on folder.
# If more than one match occurs, ask the user for the exact folder in TSS.
if ($folders.Count -eq 1 -Or !$folders.Count ) {
    $TssFolder = $folders
} else {
    $TssFolderName = myDialogBox -Title 'Select a folder:' -Prompt 'Please select the Secret Folder:' -Values $folders.FolderName
    $TssFolder = $folders | Where-Object { $_.FolderName -eq $TssFolderName }
}

# Obtain secrets to use for AD and DMZ access
$ADSecrets = Search-TssSecret -TssSession $session -FolderId $TssFolder.id -SecretTemplateId $Settings.SecretTemplateLookup.ActiveDirectoryAccount
$DMZSecrets = Search-TssSecret -TssSession $session -FolderId $TssFolder.id -SecretTemplateId $Settings.SecretTemplateLookup.LocalUserWindowsAccount
$ADSecretName = myDialogBox -Title 'Select a secret:' -Prompt 'Please select the AD Secret:' -Values $ADSecrets.SecretName
$DMZSecretName = myDialogBox -Title 'Select a secret:' -Prompt 'Please select the DMZ Secret:' -Values $DMZSecrets.SecretName
try {
    $ADSecret = $ADSecrets | Where-Object { $_.SecretName -eq $ADSecretName } | Get-TssSecret -TssSession $session -Comment 'Performing Site Discovery' -ErrorAction Stop
    $ADcreds = $ADSecret.GetCredential($null, 'username', 'password')
} catch [System.Management.Automation.RuntimeException] {
    try {
        $ADSecretUsername = ($ADSecrets | Where-Object { $_.SecretName -eq $ADSecretName } | Get-TssSecretField -TssSession $session -Slug username).TrimStart('"').TrimEnd('"')
        $ADSecretPasswd = ($ADSecrets | Where-Object { $_.SecretName -eq $ADSecretName } | Get-TssSecretField -TssSession $session -Slug password).TrimStart('"').TrimEnd('"')
        $ADcreds = New-Object System.Management.Automation.PSCredential ($ADSecretUsername, (ConvertTo-SecureString $ADSecretPasswd -AsPlainText -Force))
        $Configuration.ScriptErrors += "WARNING: Runtime Exception; unable to retrieve $ADSecretName credentials using Get-TssSecret. Obtained using slug workaround. https://github.com/thycotic-ps/thycotic.secretserver/issues/258"
    } catch {
        while (!$ADcreds) {
            $ADcreds = Get-Credential -Message "Trouble reaching Thycotic. Please enter $ADSecretName credentials from $($TssFolder.folderName)."
        }
        $Configuration.ScriptErrors += 'ERROR: Unable to retrieve credentials. Prompted user to enter manually.'
        $Configuration.ScriptErrors += $Error[0].Exception.GetType().FullName
        $Configuration.ScriptErrors += "Error Message: $($_.Exception.Message)"
        $Configuration.ScriptErrors += "Error in Line $($_.InvocationInfo.ScriptLineNumber): $($_.InvocationInfo.Line)"
    }
} catch {
    while (!$ADcreds) {
        $ADcreds = Get-Credential -Message "Trouble reaching Thycotic. Please enter $ADSecretName credentials from $($TssFolder.folderName)."
    }
    $Configuration.ScriptErrors += 'ERROR: Unable to retrieve credentials. Prompted user to enter manually.'
    $Configuration.ScriptErrors += $Error[0].Exception.GetType().FullName
    $Configuration.ScriptErrors += "Error Message: $($_.Exception.Message)"
    $Configuration.ScriptErrors += "Error in Line $($_.InvocationInfo.ScriptLineNumber): $($_.InvocationInfo.Line)"
}
try {
    $DMZSecret = $DMZSecrets | Where-Object { $_.SecretName -eq $DMZSecretName } | Get-TssSecret -TssSession $session -Id { $_.id } -Comment 'Performing Site Discovery'
    $DMZcreds = $DMZSecret.GetCredential($null, 'username', 'password')
} catch [System.Management.Automation.RuntimeException] {
    try {
        $DMZSecretUsername = ($DMZSecrets | Where-Object { $_.SecretName -eq $DMZSecretName } | Get-TssSecretField -TssSession $session -Slug username).TrimStart('"').TrimEnd('"')
        $DMZSecretPasswd = ($DMZSecrets | Where-Object { $_.SecretName -eq $DMZSecretName } | Get-TssSecretField -TssSession $session -Slug password).TrimStart('"').TrimEnd('"')
        $DMZcreds = New-Object System.Management.Automation.PSCredential ($DMZSecretUsername, (ConvertTo-SecureString $DMZSecretPasswd -AsPlainText -Force))
        $Configuration.ScriptErrors += "WARNING: Runtime Exception; unable to retrieve $DMZSecretName credentials using Get-TssSecret. Obtained using slug workaround. https://github.com/thycotic-ps/thycotic.secretserver/issues/258"
    } catch {
        while (!$DMZcreds) {
            $DMZcreds = Get-Credential -Message "Trouble reaching Thycotic. Please enter $DMZSecretName credentials from $($TssFolder.folderName)."
        }
        $Configuration.ScriptErrors += 'ERROR: Unable to retrieve credentials. Prompted user to enter manually.'
        $Configuration.ScriptErrors += $Error[0].Exception.GetType().FullName
        $Configuration.ScriptErrors += "Error Message: $($_.Exception.Message)"
        $Configuration.ScriptErrors += "Error in Line $($_.InvocationInfo.ScriptLineNumber): $($_.InvocationInfo.Line)"
    }
} catch {
    while (!$DMZcreds) {
        $DMZcreds = Get-Credential -Message "Trouble reaching Thycotic. Please enter $DMZSecretName credentials from $($TssFolder.folderName)."
    }
    $Configuration.ScriptErrors += 'ERROR: Unable to retrieve credentials. Prompted user to enter manually.'
    $Configuration.ScriptErrors += $Error[0].Exception.GetType().FullName
    $Configuration.ScriptErrors += "Error Message: $($_.Exception.Message)"
    $Configuration.ScriptErrors += "Error in Line $($_.InvocationInfo.ScriptLineNumber): $($_.InvocationInfo.Line)"
}
# Close the TSS Session
$null = Close-TssSession -TssSession $session

# Script block that performs the work on each VM
$Worker = {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullorEmpty()]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine] $VM,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullorEmpty()]
        [String[]] $GuestPath,
        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential] $VMcreds,
        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateNotNullorEmpty()]
        $Configuration
    )
    
    $Error.Clear()
    try {
        $TestAccess = Invoke-VMScript -Server $Configuration.VIServer -VM $VM -ScriptText "try { Get-WmiObject -Class Win32_ComputerSystem -ErrorAction Stop } catch { Write-Warning 'Access denied' }" -GuestCredential $VMcreds -ErrorAction Stop 3> $null

        if ($TestAccess.ScriptOutput -like 'WARNING: Access denied*') {
            $Configuration.ScriptErrors += "WARNING: The credentials for $($VMcreds.Username) do not work on $VM. If this is a one-off error, please correct the credentials on the server. If this error repeats often, then update the credentials in Thycotic."
        } else {
            # Copy local script to VM
            Copy-VMGuestFile -Server $Configuration.VIServer -Source $Configuration.DiscoveryScript -Destination "$GuestPath\" -VM $VM -LocalToGuest -GuestCredential $VMcreds -Force -ErrorAction Stop 3> $null
            # Run the script on the VM. Delete LocalDiscovery.ps1 to prevent copy errors from locked files.
            $Result = Invoke-VMScript -Server $Configuration.VIServer -VM $VM -ScriptText "$GuestPath\LocalDiscovery.ps1 ; Remove-Item -Path '$GuestPath\LocalDiscovery.ps1' -Force" -GuestCredential $VMcreds -ErrorAction Stop 3> $null
            # Copy the resulting files from the VM back to the user's machine.
            Copy-VMGuestFile -Server $Configuration.VIServer -Source $GuestPath -Destination $Configuration.LocalPath -VM $VM -GuestToLocal -GuestCredential $VMcreds -ErrorAction Stop -Force 3> $null
            # Delete the files generated on the VM
            $null = Invoke-VMScript -Server $Configuration.VIServer -VM $VM -ScriptText "Remove-Item -Path $GuestPath -Recurse -Force; Clear-RecycleBin -Confirm:$False" -GuestCredential $VMcreds -ErrorAction Stop 3> $null
            # Store output in ScriptResults
            $Configuration.ScriptResults += $Result.ScriptOutput
        }
    } catch [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.InvalidGuestLogin] {
        $Configuration.ScriptErrors += "WARNING: The credentials for $($VMcreds.Username) do not work on $VM. If this is a one-off error, please correct the credentials on the server. If this error repeats often, then update the credentials in Thycotic."
    } catch [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.InvalidArgument] {
        $Configuration.ScriptErrors += "WARNING: Invalid argument processing $VM."
        $Configuration.ScriptErrors += "Error Message: $($_.Exception.Message)"
        $Configuration.ScriptErrors += "Error in Line $($_.InvocationInfo.ScriptLineNumber): $($_.InvocationInfo.Line)"
    } catch [VMware.VimAutomation.Sdk.Types.V1.ErrorHandling.VimException.ViServerConnectionException], [System.InvalidOperationException] {
        $Configuration.ScriptErrors += "WARNING: Failure connecting to $VM."
        $Configuration.ScriptErrors += "Error Message: $($_.Exception.Message)"
        $Configuration.ScriptErrors += "Error in Line $($_.InvocationInfo.ScriptLineNumber): $($_.InvocationInfo.Line)"
    } catch [VMware.VimAutomation.Sdk.Types.V1.ErrorHandling.VimException.VimException] {
        $Configuration.ScriptErrors += "WARNING: Unable to process $VM. Check the VM to ensure it is working properly. Error message and attempted command below:"
        $Configuration.ScriptErrors += "Error Message: $($_.Exception.Message)"
        $Configuration.ScriptErrors += "Error in Line $($_.InvocationInfo.ScriptLineNumber): $($_.InvocationInfo.Line)"
    } catch {
        $Configuration.ScriptErrors += "WARNING: Other error processing $VM."
        $Configuration.ScriptErrors += $Error[0].Exception.GetType().FullName
        $Configuration.ScriptErrors += "Error Message: $($_.Exception.Message)"
        $Configuration.ScriptErrors += "Error in Line $($_.InvocationInfo.ScriptLineNumber): $($_.InvocationInfo.Line)"
    } finally {
        $Error.Clear()
    }
}

# Create runspace pool for parralelization
$SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $MaxRunspaces, $SessionState, $Host)
$RunspacePool.Open()

$Jobs = New-Object System.Collections.ArrayList

# Display progress bar
Write-Progress -Id 1 -Activity 'Creating Runspaces' -Status "Creating runspaces for $($VMs.Count) VMs." -PercentComplete 0

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$VMindex = 1
# Create job for each VM
foreach ($VirtualMachine in $OrderedVMs) {
    $RSVM = $VMs | Where-Object { $_.Name -eq $VirtualMachine.Name }
    # Remove spaces in VM Path
    $VMPath = "$VMScriptPath\$RSVM" -replace '\s+', ''

    if ($RSVM.Guest.HostName -eq $RSVM.Name) { $Creds = $DMZcreds }
    else { $Creds = $ADcreds }

    $PowerShell = [powershell]::Create()
    $PowerShell.RunspacePool = $RunspacePool
    $null = $PowerShell.AddScript($Worker).AddArgument($RSVM).AddArgument($VMPath).AddArgument($Creds).AddArgument($Configuration)
    
    $JobObj = New-Object -TypeName PSObject -Property @{
        Runspace   = $PowerShell.BeginInvoke()
        PowerShell = $PowerShell  
    }

    $null = $Jobs.Add($JobObj)
    $RSPercentComplete = ($VMindex / $VMs.Count ).ToString('P')
    Write-Progress -Id 1 -Activity "Runspace creation: Processing $RSVM" -Status "$VMindex/$($VMs.Count) : $RSPercentComplete Complete" -PercentComplete $RSPercentComplete.Replace('%', '')

    $VMindex++
}
Write-Progress -Id 1 -Activity 'Runspace creation' -Completed

# Used to determine percentage completed.
$TotalJobs = $Jobs.Runspace.Count

Write-Progress -Id 2 -Activity 'Server Discovery' -Status 'Running local discovery.' -PercentComplete 0

# Updated percentage complete and wait until all jobs are finished.
while ($Jobs.Runspace.IsCompleted -contains $false) {
    $CompletedJobs = ($Jobs.Runspace.IsCompleted -eq $true).Count
    $PercentComplete = ($CompletedJobs / $TotalJobs ).ToString('P')
    Write-Progress -Id 2 -Activity 'Server Discovery' -Status "$CompletedJobs/$TotalJobs : $PercentComplete Complete" -PercentComplete $PercentComplete.Replace('%', '')
    Start-Sleep -Milliseconds 100
}

# Disconnect from vCenter
Disconnect-VIServer -Server $Configuration.VIServer -Force -Confirm:$false

# Clean up runspace.
$RunspacePool.Close()

Write-Progress -Id 2 -Activity 'Server Discovery' -Completed

# Set correct path for filter to function properly
Set-Location -Path $SavePath

# Merge CSV files collected into a single file
$Error.Clear()
try { Get-ChildItem -Filter $ShareInfoFilter -ErrorAction Stop | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $ShareInfoCSV -NoTypeInformation -Force }
catch [System.IO.DirectoryNotFoundException] { $Configuration.ScriptErrors += "WARNING: No ShareInfo.csv files exist in $SavePath\Individual" }
finally { $Error.Clear() }
try { Get-ChildItem -Filter $PrinterInfoFilter -ErrorAction Stop | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $PrinterInfoCSV -NoTypeInformation -Force }
catch [System.IO.DirectoryNotFoundException] { $Configuration.ScriptErrors += "WARNING: No PrinterInfo.csv files exist in $SavePath\Individual" }
finally { $Error.Clear() }
try { Get-ChildItem -Filter $VMsFilter -ErrorAction Stop | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $VMsCSV -NoTypeInformation -Force }
catch [System.IO.DirectoryNotFoundException] { $Configuration.ScriptErrors += "WARNING: No VMs.csv files exist in $SavePath\Individual" }
finally { $Error.Clear() }
try { Get-ChildItem -Filter $PhysicalServersFilter -ErrorAction Stop | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $PhysicalServersCSV -NoTypeInformation -Force }
catch [System.IO.DirectoryNotFoundException] { $Configuration.ScriptErrors += "WARNING: No PhysicalServers.csv files exist in $SavePath\Individual" }
finally { $Error.Clear() }
try { Get-ChildItem -Filter $PrinterConfigFilter -ErrorAction Stop | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $PrinterConfigCSV -NoTypeInformation -Force }
catch [System.IO.DirectoryNotFoundException] { $Configuration.ScriptErrors += "WARNING: No PrinterConfig.csv files exist in $SavePath\Individual" }
finally { $Error.Clear() }
try { Get-ChildItem -Filter $AllsoftwareFilter -ErrorAction Stop | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $AllsoftwareCSV -NoTypeInformation -Force }
catch [System.IO.DirectoryNotFoundException] { $Configuration.ScriptErrors += "WARNING: No Allsoftware.csv files exist in $SavePath\Individual" }
finally { $Error.Clear() }

# Merge TXT files collected into a single file
try {
    Get-Content -Path $ServerDiscovery_ReportFilter -ErrorAction Stop | Set-Content -Path $ServerDiscovery_ReportTXT 
} catch [System.Exception] {
    $Configuration.ScriptErrors += 'WARNING: No Server Discovery output data detected. Please ensure customer has powered on VMs and that credentials are correct.'
} catch {
    $Configuration.ScriptErrors += $Error[0]
    $Configuration.ScriptErrors += $Error[0].Exception.GetType().FullName
} finally { $Error.Clear() }

# Change path back to script location
Set-Location -Path $PSScriptRoot

# Write script output to log file
if (Test-Path -Path $ScriptOutput -PathType leaf) { Clear-Content -Path $ScriptOutput }
Add-Content -Path $ScriptOutput -Value $Configuration.ScriptResults

# Write script errors to log file
if (Test-Path -Path $ScriptErrors -PathType leaf) { Clear-Content -Path $ScriptErrors }
Add-Content -Path $ScriptErrors -Value $Configuration.ScriptErrors

Write-Host "Script log saved to $ScriptOutput"
Write-Host "Script error log saved to $ScriptErrors"

$wshell = New-Object -ComObject Wscript.Shell
$elapsedMinutes = $stopwatch.Elapsed.TotalMinutes
$null = $wshell.Popup("Operation Completed in $elapsedMinutes minutes", 0, 'Done', 0)
#####END OF SCRIPT#######