# Startupscript for PowerShell Cloud Shell
$script:Startuptime=[System.DateTime]::Now 

# User profile script location
$script:AzureRMProfileModule = if($PSVersionTable.PSEdition -eq 'Core'){'AzureRM.Profile.NetCore'}else{'AzureRM.Profile'}
$script:AzureADModule = 'AzureAD'
# On WindowsPowerShell, $PSVersionTable.PSEdition is Desktop; On pscore, $IsWindows is true; On Linux, all false
$script:IsWindowsOS = ($PSVersionTable.PSEdition -eq 'Desktop') -or $IsWindows
$script:CustomProfileTimeConsumption = 0

# User profile script location
if($script:IsWindowsOS)
{
    $script:UserDefaultPath = $env:USERPROFILE
    $script:tokenFileName='psAccessTokens.txt'
    $script:CurrentHostProfilePath = (Microsoft.PowerShell.Management\Join-Path  -Path $script:UserDefaultPath -ChildPath 'CloudDrive\Microsoft.PowerShell_profile.ps1')
    $script:AllHostsProfilePath    = (Microsoft.PowerShell.Management\Join-Path  -Path $script:UserDefaultPath -ChildPath 'CloudDrive\profile.ps1')

    # Access token file location
    $script:psAccessTokensFilePath = [System.IO.Path]::Combine( $script:UserDefaultPath, '.azure', $script:tokenFileName)

}else{
    # On Linux, we are not loading the profile from the clouddrive since we are already mounted on the Linux OS image: \clouddrive\.cloudconsole\acc_<user>.img 
    # For Pwsh profile, see https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-core-60?view=powershell-6#filesystem
    
    $script:UserDefaultPath = $HOME
    $script:CurrentHostProfilePath = (Microsoft.PowerShell.Management\Join-Path -Path $script:UserDefaultPath -ChildPath '.config/PowerShell/Microsoft.PowerShell_profile.ps1')
    $script:AllHostsProfilePath    = (Microsoft.PowerShell.Management\Join-Path -Path $script:UserDefaultPath -ChildPath '.config/PowerShell/profile.ps1') 
}



#region Utility Functions

# Extract default subscriptionId from Storage Profile environment variable
# Format of Storage Profile- {"storageAccountResourceId":"/subscriptions/<subscriptionGuid>/resourcegroups/<resourceGroup>/providers/Microsoft.Storage/storageAccounts/<storageAccountId>","fileShareName":"<Blob File Share>","diskSizeInGB":<diskSize>}
function Get-SubscriptionIdFromStorageProfile
{
    $subscriptionId = ''
    if ($env:ACC_STORAGE_PROFILE)
    {
        $storageProfile = $env:ACC_STORAGE_PROFILE | Microsoft.PowerShell.Utility\ConvertFrom-Json
        $storageAccountResourceId = $storageProfile.storageAccountResourceId
        if ($storageAccountResourceId)
        {
            # storageAccountResourceId is organized by the delimiter '/'
            $storageAccountResourceIdTokens = $storageAccountResourceId.Split('/')
            if ($storageAccountResourceIdTokens.Count)
            {
                # SubscriptionId is the next token after the keyword 'subscriptions'
                # This way of picking ensures that any change in the subscriptionId token location is future proofed
                $subscriptionId = $storageAccountResourceIdTokens[$storageAccountResourceIdTokens.IndexOf('subscriptions') + 1]
            }
        }
    }
    
    $subscriptionId
}

function Update-AzureAccessToken
{
    if($script:IsWindowsOS)
    {
        $acContent = Microsoft.PowerShell.Management\Get-Content $script:psAccessTokensFilePath | Microsoft.PowerShell.Utility\Out-String
        $acContent = $acContent.Replace('"','').Trim()

        # File contains Azure auth token in this format - "AccessToken;GraphToken;KeyVaultToken"
        # Extract the AccessToken and initialize AZURE_CONSOLE_TOKENS - used for Azure Cli & AzureRM logins
        # Extract the GraphToken and initialize AZURE_GRAPH_TOKENS -used for Azure AD login
        # Extract the KeyVault and initialize AZURE_KEYVAULT_TOKENS -used for accesssing KeyVault services
        $tokenArray = $acContent.Split(';')
        $env:AZURE_CONSOLE_TOKENS = $tokenArray[0]
        $env:AZURE_GRAPH_TOKENS = $tokenArray[1]
        $env:AZURE_KEYVAULT_TOKENS = $tokenArray[2]

    }
}

