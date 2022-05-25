#Change settings
tzutil.exe /s 'Romance Standard Time'
Set-WinUserLanguageList -LanguageList DA-DK
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowFullPathInTitleBar
Disable-UAC

#Install programs
cinst sysinternals
cinst notepadplusplus.install
cinst googlechrome
cinst 7zip.install
cinst dotnet4.6.2

#Install Windows Features
cinst IIS-WebServerRole --source windowsfeatures
cinst IIS-WindowsAuthentication --source windowsfeatures
cinst IIS-ISAPIFilter --source windowsfeatures
cinst IIS-ISAPIExtensions --source windowsfeatures
#cinst IIS-NetFxExtensibility --source windowsfeatures
cinst IIS-HttpRedirect --source windowsfeatures
cinst IIS-RequestMonitor --source windowsfeatures
cinst IIS-ASPNET45 --source windowsfeatures
#cinst IIS-ManagementService --source windowsfeatures

#Disable windows update
Stop-Service "wuauserv" -force
Set-Service -Name "wuauserv" -StartupType "Disabled"

#manual steps:
# remove OneDrive autostart
# create ConfigitGridUser
# install sql server
## set Default Instance
## add ConfigitGridUser
# install Quote
# install Grid
# VM host port forward: 80