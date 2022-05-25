# 1. Install Chocolatey & Boxstarter
<# From PowerShell ADMINISTRATOR session run
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); Get-Boxstarter -Force
#>


# 2. From Same PowerShell, run this:
<#
### With User Credentials
$cred=Get-Credential domain\username
Install-BoxstarterPackage -PackageName https://gist.githubusercontent.com/flcdrg/87802af4c92527eb8a30/raw/boxstarter-bare.ps1 -Credential $cred
### End 

Set-ExecutionPolicy Bypass -Scope Process -Force;
. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/emorin/workstationbuilder/main/box-builder.ps1

Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/emorin/workstationbuilder/main/box-builder.ps1 -DisableReboots
#>

# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

# Downloads of non-chocolatey installed apps will go here (within system root)
$UtilDownloadPath = join-path $env:systemdrive 'Utilities\Downloads'

# Hahicorp manually installed apps go here and this gets added to your path
# $UtilBinPath = join-path $env:systemdrive 'Utilities\bin'
$UtilPath = join-path $env:systemdrive 'Utils'

# some manual installs: vscode-insiders and typora
$ManualDownloadInstall = @{
    'vscodeinsiders.exe' = 'https://go.microsoft.com/fwlink/?Linkid=852155'
   # 'vscode.exe' = 'https://go.microsoft.com/fwlink/?linkid=852157'
    'typora-setup-x64.exe' = 'https://typora.io/windows/typora-setup-x64.exe'
    'skypeonlinepowershell.exe' = 'https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowershell.exe'
}

# Chocolatey packages to install
# $ChocoInstallsMain = [System.Collections.ArrayList]::new()

######################################
#### make sure we're not bothered ####
######################################

Disable-UAC

### HACK Workaround choco / boxstarter path too long error
## https://github.com/chocolatey/boxstarter/issues/241
$ChocoCachePath = "$env:USERPROFILE\AppData\Local\Temp\chocolatey"
New-Item -Path $ChocoCachePath -ItemType Directory -Force

######################################
#### helper functions ####
######################################
# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf("/"))
$helperUri += "/scripts"
write-host "helper script base URI is $helperUri"

function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

function executeScript {
    Param ([string]$script)
    write-host "executing $helperUri/$script ..."
	iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
}

function chocoAppInstall {
    Param(  
        [string]$chocolateyAppList
    )

    if ([string]::IsNullOrWhiteSpace($chocolateyAppList) -eq $false){   
      
        $appsToInstall = $chocolateyAppList -split "," | ForEach-Object { "$($_.Trim())" }

        foreach ($app in $appsToInstall)
        {
            Write-Host ""
            Write-Host "Installing $app" -ForegroundColor Green
            Write-Host "------------------------------------" -ForegroundColor Green
            & choco upgrade $app -y --cacheLocation="$ChocoCachePath" | Write-Output
        }
    }
}

function chocoWindowsFeature {
    Param(  
        [string]$dismAppList    
    )

    if ([string]::IsNullOrWhiteSpace($dismAppList) -eq $false){
        Write-Host "DISM Features Specified"    

        $appsToInstall = $dismAppList -split "," | ForEach-Object { "$($_.Trim())" }

        foreach ($app in $appsToInstall)
        {
            Write-Host "Installing $app"
            & choco install $app /y /source windowsfeatures | Write-Output
        }
    }
}

function InstallChocoPackages {
    param (
        [array]$chocoPackages
    ) 
    <#
        Install any chocolatey packages we want setup now
    #>
    Write-Output "Installing software via chocolatey"  
    if ($chocoPackages.Count -gt 0) {
        # Install a ton of other crap I use or like, update $ChocoInsalls to suit your needs of course
        $chocoPackages | Foreach-Object {
            try {
                choco upgrade -y $_ --cacheLocation "$($env:userprofile)\AppData\Local\Temp\chocolatey"
            }
            catch {
                Write-Warning "Unable to install software package with Chocolatey: $($_)"
            }
        }
    }
    else {
        Write-Output 'There were no packages to install!'
    }
}

function Read-Choice {     
    Param(
        [Parameter(Position = 0)]
        [System.String]$Message, 
     
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]$Choices = @('&Yes', '&No', 'Yes to &All', 'No &to All'),
     
        [Parameter(Position = 2)]
        [System.Int32]$DefaultChoice = 0, 
     
        [Parameter(Position = 3)]
        [System.String]$Title = [string]::Empty
    )        
    [System.Management.Automation.Host.ChoiceDescription[]]$Poss = $Choices | ForEach-Object {            
        New-Object System.Management.Automation.Host.ChoiceDescription "$($_)", "Sets $_ as an answer."      
    }       
    $Host.UI.PromptForChoice( $Title, $Message, $Poss, $DefaultChoice )
}
Function Get-SpecialPaths {
    $SpecialFolders = @{}

    $names = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])

    foreach($name in $names) {
        $SpecialFolders[$name] = [Environment]::GetFolderPath($name)
    }

    $SpecialFolders
}

Function Get-EnvironmentVariableNames {
    param (
        [string]$Scope
    )

    ([Environment]::GetEnvironmentVariables($Scope).GetEnumerator()).Name
}

Function Get-EnvironmentVariable {
    param (
        [string]$Name,
        [string]$Scope
    )

    [Environment]::GetEnvironmentVariable($Name, $Scope)
}

Function Add-EnvPath {
    # Adds a path to the $ENV:Path list for a user or system if it does not already exist (in both the system and user Path variables)
    param (
        [string]$Location,
        [string]$NewPath
    )

    $AllPaths = $Env:Path -split ';'
    if ($AllPaths -notcontains $NewPath) {
        Write-Output "Adding Utilties bin directory path to the environmental path list: $UtilPath"

        $NewPaths = (@(([Environment]::GetEnvironmentVariables($Location).GetEnumerator() | Where {$_.Name -eq 'Path'}).Value -split ';') + $UtilPath | Select-Object -Unique) -join ';'

        [Environment]::SetEnvironmentVariable("PATH", $NewPaths, $Location)
    }
}

