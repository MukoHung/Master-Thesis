$scriptsUrlRoot="https://raw.githubusercontent.com/hcr923fm/boxstarter-myriad-setup/master/"
function executeScript {
    Param ([string]$script)
    write-host "executing $script ..."
	iex ((new-object net.webclient).DownloadString("$script")) -ErrorAction Ignore
}

#$ServerName = Read-Host -Prompt "Which machine are we installing on? [ $env:COMPUTERNAME ]"
#if (!$ServerName) { $ServerName= $env:COMPUTERNAME }
#$UserName = Read-Host -Prompt "Which user should the install script run as? [ $env:USERNAME ]"
#if (!$UserName) { $UserName= $env:USERNAME }

#$Cred=Get-Credential "${UserName}"

# Do some generic defucking of Windows
Write-Host "Setting up Windows Explorer" -ForegroundColor Yellow
#Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/microsoft/windows-dev-box-setup-scripts/master/scripts/FileExplorerSettings.ps1 -ComputerName $ServerName -Credential $Cred -DisableReboots
try { executeScript "https://raw.githubusercontent.com/microsoft/windows-dev-box-setup-scripts/master/scripts/FileExplorerSettings.ps1" }
catch { Write-Host "Unable to set up Windows Explorer!" -ForegroundColor Red }

Write-Host "Removing cruft apps" -ForegroundColor Yellow
#Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/microsoft/windows-dev-box-setup-scripts/master/scripts/RemoveDefaultApps.ps1 -ComputerName $ServerName -Credential $Cred -DisableReboots
try{ executeScript "https://raw.githubusercontent.com/microsoft/windows-dev-box-setup-scripts/master/scripts/RemoveDefaultApps.ps1" }
catch { Write-Host "Unable to remove default applications!" -ForegroundColor Red }

Write-Host "Disabling unnecessary features and installing aria2" -ForegroundColor Yellow
#Install-BoxstarterPackage -PackageName "$scriptsUrlRoot/scripts/enable_utilities.ps1"-ComputerName $ServerName -Credential $Cred -DisableReboots
#executeScript "$scriptsUrlRoot/scripts/enable_utilities.ps1"
Disable-GameBarTips
Disable-MicrosoftUpdate
Disable-UAC
Disable-BingSearch
Enable-RemoteDesktop
Set-StartScreenOptions -EnableBootToDesktop -EnableDesktopBackgroundOnStart
Set-ExplorerOptions -showFileExtensions -showHiddenFilesFoldersDrives -showProtectedOSFiles
cinst aria2 -y
cinst ccleaner -y
cinst speccy -y
cinst vlc -y
cinst sublimetext3 -y
# cinst intel-dsa -y

# FFMpeg is 64bit only in choco
if([System.Environment]::Is64BitOperatingSystem){
    cinst ffmpeg -y
}

Write-Host "Installing useful web browsers" -ForegroundColor Yellow
try {executeScript "https://raw.githubusercontent.com/microsoft/windows-dev-box-setup-scripts/master/scripts/Browsers.ps1"}
catch { Write-Host "Unable to install browsers!" -ForegroundColor Red }
