# Save drive name
$usbLocationObject = Get-Location
$usbLocation = $usbLocationObject.toString()

# Registry edits
$advancedSettingsEnable = @('TaskbarSmallIcons', 'TaskbarGlomLevel', 'MMTaskbarEnabled', 'MMTaskbarGlomLevel')
$advancedSettingsDisable = @('ShowCortanaButton', 'HideFileExt')
# Storage Sense On, Run Daily, Delete Temporary Files, Delete Recycle Bin Daily, Delete Downloads folder Daily
$storageSettingsEnable = @(01, 04, 08, 32, 512, 256, 2048)

# Required WSL Linux Kernel, WSL2 and Ubuntu installed through chocolatey
Start-BitsTransfer -Source 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -Destination 'wslUpdate.msi'
$wslUpdate = Get-ChildItem .\wslUpdate.msi

# License file must be on USB
$chocoLicense = $usbLocation + 'chocolatey.license.xml'

# Unrestricted policy to allow for running custom scripts
Set-ExecutionPolicy Unrestricted;
# Set Security Protocol to TLS 1.2, required for chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;

function displayStep
{
    Write-Host $args[0] -ForegroundColor Red -BackgroundColor White
}

# Change Windows explorerer advanced settings via registry
# Args[0] = setting name, Args[1] = value
function setRegistrySettings
{
    foreach ($setting in $args[0])
    {
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ -Name $setting -Value $args[1]
    }
}

function setStorageSenseSettings
{
    foreach ($setting in $args[0])
    {
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name $setting -Value $args[1]
    }
}

function initialWidowsUpdate
{
    displayStep 'Running initial Windows Update...'
    Install-Module PSWindowsUpdate
    Add-WUServiceManager -MicrosoftUpdate
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot -Wait
}

function chocolateyProInstall
{
    displayStep 'Installing Chocolatey...'
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    New-Item $env:ChocolateyInstall\license -Type Directory -Force
    Copy-Item $chocoLicense $env:ChocolateyInstall\license\chocolatey.license.xml -Force
    choco feature enable -n allowGlobalConfirmation
    choco upgrade chocolatey.extension
}

function installWslUbuntu
{
    displayStep 'Installing WSL2...'
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    choco install wsl2
    Start-Process $wslUpdate -Wait
    Start-Process powershell -Wait {
        wsl --set-default-version 2;
        choco install wsl-ubuntu-2004;
    }
    $ubuntuExe = Get-ChildItem -Path 'C:\Program Files\WindowsApps' -Filter ubuntu2004.exe -Recurse
    Start-Process $ubuntuExe -Wait
}

# Clones eglove/PSSCripts from GitHub to C:\, sets directory as environment variable so scripts can be run
# from terminal.
function clonePsScriptsSetEnv
{
    displayStep 'Cloning Powershell Scripts...'
    Set-Location C:\
    choco install git gh
    Start-Process powershell -Wait {
        gh auth login;
        gh repo clone eglove/PSScripts;
    }
    $env:Path = $env:Path, "C:\PSScripts" -join ";"
    [System.Environment]::SetEnvironmentVariable('Path', $env:Path, [System.EnvironmentVariableTarget]::Machine)

    # Set scheduled task to run morning script
    $action = New-ScheduledTaskAction -Execute 'pwsh' -Argument '-command C:\PSScripts\morning.ps1 -ExecutionPolicy Bypass'
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $trigger.Delay = 'PT30S'
    $principal = New-ScheduledTaskPrincipal $env:UserName -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet
    $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
    Register-ScheduledTask update -InputObject $task
}

function installPackagesModules
{
    displayStep 'Installing Software...'
    $chocoPackages = Get-Content '/PSScripts/installedChocoPackages.txt'
    choco install $chocoPackages --skip-virus-check

    displayStep 'Installing Yarn Globals...'
    Start-Process powershell -Wait {
        yarn global add (Get-Content '/PSScripts/installedYarnPackages.txt')
    }

    displayStep 'Installing Powershell Modules...'
    $psModules = Get-Content '/PSScripts/installedPSModules.txt'
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    foreach ($module in $psModules)
    {
        Install-Package $module -Confirm
    }
}

# Set Registry Settings, changes taskbar look, hides cortana, show hidden files and file extensions
# Explorer will reset for changes to take effect
function applyRegistrySettings
{
    displayStep('Applying Registry Settings...')
    setRegistrySettings $advancedSettingsEnable 1
    setStorageSenseSettings $storageSettingsEnable 1
    setRegistrySettings $advancedSettingsDisable 0

    # Not an 'advanced' setting
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name EnableAutoTray -Value 0
    Stop-Process -Name "Explorer"
}

function copySettings
{
    Copy-Item '/PSScripts/settingsBackup/.settings' '~/AppData/Local/Jetbrains/Toolbox/.settings' -Force
    Copy-Item '/PSScripts/settingsBackup/.settings.json' '~/AppData/Local/Jetbrains/Toolbox/.settings' -Force
    Copy-Item '/PSScripts/settingsBackup/config.yaml' '~/AppData/Roaming/terminus/config.yaml' -Force
}

function cleanup
{
    # Cache git credentials
    git config --global credential.helper wincred

    displayStep('Updating Windows and cleaning up...')
    # Update windows
    Get-WindowsUpdate
    Install-WindowsUpdate -AcceptAll

    # Remove desktop shortcuts , WARNING do not target all files, this breaks the recycle bin shortcut
    # and desktop icons will permanently not show.
    Remove-Item "C:\Users\*\Desktop\*.lnk" -Force

    # Open disk cleanup tool to safely remove Windows.old
    cleanmgr /d C

    # Delete downloads
    Remove-Item $usbLocation'wslUpdate.msi'
    Remove-Item $usbLocation'script.ps1'
}

initialWidowsUpdate
chocolateyProInstall
installWslUbuntu
clonePsScriptsSetEnv
installPackagesModules
applyRegistrySettings
copySettings
cleanup
