### Administrator privileges ###
	Set-ExecutionPolicy Unrestricted
	if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }


### CreateRestorePoint ###
  	Write-Output "Creating Restore Point incase something bad happens"
  	Enable-ComputerRestore -Drive "C:\"
  	Checkpoint-Computer -Description "RestorePoint1Stock" -RestorePointType "MODIFY_SETTINGS"

Rename-Computer -NewName "animus"

### Removing Bandwidth Stealing ###
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Pshched" -Force | Out-Null
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Pshched" -Name "NonBestEffortLimit" -Type DWord -Value 0

### System O&O Shutup ###
#	Write-Output "Running O&O Shutup..."
#	Import-Module BitsTransfer
#	Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile OOSU10.exe
#	./OOSU10.exe ooshutup10.cfg /quiet
#	rm OOSU10.exe

### Stop web search in start ### 
	reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search /f /v BingSearchEnabled /t REG_DWORD /d 0
	reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search /f /v AllowSearchToUseLocation /t REG_DWORD /d 0
	reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search /f /v CortanaConsent /t REG_DWORD /d 0

### Stop expanding in file explorer
	reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /f /v NavPaneExpandToCurrentFolder /t REG_DWORD /d 0

### Hide ribbon on file explorer
	Set-ItemProperty -path 'HKCU:\\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Ribbon\' -name MinimizedStateTabletModeOff -value 1

### disable Edge update??kind of past that
	reg add HKLM\\SOFTWARE\Microsoft\EdgeUpdate /f /v DoNotUpdateToEdgeWithChromium /t REG_DWORD /d 1

### Set wallpaper
# if (Test-Path -Path "D:\home\Pictures\Wallpaper\wallpaper.png" -PathType leaf == False) 
#  then
#	Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value "D:\home\Pictures\wallpaper.jpg"
#  else 
#       Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value "D:\home\Pictures\wallpaper.png"
# fi

### Remove Store Apps ###
	Write-Output "Removing Store Apps..."
	Get-AppxPackage -AllUsers | Remove-AppxPackage

### Reactivating Ms Store
    	Get-AppxPackage -Allusers "Microsoft.WindowsStore" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

### Reactivating Ms Photos and Video editor    	
	Get-AppxPackage -AllUsers "Microsoft.Windows.Photos" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

### Reacticating Ms snip tool
    	Get-AppxPackage -AllUsers "Microsoft.ScreenSketch" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

### Reacticating Ms notepad
	Get-AppxPackage -AllUsers "Microsoft.WindowsNotepad" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

### Reacticating Windows terminal
	Get-AppxPackage -AllUsers "Microsoft.WindowsTerminal" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}


### Install Chocolatey ###
	Write-Output "Install Chocolatey..."
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

### Installing Office ###
	Write-Output "Running Office..."
        Start-Process '
C:\Users\$env:UserName\OneDrive\Personal\scripts\WindowsScript\office.exe'

### Install Chocolatey Applications ###
	choco install -y transmission
	choco install -y mpv
	choco install -y googlechrome
	choco install -y tidal
	choco install -y geekuninstaller
	choco install -y adobereader
	choco install -y dropbox
	choco install -y duckietv
#	choco install -y gnupg
	choco install -y whatsapp
#	choco install -y gimp
#	choco install -y inkscape
#	choco install -y obs-studio
#	choco install -y kdenlive
	choco install -y vscode
#	choco install -y ccleaner
	choco install -y minecraft-launcher
#	choco install -y nordvpn
	choco install -y signal
	choco install -y discord
#	choco install -y flameshot

# install flameshot    C:\Users\skirk\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Flameshot
# install irfanview    C:\ProgramData\Microsoft\Windows\Start Menu\Programs\IrfanView

	
### REMOVING DESKTOP APPS

rm "C:\Users\$env:UserName\Desktop\Discord.lnk"
rm "C:\Users\$env:UserName\Desktop\Google Chrome.lnk"
rm "C:\Users\$env:UserName\Desktop\TIDAL.lnk"
rm "C:\Users\$env:UserName\Desktop\Signal.lnk"
rm "C:\Users\$env:UserName\Desktop\NordVPN.lnk"
rm "C:\Users\$env:UserName\Desktop\DuckieTV.lnk"
rm "C:\Users\$env:UserName\Desktop\Whatsapp.lnk"
rm "C:\Users\Public\Desktop\Minecraft Launcher.lnk"
rm "C:\Users\Public\Desktop\Visual Studio Code.lnk"
rm "C:\Users\Public\Desktop\Google Chrome.lnk"
rm "C:\Users\Public\Desktop\Transmission Qt Client.lnk"


