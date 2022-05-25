# Description: Boxstarter Script
# Author: AspDotNetCP <key.man@gmx.com>
# Last Updated: 2018-12-23
#
# Run this Boxstarter by calling the following from an **ELEVATED PowerShell instance**:
#     `set-executionpolicy Unrestricted`
#     `. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force`
#     `Install-BoxstarterPackage -DisableReboots -PackageName <URL-TO-RAW-GIST>`

# Initialize reboot log file
$reboot_log = "C:\installation.rbt"
if ( -not (Test-Path $reboot_log) ) { New-Item $reboot_log -type file }
$reboots = Get-Content $reboot_log

# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$true # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

#Temporary - Disable UAC for the installation proccess
  Disable-UAC
  
#--- Windows Settings ---
Disable-BingSearch
Disable-GameBarTips

Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
Set-TaskbarOptions -Size Small -Dock Bottom -Combine Full -Lock
Set-TaskbarOptions -Size Small -Dock Bottom -Combine Full -AlwaysShowIconsOn

netsh wlan disconnect
Start-Sleep -s 15
netsh wlan connect name=leech001@unifi ssid=leech001@unifi
Start-Sleep -s 15
#--- Windows Subsystems/Features ---
# cinst Microsoft-Hyper-V-All -source windowsFeatures
# cinst Microsoft-Windows-Subsystem-Linux -source windowsfeatures


#--- Tools ---
# cinst git -params '"/GitAndUnixToolsOnPath /WindowsTerminal"' -y
cinst poshgit -dvy
# cinst sysinternals -y
# cinst vim -dvy

#--- InstallApps ---

cinst -dvy googlechrome 
cinst -dvy notepadplusplus
cinst -dvy listary
cinst -dvy ccleaner
cinst -dvy 7zip
cinst -dvy sql-server-management-studio

# cinst docker-for-windows -dvy
# cinst sharex -dvy
# cinst microsoft-teams -dvy
# cinst vcxsrv -dvy

#---Dotnet---#
# Install Visual Studio 2017 Enterprise
$section = "VisualStudio2017"
if(-not ($section -in $reboots)) {
	cinst visualstudio2017enterprise -dvy
	#Azure
	cinst visualstudio2017-workload-azure -dvy
	#Installs Unity as well for HoloLens/MR Development
	cinst visualstudio2017-workload-managedgame -dvy
	#UWP
	cinst visualstudio2017-workload-universal -dvy
	#Data tools
	cinst visualstudio2017-workload-data -dvy
	#.NET Desktop dev
	#cinst visualstudio2017-workload-manageddesktop -dvy
	#Linux C++ Development
	#cinst visualstudio2017-workload-nativecrossplat -dvy
	#Desktop C++
	#cinst visualstudio2017-workload-nativedesktop -dvy
	#Mobile Game C++ (Directx, Unreal, Cocos2D - Android/iOS)
	#cinst visualstudio2017-workload-nativegame -dvy
	#Mobile C++
	#cinst visualstudio2017-workload-nativemobile -dvy
	#Crossplat .NET Core
	cinst visualstudio2017-workload-netcoretools -dvy
	#Mobile .NET
	#cinst visualstudio2017-workload-netcrossplat -dvy
	#ASP.NET and Web Dev
	cinst visualstudio2017-workload-netweb -dvy
	#Node JS
	#cinst visualstudio2017-workload-node -dvy
	#Office/Sharepoint
	#cinst visualstudio2017-workload-office -dvy
	#Extension development
	#cinst visualstudio2017-workload-visualstudioextension -dvy
	#Mobile Web Development Tools
	#cinst visualstudio2017-workload-webcrossplat -dvy
}
if ( -not ($section -in $reboots) ) { Add-Content $reboot_log $section ; Invoke-Reboot } 

cinst -dvy dotnet4.6.1
choco install visualstudiocode -fy
cinst visualstudio2017enterprise -fy
cinst -dvy visualstudio2017-workload-netweb
cinst -dvy visualstudio2017-workload-netcoretools 
cinst -dvy visualstudio2017-workload-azure
cinst -dvy dotnetcore-sdk
cinst -dvy msbuild.communitytasks
cinst -dvy msbuild.extensionpack
cinst -dvy resharper
# cinst -dvy resharper-clt.portable
# cinst -dvy dotpeek

#====================================================
# Install Visual Studio Extensions
#Install-ChocolateyVsixPackage add-empty-file https://visualstudiogallery.msdn.microsoft.com/3f820e99-6c0d-41db-aa74-a18d9623b1f3/file/140782/6/AddAnyFile.vsix
#Install-ChocolateyVsixPackage boost-test-adapter https://visualstudiogallery.msdn.microsoft.com/5f4ae1bd-b769-410e-8238-fb30beda987f/file/105652/19/BoostUnitTestAdapter.vsix
#Install-ChocolateyVsixPackage web-essentials https://visualstudiogallery.msdn.microsoft.com/6ed4c78f-a23e-49ad-b5fd-369af0c2107f/file/50769/32/WebEssentials.vsix
#Install-ChocolateyVsixPackage chutzpah https://visualstudiogallery.msdn.microsoft.com/f8741f04-bae4-4900-81c7-7c9bfb9ed1fe/file/66979/28/Chutzpah.VS2012.vsix


#--- Uninstall unecessary applications that come with Windows out of the box ---
# 3D Builder
Get-AppxPackage Microsoft.3DBuilder | Remove-AppxPackage

# Alarms
Get-AppxPackage Microsoft.WindowsAlarms | Remove-AppxPackage

# Autodesk
Get-AppxPackage *Autodesk* | Remove-AppxPackage

# Bing Weather, News, Sports, and Finance (Money):
Get-AppxPackage Microsoft.BingFinance | Remove-AppxPackage
Get-AppxPackage Microsoft.BingNews | Remove-AppxPackage
Get-AppxPackage Microsoft.BingSports | Remove-AppxPackage
Get-AppxPackage Microsoft.BingWeather | Remove-AppxPackage

# BubbleWitch
Get-AppxPackage *BubbleWitch* | Remove-AppxPackage

# Candy Crush
Get-AppxPackage king.com.CandyCrush* | Remove-AppxPackage

# Privacy: Let apps use my advertising ID: Disable
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0
# To Restore:
#Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 1

# Privacy: SmartScreen Filter for Store Apps: Disable
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Name EnableWebContentEvaluation -Type DWord -Value 0
# To Restore:
#Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Name EnableWebContentEvaluation -Type DWord -Value 1

# checkout recent projects
mkdir C:\github
cd C:\github
git.exe clone https://github.com/microsoft/windows-dev-box-setup-scripts

#--- Restore Temporary Settings ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula


  