function Start-Proc {
    param([string]$Exe = $(Throw "An executable must be specified"),
          [string]$Arguments,
          [switch]$Hidden,
          [switch]$waitforexit)

    $startinfo = New-Object System.Diagnostics.ProcessStartInfo
    $startinfo.FileName = $Exe
    $startinfo.Arguments = $Arguments
    if ($Hidden) {
        $startinfo.WindowStyle = 'Hidden'
        $startinfo.CreateNoWindow = $True
    }
    $process = [System.Diagnostics.Process]::Start($startinfo)
    if ($waitforexit) { $process.WaitForExit() }
}

$ConfirmPreference = "None" #ensure installing powershell modules don't prompt on needed dependencies

# Need this to download via Invoke-WebRequest
[Net.ServicePointManager]::SecurityProtocol =  [System.Security.Authentication.SslProtocols] "tls, tls11, tls12"

# Trust the psgallery for installs
Write-Host -ForegroundColor 'Yellow' 'Setting PSGallery as a trusted installation source...'
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install/Update PowershellGet and PackageManager if needed
try {
    Import-Module PowerShellGet
}
catch {
    throw 'Unable to load PowerShellGet!'
}

# Need to set Nuget as a provider before installing modules via PowerShellGet
$null = Install-PackageProvider NuGet -Force

# Store a few things for later use
# $SpecialPaths = Get-SpecialPaths
$packages = Get-Package

if (@($packages | Where-Object {$_.Name -eq 'PackageManagement'}).Count -eq 0) {
    Write-Host -ForegroundColor cyan "PackageManager is installed but not being maintained via the PowerShell gallery (so it will never get updated). Forcing the install of this module through the gallery to rectify this now."
    Install-Module PackageManagement -Force
    Install-Module PowerShellGet -Force

    Write-Host -ForegroundColor:Red "PowerShellGet and PackageManagement have been installed from the gallery. You need to close and rerun this script for them to work properly!"
    
    Invoke-Reboot
}
else {
    $InstalledModules = (Get-InstalledModule).name
    $ModulesToBeInstalled = $ModulesToBeInstalled | Where-Object {$InstalledModules -notcontains $_}
    if ($ModulesToBeInstalled.Count -gt 0) {
        Write-Host -ForegroundColor:cyan "Installing modules that are not already installed via powershellget. Modules to be installed = $($ModulesToBeInstalled.Count)"
        Install-Module -Name $ModulesToBeInstalled -AllowClobber -AcceptLicense -ErrorAction:SilentlyContinue
    }
    else {
        Write-Output "No modules were found that needed to be installed."
    }
}

#--- Setting up Windows ---
executeScript "FileExplorerSettings.ps1";
executeScript "SystemConfiguration.ps1";
executeScript "RemoveDefaultApps.ps1";
executeScript "Fonts.ps1";
executeScript "Browsers.ps1";
executeScript "CommonAdminTools.ps1";
executeScript "CommonDevTools.ps1";
executeScript "Tools.ps1";
executeScript "HyperV.ps1";
executeScript "WSL.ps1";
executeScript "Docker.ps1";
executeScript "Azure.ps1";
executeScript "SQL.ps1";
executeScript "OtherTools.ps1";

# # Windows features
# choco install IIS-WebServerRole IIS-NetFxExtensibility45 IIS-HttpCompressionDynamic IIS-WindowsAuthentication IIS-ASPNET45 IIS-IIS6ManagementCompatibility -source windowsfeatures

# cup becyicongrabber --cacheLocation="$ChocoCachePath"

# if ((get-wmiobject Win32_ComputerSystem).manufacturer -like "*Dell*") {
#     cup dellcommandupdate-uwp --cacheLocation="$ChocoCachePath"
# }

# cup hwinfo --cacheLocation="$ChocoCachePath"

# cup msbuild-structured-log-viewer --cacheLocation="$ChocoCachePath"

# cup PDFXchangeEditor --cacheLocation="$ChocoCachePath" --params '"/NoDesktopShortcuts /NoUpdater"'
# cup pingplotter --cacheLocation="$ChocoCachePath"
# cup windirstat --cacheLocation="$ChocoCachePath"

# # $docker = "C:\Program Files\Docker\Docker\Resources\bin\docker.exe"

# # Install-Module posh-git -AllowPrerelease -Force

# # C:\windows\system32\inetsrv\appcmd.exe unlock config -section:windowsAuthentication
# # C:\windows\system32\inetsrv\appcmd.exe unlock config -section:anonymousAuthentication

# # Note: There are ususally VS Solution-specific config file in .vs\config\applicationhost.config too
# # & "C:\Program Files\IIS Express\appcmd.exe" unlock config -section:windowsAuthentication
# # & "C:\Program Files\IIS Express\appcmd.exe" unlock config -section:anonymousAuthentication

# #PowerShell help
# # Update-Help -ErrorAction SilentlyContinue

# Install after other packages, so integration will work
cup beyondcompare --cacheLocation="$ChocoCachePath"
cup beyondcompare-integration --cacheLocation="$ChocoCachePath"

# # No SMB1 - https://blogs.technet.microsoft.com/filecab/2016/09/16/stop-using-smb1/
# Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol

# # Cleanup reboot log temp file
# Remove-Item $reboot_log -Force

#--- reenabling critial items ---
Enable-MicrosoftUpdate
Install-WindowsUpdate -AcceptEula -GetUpdatesFromMS
Enable-UAC