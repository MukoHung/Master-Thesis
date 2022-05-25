# Description: Boxstarter Script
#
# Install boxstarter:
# 	. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
#
# You might need to set: Set-ExecutionPolicy RemoteSigned
#
# Run this boxstarter by calling the following from an **elevated** command-prompt:
# 	start http://boxstarter.org/package/nr/url?<URL-TO-RAW-GIST>
# OR
# 	Install-BoxstarterPackage -PackageName <URL-TO-RAW-GIST> -DisableReboots
#
# Learn more: http://boxstarter.org/Learn/WebLauncher

# Set & config start settings

Write-Verbose "Configure: ExecutionPolicy to RemoteSigned"
Set-ExecutionPolicy Unrestricted -Force

# Install Boxstarter
Write-Verbose "Install: Boxstarter"
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force

Write-Verbose "Configure: Temporarily disable UAC"
Disable-UAC

Write-Verbose "Configure: Trust PSGallery"
Get-PackageProvider -Name NuGet -ForceBootstrap
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Write-Verbose "Install: PowerShell Get"
Install-Module -Name PowerShellGet -force

# Enable Windows Features..
Write-Verbose "Configure: WindowsOptionalFeatures for WSL"
cinst Microsoft-Windows-Subsystem-Linux -source windowsfeatures
cinst VirtualMachinePlatform -source windowsfeatures

# Chocolatey Installs
Write-Verbose "Install: Brave browser "
cinst -y brave

Write-Verbose "Install: Microsoft Edge browser"
cinst -y microsoft-edge

Write-Verbose "Install: Vivaldi browser "
cinst -y vivaldi

Write-Verbose "Install: Adobe Reader "
cinst -y adobereader

Write-Verbose "Install: Dashlane "
cinst -y dashlane

Write-Verbose "Install Microsoft teams "
cinst -y microsoft-teams.install

Write-Verbose "Install: Logitech options "
cinst -y logitech-options

Write-Verbose "Install: Azure Data Studio "
cinst -y azure-data-studio

Write-Verbose "Install: Docker Desktop "
cinst -y docker-desktop

Write-Verbose "Install: Git "
cinst -y git.install --params /GitOnlyOnPath /WindowsTerminal

Write-Verbose "Install: Pwsh"
cinst -y powershell-core

Write-Verbose "Install: VS Code Insiders "
cinst -y vscode-insiders

Write-Verbose "Install: Dotnet core SDK"
cinst -y dotnetcore-sdk

Write-Verbose "Install: Snagit"
cinst -y snagit

#Write-Verbose "Install: Windows terminal "
#cinst -y microsoft-windows-terminal

Write-Verbose "Make new dir for githubrepos"
mkdir C:\githubrepos

# Define Bloatware appxpackages to remove
$bloatApps = @(
    #Unnecessary Windows 10 AppX Apps
    "Microsoft.BingNews"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.News"
    "Microsoft.Office.Lens"
    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.RemoteDesktop"
    "Microsoft.SkypeApp"
    "Microsoft.StorePurchaseApp"
    "Microsoft.Office.Todo.List"
    "Microsoft.Whiteboard"
    "Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCamera"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    #Sponsored Windows 10 AppX Apps
    #Add sponsored/featured apps to remove in the "*AppName*" format
    "*EclipseManager*"
    "*ActiproSoftwareLLC*"
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
    "*Duolingo-LearnLanguagesforFree*"
    "*PandoraMediaInc*"
    "*CandyCrush*"
    "*BubbleWitch3Saga*"
    "*Wunderlist*"
    "*Flipboard*"
    "*Twitter*"
    "*Facebook*"
    "*Spotify*"
    "*Minecraft*"
    "*Royal Revolt*"
    "*Sway*"
    "*Speed Test*"
    "*Dolby*"
    #Optional: Typically not removed but you can if you need to for some reason
    #"*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
    #"*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
    #"*Microsoft.BingWeather*"
    #"*Microsoft.MSPaint*"
    #"*Microsoft.MicrosoftStickyNotes*"
    #"*Microsoft.Windows.Photos*"
    #"*Microsoft.WindowsCalculator*"
    #"*Microsoft.WindowsStore*"
)

# Function to remove defined bloatware appxpackages
Function Remove-BloatAppxApps {
    foreach ($bloatApp in $bloatApps) {
        Write-Verbose "Trying to remove $bloatApp."
        Get-AppxPackage -Name $bloatApp | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $bloatApp | Remove-AppxProvisionedPackage -Online
    }
}

Write-Verbose "Remove all the bloatware apps"
Remove-BloatAppxApps

Write-Verbose "Configure: Disable Bing as search engine in taskbar & start menu"
Disable-BingSearch

Write-Verbose "Configure Windows: Explorer Options"
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -DisableOpenFileExplorerToQuickAccess -DisableShowFrequentFoldersInQuickAccess -DisableShowRecentFilesInQuickAccess

Write-Verbose "Configure Windows: Taskbar"
Set-TaskbarOptions -Size Large -Dock Bottom -Combine Full -AlwaysShowIconsOn

Write-Verbose "Configure Windows: Better File Explorer"
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1		
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1		
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

Write-Verbose "Always show all items in system tray"
Set-ItemProperty -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name EnableAutoTray -Value 0

Write-Verbose "Configure Windows: Privacy: Disable Advertising Info"
If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null
}
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0

Write-Verbose "Configure Windows: Set WSL Version 2"
wsl --install
wsl --set-default-version 2

Write-Verbose "Configure: git global config"
git config --global user.name "Sandro Christiaan"
git config --global user.email "schristiaan@hotmail.com"

Write-Verbose "Disable PowerShell v2"
Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root

Write-Verbose "Disable SMBv1"
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol

#--- Rename the Computer ---
# Requires restart, or add the -Restart flag
Write-Verbose "Configure Windows: rename Computernam"
$computerName = "SANE"
if ($env:COMPUTERNAME -ne $computerName) {
    Rename-Computer -NewName $computerName
}

#Apps left to install via Microsoft store
Write-Verbose "To install via Microsoft store, Windows Terminal, Spotify, Whatsapp desktop, WSL Ubuntu, Circuit"

Write-Verbose "Configure: Enable UAC"
Enable-UAC

Write-Verbose "Confifure: Windows updates defaults"
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

Write-Verbose "Script completed."