function Set-AzCliLogLocation
{
    if (Microsoft.PowerShell.Management\Test-Path -Path (Microsoft.PowerShell.Management\Join-Path -Path  $script:UserDefaultPath -ChildPath '\CloudDrive'))
    {
        $azureConfigDir = Microsoft.PowerShell.Management\Join-Path -Path $script:UserDefaultPath -ChildPath '\CloudDrive\.pscloudshell\.azure'
        [Environment]::SetEnvironmentVariable('AZURE_CONFIG_DIR', $azureConfigDir , 'Process')
    }
}

function Start-AzCliAuth
{    
    # Login to Azure Cli
    $azCliPath = Microsoft.PowerShell.Management\Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath '\Microsoft SDKs\Azure\CLI2\wbin\az';
    Microsoft.PowerShell.Management\Start-Process -FilePath "$azCliPath" -ArgumentList "login","--identity" -WindowStyle Hidden 
}

# Authenticate to Azure Resource Manager Service using Identity (MSI) based auth
# This is a one time authentication at Shell startup
# The Identity endpoint $env:MSI_ENDPOINT takes care of keeping the auth current
function Connect-AzureRMService
{
    param (
            
        [string]$currentSubscriptionId
    )

    # Enable AzureRM Data collection
    # Else User is prompted when Add-AzureRMAccount is invoked
    Set-PSCloudShellTelemetry
    
    Microsoft.PowerShell.Core\Import-Module $script:AzureRMProfileModule
    $addAzureRMAccountParameters = @{'Identity' = $true; 'AccountId' = $env:ACC_OID; 'TenantId' = $env:ACC_TID}
    if($currentSubscriptionId)
    {
        $addAzureRMAccountParameters.Add('SubscriptionId', $currentSubscriptionId)        
    }

    if ($env:ACC_CLOUD -eq 'dogfood')
    {
        $addAzureRMAccountParameters.Add('EnvironmentName', $env:ACC_CLOUD)
    }
    
    $azureRMAccount = & $script:AzureRMProfileModule\Add-AzureRMAccount @addAzureRMAccountParameters -ErrorAction SilentlyContinue -ErrorVariable azureRMError

    # Log any errors from AzureRM authentication
    if ($azureRMError)
    {
        $errorFolderPath =  $script:UserDefaultPath
        $azureFolderPath = (Microsoft.PowerShell.Management\Join-Path  -Path $script:UserDefaultPath -ChildPath '.azure')
        if (Microsoft.PowerShell.Management\Test-Path -Path $azureFolderPath)
        {
            $errorFolderPath = $azureFolderPath
        }
        # Use  $script:UserDefaultPath Path if .azure folder does not exist
        $azureRMError > (Microsoft.PowerShell.Management\Join-Path -Path $errorFolderPath -ChildPath 'azureRMError.err')
    }

    return $azureRMAccount
}

# Authenticate to Azure Active Directory Service
# This function needs to be run once per shell startup and everytime we get a new token from the RP
function Connect-AzureADService
{
    # AzureAD is currently not supported on PowerShell Core
    if ($PSVersionTable.PSEdition -eq 'Desktop')
    {        
        Update-AzureAccessToken

        # Authenticate to AzureAD only if Graph Token is supplied
        if ($env:AZURE_GRAPH_TOKENS)
        {
            Microsoft.PowerShell.Core\Import-Module -Name $script:AzureADModule
            $azureADParameters = @{'AadAccessToken' = $env:AZURE_GRAPH_TOKENS; 'AccountID' = $env:ACC_OID; 'TenantId' = $env:ACC_TID}

            # Connect-AzureAD does not result in a network call and the perf impact is negligible
            # This call only sets the local process context with the token, account and tenant information
            & $script:AzureAD\Connect-AzureAD @azureADParameters -ErrorAction SilentlyContinue -ErrorVariable azureADError | Microsoft.PowerShell.Core\Out-Null

            # Log any errors from AzureAD authentication
            if ($azureADError)
            {
                $errorFolderPath = $script:UserDefaultPath
                $azureFolderPath = (Microsoft.PowerShell.Management\Join-Path -Path $script:UserDefaultPath -ChildPath '.azure')
                Microsoft.PowerShell.Utility\Write-Warning -Message "An error occured while authenticating to AzureAD. Check $azureFolderPath for logs"
                if (Microsoft.PowerShell.Management\Test-Path -Path $azureFolderPath)
                {
                    $errorFolderPath = $azureFolderPath
                }
                # Use  $script:UserDefaultPath Path if .azure folder does not exist
                $azureADError > (Microsoft.PowerShell.Management\Join-Path -Path $errorFolderPath -ChildPath 'azureADError.err')
            }
        }
        else
        {
            Microsoft.PowerShell.Utility\Write-Warning -Message "Could not authenticate to AzureAD. AzureAD cmdlets might not work"
        }
    }
}

