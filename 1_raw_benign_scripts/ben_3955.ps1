# https://forums.adobe.com/thread/2621275

cd  C:\Users\cmartinezv\Documents

# This will Stop the Services, and change the startup from Automatic to Manual - Opening Adobe Applications will start these services, without your interaction. If you have issues, you can manually start them by replacing Get-Service with Start-Service, or open the Services Panel with WindowsKey+R: "services.msc"
# Setting Startup to Manual only needs to be run once. Stopping the services needs to be done each time you exit application, if you don't want background services running. Such as Sync.

Get-Service -DisplayName Adobe* | Stop-Service
Get-Service -DisplayName Adobe* | Set-Service -StartupType Manual

Get-Service -DisplayName AdobeUpdateService | Stop-Service
Get-Service -DisplayName AdobeUpdateService | Set-Service -StartupType Manual




# On Application Exit, Run This in PowerShell - or Make a Shortcut

Get-Process -Name Adobe* | Stop-Process -Force
Get-Process -Name CCLibrary | Stop-Process -Force
Get-Process -Name CCXProcess | Stop-Process -Force
Get-Process -Name CoreSync | Stop-Process -Force
Get-Process -Name AdobeIPCBroker | Stop-Process -Force
Get-Process -Name Adobe CEF Helper | Stop-Process -Force


# You can go further by removing the Run at Logon in Registry, first confirm they are found.

Get-Item Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run

# Backup your existing Run Key. This command is Powershell Only. This will create a reg file called 'RunAtLogOn-Backup' in your user folder.

# REG EXPORT HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run $env:USERPROFILE\RunAtLogOn-Backup.reg

# and the command prompt version.

# REG EXPORT HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run %USERPROFILE%\RunAtLogOn-Backup.reg


# To remove these keys in Powershell:

Get-Item Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run | Remove-ItemProperty -Name AdobeAAMUpdater-1.0

Get-Item Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run | Remove-ItemProperty -Name AdobeGCInvoker-1.0
