# Leo Laporte, 5 April 2019

$computername = "LeoX1E1"

# A tip of the hat to  Nick Craver 
# https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9
# and Jess Frazelle
# https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f

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

#---- TEMPORARY ---
Disable-UAC

##################
# Privacy Settings
##################

# Privacy: Let apps use my advertising ID: Disable
If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null
}

# Privacy: SmartScreen Filter for Store Apps: Disable
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Name EnableWebContentEvaluation -Type DWord -Value 0

# WiFi Sense: HotSpot Sharing: Disable
If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
    New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null
}

# Start Menu: Disable Bing Search Results
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0

# Start Menu: Disable Cortana 
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'Windows Search' -ItemType Key
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name AllowCortana -Type DWORD -Value 0

############################
# Personal Preferences on UI
############################

# Replace CAPS-LOCK with CTRL (requires reboot)
hexified = "00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00".Split(',') | % { "0x$_"};
$kbLayout = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout';
New-ItemProperty -Path $kbLayout -Name "Scancode Map" -PropertyType Binary -Value ([byte[]]$hexified);

# Hide useless folders
gi "$Home\3D Objects",$Home\Contacts,$Home\Favorites,$Home\Links,"$Home\Saved Games",$Home\Searches -Force | foreach { $_.Attributes = $_.Attributes -bor "Hidden" }

# Change Explorer home screen back to "This PC"
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1

# Better File Explorer
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1		
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1		
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

# These make "Quick Access" behave much closer to the old "Favorites"

# Disable Quick Access: Recent Files
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 0

# Disable Quick Access: Frequent Folders
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 0

# Disable the Lock Screen (the one before password prompt - to prevent dropping the first character)
If (-Not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization)) {
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name Personalization | Out-Null
}
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Type DWord -Value 1

# Disable Xbox Gamebar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

# Turn off People in Taskbar
If (-Not (Test-Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
    New-Item -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People | Out-Null
}
Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name PeopleBand -Type DWord -Value 0

#################
# Windows Updates
#################

# Change Windows Updates to "Notify to schedule restart"
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name UxOption -Type DWord -Value 1

# Disable P2P Update downloads outside of local network
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config -Name DODownloadMode -Type DWord -Value 1
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization -Name SystemSettingsDownloadMode -Type DWord -Value 3


###############################
# Windows 10 Metro App Removals
# These start commented out so you choose
# Just remove the # (comment in PowerShell) on the ones you want to remove
###############################

# Be gone, heathen!
Get-AppxPackage king.com.CandyCrushSaga | Remove-AppxPackage

#Remove CandyCrushFriends 
Get-AppxPackage king.com.CandyCrushFriends | Remove-AppxPackage

# Bing Weather, News, Sports, and Finance (Money):
#Get-AppxPackage Microsoft.BingWeather | Remove-AppxPackage
#Get-AppxPackage Microsoft.BingNews | Remove-AppxPackage
#Get-AppxPackage Microsoft.BingSports | Remove-AppxPackage
#Get-AppxPackage Microsoft.BingFinance | Remove-AppxPackage

# Xbox:
Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage

# Windows Phone Companion
#Get-AppxPackage Microsoft.WindowsPhone | Remove-AppxPackage

# Solitaire Collection
Get-AppxPackage Microsoft.MicrosoftSolitaireCollection | Remove-AppxPackage

# People
Get-AppxPackage Microsoft.People | Remove-AppxPackage

# Groove Music
Get-AppxPackage Microsoft.ZuneMusic | Remove-AppxPackage

# Movies & TV
Get-AppxPackage Microsoft.ZuneVideo | Remove-AppxPackage

# OneNote
#Get-AppxPackage Microsoft.Office.OneNote | Remove-AppxPackage

# Photos
#Get-AppxPackage Microsoft.Windows.Photos | Remove-AppxPackage

# Sound Recorder
#Get-AppxPackage Microsoft.WindowsSoundRecorder | Remove-AppxPackage

# Mail & Calendar
Get-AppxPackage microsoft.windowscommunicationsapps | Remove-AppxPackage

# Skype (Metro version)
Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage

# Now install my apps using Chocolatey (https://chocolatey.org
choco upgrade lastpass  --yes
choco upgrade brave  --yes
choco upgrade sysinternals  --yes
choco upgrade googlechrome  --yes
choco upgrade cmder  --yes
choco upgrade keybase  --yes
choco upgrade adobe-creative-cloud  --yes
choco upgrade synologydrive  --yes
choco upgrade racket  --yes
choco upgrade autohotkey  --yes
choco upgrade dropbox  --yes
choco upgrade 7zip  --yes
choco upgrade vlc  --yes
choco upgrade powershell  --yes
choco upgrade skype  --yes
choco upgrade vscode  --yes
choco upgrade chocolateygui  --yes
choco upgrade googledrive  --yes
choco upgrade slack  --yes
choco upgrade gpg4win  --yes
choco upgrade claws-mail  --yes
choco upgrade cpu-z  --yes
choco upgrade hexchat  --yes
choco upgrade Microsoft-Hyper-V-All -source windowsFeatures --yes
choco upgrade Microsoft-Windows-Subsystem-Linux -source windowsfeatures --yes
choco upgrade git -params '"/GitAndUnixToolsOnPath /WindowsTerminal"' --yes
choco upgrade poshgit --yes
choco upgrade docker-for-windows --yes

# Fonts
choco upgrade firacode  --yes
choco upgrade inconsolata --yes

#--- Restore Temporary Settings ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

#--- Rename the Computer ---
# Requires restart, or add the -Restart flag
if ($env:computername -ne $computername) {
	Rename-Computer -NewName $computername
}