rm "C:\Users\Public\Desktop\Microsoft Edge.lnk"
rm "C:\Users\$env:UserName\Desktop\Microsoft Edge.lnk"


### Setting Screen Scaling ###
cd C:\Users\skirk\OneDrive\Personal\scripts\WindowsScript
reg import '.\100%-dpi-scaling.reg'
reg import '.\12 time.reg'

### Hide Cortana Button ### 
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Type DWord -Value 0

### Disable Meet Now ###
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "SCAMeetNow" -Type DWord -Value 1

### Disable Mouse Pad While Mouse Connected ###
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name "LeaveOnWithMouse" -Type DWORD -Value 0


### Applications/folder Shortcuts ### (Symlink)
#New-Item -ItemType Junction -Path "C:\Users\$env:UserName\Pictures\minecraft-screenshots" -Target "C:\Users\$env:UserName\AppData\Roaming\.minecraft\screenshots"
New-Item -ItemType Junction -Path "C:\Users\$env:UserName\Documents\minecraft-schematics" -Target "C:\Users\$env:UserName\AppData\Roaming\.minecraft\schematics"
New-Item -ItemType Junction -Path "C:\Users\$env:UserName\Documents\minecraft-resourcepacks" -Target "C:\Users\$env:UserName\AppData\Roaming\.minecraft\resourcepacks"
New-Item -ItemType Junction -Path "C:\Users\$env:UserName\Documents\minecraft-modpacks" -Target "C:\Users\$env:UserName\AppData\Roaming\.minecraft\mods"

# Symlink ondrive to system so the same with above
New-Item -ItemType Junction -Path "C:\Users\$env:UserName\AppData\Roaming\.minecraft\screenshots" -Target "C:\Users\$env:UserName\OneDrive\Pictures\Screenshots\MinecraftScreenshots"


New-Item -ItemType Junction -Path "C:\Users\$env:UserName\Downloads\Torrents" -Target "D:\home\Downloads\Torrents"
New-Item -ItemType Junction -Path "C:\Users\$env:UserName\Videos\TVShows" -Target "D:\home\Videos\TVShows"
New-Item -ItemType Junction -Path "C:\Users\$env:UserName\Videos\Movies" -Target "D:\home\Videos\Movies"
New-Item -ItemType Junction -Path "C:\Users\$env:UserName\Pictures\profile pics" -Target "D:\home\Pictures\profile pics"
New-Item -ItemType Junction -Path "C:\Users\$env:UserName\Pictures\Wallpapers" -Target "D:\home\Pictures\Wallpapers"
New-Item -ItemType SymbolicLink -Path "C:\Users\$env:UserName\Pictures\wallpaper" -Target "D:\home\Pictures\wallpaper"

New-Item -ItemType SymbolicLink -Path "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\MPV.lnk" -Target "C:\ProgramData\chocolatey\lib\mpv.install\tools\mpv.exe"
New-Item -ItemType SymbolicLink -Path "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Geek Uninstaller.lnk" -Target "C:\ProgramData\chocolatey\bin\geek.exe"

Copy Dropbox magnets to desktop for downloading 



### CLEANING START MENU ###
New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\" -Name "Microsoft Office" -ItemType "directory"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office Tools\Office Language Preferences.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office Tools\Office Upload Center.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Access.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Outlook.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PowerPoint.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Publisher.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Word.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Minecraft Launcher\Minecraft Launcher.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Dropbox\Dropbox.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\" 
Move-item "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DuckieTV\DuckieTV.lnk" -Destination "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\"
Move-item "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\TIDAL Music AS\TIDAL.lnk" -Destination "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
Move-item "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\WhatsApp\WhatsApp.lnk" -Destination "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\NordSec\NordVPN.lnk" -Destination "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\NordSec\NordVPN Diagnostics.lnk" -Destination "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\"
Move-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk" -Destination "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\"
Move-Item "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk" -Destination "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\"

rm "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office Tools\"
rm "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DuckieTV"
rm "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Dropbox"
rm "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\TIDAL Music AS"
rm "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\WhatsApp"
rm "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Minecraft Launcher"

