function Set-PSCloudShellTelemetry
{
    # Default value in case PSCloudShellUtility is not loaded
    Microsoft.PowerShell.Core\Import-Module -Name $script:AzureRMProfileModule
    $productVersion = '0.1.0'
    $productName = 'ps-cloud-shell'

    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent($productName, $productVersion)
    & $script:AzureRMProfileModule\Enable-AzureRMDataCollection -WarningAction SilentlyContinue
}

function Invoke-PSCloudShellUserProfile
{
    $start=[System.DateTime]::Now

    # First run all hosts profile
    if(Microsoft.PowerShell.Management\Test-Path -Path $script:AllHostsProfilePath)
    {
        try
        {
            Microsoft.PowerShell.Utility\Write-Verbose -Message 'Loading AllHosts profile ...' -Verbose

            # As the startupscript.ps1 gets executed with "." for global scope, we use "." here to use the startupscript's scope, i.e., global.
            . $script:AllHostsProfilePath
        }
        catch
        {
            # Log a warning and continue if encountering any terminating errors from the running user profile
            Microsoft.PowerShell.Utility\Write-Warning -Message "$_"
        }
    }

    # Second run current host profile
    if(Microsoft.PowerShell.Management\Test-Path -Path $script:CurrentHostProfilePath)
    {
        try
        {
            Microsoft.PowerShell.Utility\Write-Verbose -Message 'Loading CurrentHost profile ...' -Verbose

            # As the startupscript.ps1 gets executed with "." for global scope, we use "." here to use the startupscript's scope, i.e., global.
            . $script:CurrentHostProfilePath
        }
        catch
        {
            # Log a warning and continue if encountering any terminating errors from the running user profile
            Microsoft.PowerShell.Utility\Write-Warning -Message "$_"
        }
    }

    $script:CustomProfileTimeConsumption = [System.Math]::Round(([System.DateTime]::Now - $start).TotalMilliseconds)
    # display time if it's greater than 1 second
    if($script:CustomProfileTimeConsumption -gt '1000')
    {
        Microsoft.PowerShell.Utility\Write-Verbose -Message "Loading user profile took $script:CustomProfileTimeConsumption ms." -Verbose
    }

    # Clean up variables since this startup script runs as a global scope
    Microsoft.PowerShell.Utility\Remove-Variable -Name start -ErrorAction Ignore
}

#endregion

#region Initialization

# Set the user profile path to clouddrive
Microsoft.PowerShell.Utility\Set-Variable -Name PROFILE -Value $script:CurrentHostProfilePath -Scope Global
$PROFILE = $PROFILE | Microsoft.PowerShell.Utility\Add-Member -MemberType NoteProperty -Name CurrentUserAllHosts -Value $script:AllHostsProfilePath -PassThru
$PROFILE = $PROFILE | Microsoft.PowerShell.Utility\Add-Member -MemberType NoteProperty -Name CurrentUserCurrentHost -Value $script:CurrentHostProfilePath -PassThru

# Define a custom prompt function for Azure drive (Azure:) only
# Since it is defined before user profile(s) are loaded, users can still customize prompt via profile
function prompt
{
     # If inside Azure PSDrive, show the current path above the prompt
     if(($pwd.Drive).Name -eq 'Azure' -and ($pwd.Provider).Name -eq 'SHiPS')
     {
         # There is a double prompt issue on pwsh bash using write-host here. See https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences for more details.
         # Gray #8C8C8C is chosen because it's passed color contrast check for both bash and PowerShell blue
         # PS blue: #012456 vs #8C8C8C     4.5 :1
         # Bash:    #000000 vs #8C8C8C     6.25:1
         $CSI=[char]0x1b + '['
         "${CSI}38;2;140;140;140m$($pwd)${CSI}00m`nPS Azure:\> "
     }
    # else use the default prompt
    else
    {
        "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";
    }

    # .Link
    # https://go.microsoft.com/fwlink/?LinkID=225750
    # .ExternalHelp System.Management.Automation.dll-help.xml
}

# Access token file will be replace by msi. For now no changes on pscore on linux.
if( $script:IsWindowsOS)
{
    if (-not (Microsoft.PowerShell.Management\Test-Path -Path $script:psAccessTokensFilePath))
    {
        Microsoft.PowerShell.Utility\Write-Warning -Message "AccessTokens file does not exist - $script:psAccessTokensFilePath. Skipping authenticating to Azure Services"
        Set-PSCloudShellTelemetry
        . Invoke-PSCloudShellUserProfile
        return
    }
}

# Dogfood initialization script
if ($env:ACC_CLOUD -eq 'dogfood')
{
    Microsoft.PowerShell.Utility\Write-Warning -Message "You are running in a dogfood environment. Please supply a URI for Azure dogfood environment initialization script."
    $dfEnvInitScriptURI = Microsoft.PowerShell.Utility\Read-Host -Prompt "Supply the URI"
    $dfEnvInitScript = Microsoft.PowerShell.Utility\Invoke-WebRequest -Uri $dfEnvInitScriptURI -UseBasicParsing | ForEach-Object Content
    $null = [ScriptBlock]::Create($dfEnvInitScript).Invoke()
}

