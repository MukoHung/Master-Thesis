# TODO: Set sound scheme to 'No sounds'

# Notepad++ TODOs:
# %appdata%\Notepad++\config.xml, /NotepadPlus/GUIConfigs/GUIConfig[name='TabSetting']/@replaceBySpace, 'yes'
# %appdata%\Notepad++\config.xml, /NotepadPlus/GUIConfigs/GUIConfig[name='auto-completion']/@autoCAction, 0
# %appdata%\Notepad++\stylers.xml, /NotepadPlus/GlobalStyles/WidgetStyle[fontName='Courier New']/@fontName, 'Consolas'

# TODO: unpin Edge and Store and pin default apps

$ErrorActionPreference = 'Stop'

Rename-Computer 'Taliesin'
Set-TimeZone 'Eastern Standard Time'

$screenTimeoutMinutes = 5
powercfg /change monitor-timeout-ac $screenTimeoutMinutes
powercfg /change monitor-timeout-dc $screenTimeoutMinutes
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

# Install Boxstarter
Set-ExecutionPolicy RemoteSigned -Force
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force

# Boxstarter installs itself using Chocolatey, so make sure this is set before Chocolatey installs anything else
$env:ChocolateyToolsLocation = Join-Path ([Environment]::GetFolderPath('CommonApplicationData')) 'chocolatey\tools'
[Environment]::SetEnvironmentVariable('ChocolateyToolsLocation', $env:ChocolateyToolsLocation, 'User')

Disable-BingSearch

# Workaround for https://github.com/chocolatey/boxstarter/issues/434
New-Item HKCU:\Software\Policies\Microsoft\Windows -Name Explorer
Set-ItemProperty HKCU:\Software\Policies\Microsoft\Windows\Explorer DisableSearchBoxSuggestions 1

Disable-GameBarTips

# Show taskbar buttons on taskbar where window is open
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

# Hide taskbar search box
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -Value 0

# Hide taskbar task view button
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Value 0

# Hide Windows Ink Workspace button
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace -Name PenWorkspaceButtonDesiredVisibility -Value 0

# Disable 'Let apps use advertising ID'
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Value 0

# Disable 'Show me suggested content in the Settings app'
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SubscribedContent-338393Enabled -Value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SubscribedContent-353694Enabled -Value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SubscribedContent-353696Enabled -Value 0

# Disable 'Occasionally show suggestions in Start'
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SubscribedContent-338388Enabled -Value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SystemPaneSuggestionsEnabled -Value 0

# Disable 'Show me the Windows welcome experience after updates and occasionally when I sign in to highlight what’s new and suggested'
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SubscribedContent-310093Enabled -Value 0

# Disable 'Get tips, tricks, and suggestions as you use Windows'
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SubscribedContent-338389Enabled -Value 0

# Stop default apps from coming back
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name OemPreInstalledAppsEnabled -Value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name PreInstalledAppsEnabled -Value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name PreInstalledAppsEverEnabled -Value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SilentInstalledAppsEnabled -Value 0

# Clean up the programs list

$microsoftAppsToUninstall =
    'Microsoft.BingWeather',
    'Microsoft.Microsoft3DViewer',
    'Microsoft.Getstarted', # Start menu: Tips
    'Microsoft.Messaging',
    'Microsoft.MicrosoftOfficeHub',
    'Microsoft.MicrosoftSolitaireCollection',
    'Microsoft.MixedReality.Portal',
    'Microsoft.MSPaint', # Start menu: Paint 3D
    'Microsoft.OneConnect', # Start menu: Mobile Plans
    'Microsoft.Print3D',
    'Microsoft.SkypeApp',
    'microsoft.windowscommunicationsapps', # Start menu: 'Mail' and 'Calendar'
    'Microsoft.Xbox.TCUI', # Apps & Features: 'Xbox Live'
    'Microsoft.XboxApp',
    'Microsoft.XboxGameOverlay',
    'Microsoft.XboxGamingOverlay',
    'Microsoft.YourPhone',
    'Microsoft.ZuneMusic',
    'Microsoft.ZuneVideo'
# (See Get-StartApps and https://docs.microsoft.com/windows/application-management/apps-in-windows-10)

Get-AppxPackage -AllUsers |
    Where-Object { $_.Publisher -notlike '*Microsoft*' -or $microsoftAppsToUninstall -contains $_.Name } |
    Remove-AppxPackage

Set-WindowsExplorerOptions `
    -EnableShowHiddenFilesFoldersDrives `
    -EnableShowFileExtensions `
    -EnableExpandToOpenFolder `
    -DisableOpenFileExplorerToQuickAccess `
    -DisableShowRecentFilesInQuickAccess `
    -DisableShowFrequentFoldersInQuickAccess

choco install git poshgit notepadplusplus ConEmu Firefox linqpad foobar2000 f.lux greenshot unchecky sumatrapdf Recuva -y

foreach ($directory in ('DesktopDirectory', 'CommonDesktopDirectory')) {
    Get-ChildItem ([Environment]::GetFolderPath($directory)) -Filter '*.lnk' | Remove-Item
}

# Needed for helper methods that edit settings files
. .\Utils.ps1

# Workaround for https://github.com/greenshot/greenshot/issues/136
# More flexible would be to set or add a line in the [Core] section, but this is less code and more conservative.
$greenshot = Join-Path $env:ProgramFiles 'Greenshot\Greenshot.exe'
& $greenshot /exit
ReplaceSingleLineInTextFile (Join-Path $env:APPDATA 'Greenshot\Greenshot.ini') 'ShowTrayNotification=True' 'ShowTrayNotification=False'
& $greenshot

# https://unchecky.userecho.com/communities/1/topics/485-switch-for-no-notification-icon-tray-icon
Set-ItemProperty -Path HKCU:\Software\Unchecky -Name HideTrayIcon -Value 1

# Put my current .gitconfig in place
Invoke-WebRequest 'https://gist.githubusercontent.com/jnm2/4b8d6caaf85157ea9763e22e41185f2d/raw/.gitconfig' -OutFile (
    Join-Path $env:USERPROFILE '.gitconfig')

# Download VS Code installer to the desktop
Invoke-WebRequest 'https://aka.ms/win32-x64-user-stable' -OutFile (
    Join-Path ([Environment]::GetFolderPath('DesktopDirectory')) 'Install Visual Studio Code.exe')

Enable-RemoteDesktop

Update-Help

Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
