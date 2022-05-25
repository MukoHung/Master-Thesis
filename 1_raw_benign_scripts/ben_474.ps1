Update-ExecutionPolicy Unrestricted
Set-ExplorerOptions -showHidenFilesFoldersDrives -showProtectedOSFiles -showFileExtensions
cinst win-no-annoy
cinst visualstudio2015community
cinst resharper -version 9.2.0.0
cinst fiddler4
cinst git-credential-winstore
cinst sysinternals
cinst webpi
cinst vagrant
cinst nodejs
cinst console-devel
cinst notepad2-mod
cinst notepadplusplus
cinst google-chrome-x64
cinst skype
cinst teamviewer
cinst vlc
cinst 7zip
cinst googledrive
cinst yandexdisk
cinst Microsoft-Hyper-V-All -source windowsFeatures
cinst IIS-WebServerRole -source windowsfeatures
Install-ChocolateyPinnedTaskBarItem "$env:windir\system32\mstsc.exe"
Install-ChocolateyPinnedTaskBarItem "$env:programfiles\console\console.exe"
Install-WindowsUpdate -AcceptEula