$AuthStartTime = [System.DateTime]::Now
# Authenticate to Azure services
# Use the default subscriptionId from Storage Profile to optimize authenticating to Azure Services using Add-AzureRMAccount
Microsoft.PowerShell.Utility\Write-Verbose -Verbose -Message 'Authenticating to Azure ...'

# On bash, 'az login' has been taken care of already
if($script:IsWindowsOS)
{
    Set-AzCliLogLocation
    Start-AzCliAuth
}

if (-not (Connect-AzureRMService -currentSubscriptionId (Get-SubscriptionIdFromStorageProfile)))
{
    Microsoft.PowerShell.Utility\Write-Warning -Message 'Azure Authentication failed.'
    . Invoke-PSCloudShellUserProfile
    return
}

# Authenticate to AzureAD
Connect-AzureADService

#endregion

#region Register to reauthenticate to AzureAD service upon receiving an updated token from the agent

$eventIdentifier = 'PSCloudShell-' + [guid]::NewGuid()
$action ={
    
    # We only need to authenticate to AzureAD upon receiving new tokens
    # since AzureAD does not support Identity (MSI) based auth yet
    Connect-AzureADService
}

# Register-ObjectEvent applies only for Full-PowerShell-Windows environment
if($PSVersionTable.PSEdition -eq 'Desktop')
{
    $fswObj = Microsoft.PowerShell.Utility\New-Object -TypeName System.IO.FileSystemWatcher
    $fswObj.Path = Microsoft.PowerShell.Management\Split-Path -Path $script:psAccessTokensFilePath
    $fswObj.Filter = Microsoft.PowerShell.Management\Split-Path -Path $script:psAccessTokensFilePath -Leaf

    $null = Microsoft.PowerShell.Utility\Register-ObjectEvent -InputObject $fswObj -EventName 'Changed' -SourceIdentifier $eventIdentifier -Action $action
}


# Measure the time spent on the Azure authentication
$AzureAuthTimeConsumption = [System.Math]::Round(([System.DateTime]::Now - $AuthStartTime).TotalMilliseconds)
PSCloudShellUtility\Add-CloudShellTelemetry -Name ACC.POWERSHELL.AZUREAUTHENTICATION -Value $AzureAuthTimeConsumption
Microsoft.PowerShell.Utility\Remove-Variable -Name AzureAuthTimeConsumption, AuthStartTime -ErrorAction Ignore

#endregion

#region Load User profile if exists

. Invoke-PSCloudShellUserProfile

#endregion

#region Set PSDefaultParameterValues for cmdlets
$PSDefaultParameterValues = @{'Install-Module:Scope' = 'CurrentUser'; 'Install-Script:Scope' = 'CurrentUser'}
#endregion

#region Load the Azure Provider initialize Azure drive
Microsoft.PowerShell.Core\Import-Module -Name AzurePSDrive
Microsoft.PowerShell.Core\Import-Module -Name PSCloudShellUtility
Microsoft.PowerShell.Utility\Write-Verbose -Verbose -Message 'Building your Azure drive ...'

$null = Microsoft.PowerShell.Management\New-PSDrive -Name Azure -PSProvider SHiPS -Root "AzurePSDrive#Azure" -Scope Global
if(-not $?)
{
    Microsoft.PowerShell.Utility\Write-Warning -Message 'Something went wrong while creating Azure drive. You can still use this shell to run Azure PowerShell commands.'
}
else
{
    Microsoft.PowerShell.Management\Set-Location -Path Azure:
}


# Set the PSReadline key handler for CloudShell key bindings and telemetry.
# Note: Set-CloudShellPSReadLineKeyHandler has to be after loading user profiles
PSCloudShellUtility\Set-CloudShellPSReadLineKeyHandler

$elapsed = [System.Math]::Round(([System.DateTime]::Now - $script:Startuptime).TotalMilliseconds, 2) - $script:CustomProfileTimeConsumption
PSCloudShellUtility\Add-CloudShellTelemetry -Name ACC.POWERSHELL.STARTUPTIME -Value $elapsed

#endregion

# Cleanup unnecessary variables
Microsoft.PowerShell.Utility\Remove-Variable -Name AllHostsProfilePath, CurrentHostProfilePath, Startuptime, elapsed, CustomProfileTimeConsumption, IsWindowsOS, UserDefaultPath -ErrorAction Ignore
Microsoft.PowerShell.Management\Remove-Item -Path env:ACC_CLUSTER -ErrorAction Ignore
