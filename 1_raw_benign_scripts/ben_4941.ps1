#Requires -RunAsAdministrator

Write-Host "NÃO EXECUTE ESSE SCRIPT USANDO O WINDOWSTERMINAL." -ForegroundColor Red

# Habilita o WSL
Write-Host "Habilitando o WSL" -ForegroundColor Green
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Renomeia o computador
Write-Host "Renomeando o computador para 'Rafael-Windows'" -ForegroundColor Green
Rename-Computer -NewName "Rafael-Windows"

# Instala o Chocolatey
Write-Host "Instalando o Chocolatey" -ForegroundColor Green
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Instala os pacotes
Write-Host "Instalando os pacotes do Chocolatey" -ForegroundColor Green
choco install adoptopenjdk16 `
	7zip `
	androidstudio `
	anki `
	autohotkey `
	batteryinfoview `
	brave `
	bulk-crap-uninstaller `
	bulkrenameutility `
	calibre `
	ccleaner `
	choco-cleaner `
	choco-upgrade-all-at-startup `
	cpu-z `
	ddu `
	discord `
	dropbox `
	ds4windows `
	epicgameslauncher `
	everything `
	ffmpeg-batch `
	firefox `
	flameshot `
	gamesavemanager `
	git `
	goggalaxy `
	google-drive-file-stream `
	googlechrome `
	gpu-z `
	gradle `
	gsudo `
	handbrake `
	hwmonitor `
	icloud `
	imageglass `
	insomnia-rest-api-client `
	itunes `
	lame `
	libreoffice-fresh `
	linkshellextension `
	lockhunter `
	logitech-options `
	megasync `
	mo2 `
	msiafterburner `
	nodejs-lts `
	origin `
	powertoys `
	eartrumpet `
	processhacker `
	putty `
	python3 `
	remove-empty-directories `
	revo-uninstaller `
	rufus `
	samsung-magician `
	samsung-nvme-driver `
	samsung-usb-driver `
	screentogif `
	spotify `
	steam `
	stremio `
	telegram `
	transmission `
	treesizefree `
	amazongames `
	twitch `
	ubisoft-connect `
	unchecky `
	unity-hub `
	vdhcoapp `
	veracrypt `
	virtualbox `
	vlc `
	vortex `
	vscode `
	whatsapp `
	wirelessnetview `
	xmind `
	yacreader `
	yarn `
	youtube-dl-gui --ignore-checksums -y

# winget install --id=Amazon.Kindle -e --accept-package-agreements
# winget install --id=Dell.CommandUpdate -e --accept-package-agreements
# winget install --id=GielCobben.Caption -e
# winget install --id=Google.ChromeRemoteDesktop  -e
# winget install --id=JohnMacFarlane.Pandoc  -e
# winget install --id=Microsoft.WindowsTerminal.Preview  -e
# winget install --id=Nvidia.RTXVoice -e --accept-package-agreements
# winget install --id=Ombrelin.PandocGui  -e
# winget install --id=PlayStation.PSRemotePlay -e --accept-package-agreements
# winget install --id=Samsung.DeX  -e
# winget install --id=Samsung.SmartSwitch  -e
# winget install --id=Streamlink.Streamlink  -e
# winget install --id=ThePBone.GalaxyBudsClient  -e
# winget install --id=WeMod.WeMod -e --accept-package-agreements

# # XBOX
# winget install --id=9MV0B5HZVK9Z -e --accept-package-agreements

# # Dell Power Manager
# winget install --id=9PD11RQ8QC9K -e --accept-package-agreements

# # Raw Image Extension
# winget install --id=9NCTDW2W1BH8 -e --accept-package-agreements

# # VP9 Video Extensions
# winget install --id=9N4D0MSMP0PT -e --accept-package-agreements

# # NVIDIA Control Panel
# winget install --id=9NF8H0H7WMLT -e --accept-package-agreements

# # HEIF Image Extensions
# winget install --id=9PMMSR1CGPWG -e --accept-package-agreements

$options = '&S', '&N'
$default = 1  # 0=S, 1=N

do
{
	$response = $Host.UI.PromptForChoice('', 'Já abriu o Windows Terminal, iTunes, AfterBurner e Discord?', $options, $default)
} until ($response -eq 0)

[string]$currentDir = Get-Location
[string]$WTSettings = Resolve-Path ~\AppData\Local\Packages\Microsoft.WindowsTerminalPreview*\LocalState\settings.json

# Make `refreshenv` available right away
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

refreshenv

# Deleta as configurações existentes
Write-Host "Deletando as configurações existentes..." -ForegroundColor Green
Remove-Item $WTSettings -Force
Remove-Item $currentDir'\.ssh' -Recurse -Force

# Extrai chaves SSH
Write-Host "Deletando e extraindo as chaves SSH..." -ForegroundColor Green
7z e $currentDir'\.ssh.zip' -o'.ssh'

# Cria os links simbólicos
Write-Host "Criando os links simbólicos para as configurações..." -ForegroundColor Green
New-Item -ItemType SymbolicLink -Path '~\.ssh' -Target $currentDir'\.ssh'
New-Item -ItemType SymbolicLink -Path '~\.editorconfig' -Target $currentDir'\.editorconfig'
New-Item -ItemType SymbolicLink -Path '~\.gitattributes' -Target $currentDir'\.gitattributes'
New-Item -ItemType SymbolicLink -Path '~\.gitignore' -Target $currentDir'\.gitignore'
New-Item -ItemType SymbolicLink -Path '~\.gitconfig' -Target $currentDir'\.gitconfig'
New-Item -ItemType SymbolicLink -Path '~\.gitconfig_pessoal' -Target $currentDir'\.gitconfig_pessoal'
New-Item -ItemType SymbolicLink -Path '~\.gitconfig_serpro' -Target $currentDir'\.gitconfig'
New-Item -ItemType SymbolicLink -Path '~\.npmrc' -Target $currentDir'\.npmrc'
New-Item -ItemType SymbolicLink -Path '~\.wslconfig' -Target $currentDir'\.wslconfig'
New-Item -ItemType SymbolicLink -Path '~\.yarnrc' -Target $currentDir'\.yarnrc'
New-Item -ItemType SymbolicLink -Path '~\android_dev.ps1' -Target $currentDir'\android_dev.ps1'
New-Item -ItemType SymbolicLink -Path '~\kill_port.ps1' -Target $currentDir'\kill_port.ps1'
New-Item -ItemType SymbolicLink -Path '~\wsl2_network.ps1' -Target $currentDir'\wsl2_network.ps1'
New-Item -ItemType SymbolicLink -Path $WTSettings -Target $currentDir'\Preferences\windows_terminal.json'

# MSI Profiles
Remove-Item 'C:\Program Files (x86)\MSI Afterburner\Profiles\MSIAfterburner.cfg' -Recurse -Force
Remove-Item 'C:\Program Files (x86)\MSI Afterburner\Profiles\Profile1.cfg' -Recurse -Force
New-Item -ItemType SymbolicLink -Path 'C:\Program Files (x86)\MSI Afterburner\Profiles\MSIAfterburner.cfg' -Target $currentDir'\MSIProfiles\MSIAfterburner.cfg'
New-Item -ItemType SymbolicLink -Path 'C:\Program Files (x86)\MSI Afterburner\Profiles\Profile1.cfg' -Target $currentDir'\MSIProfiles\Profile1.cfg'

# Hosts
Write-Host "Criando o link para o arquivo de hosts..." -ForegroundColor Green
Remove-Item 'C:\Windows\System32\drivers\etc\hosts' -Recurse -Force
New-Item -ItemType SymbolicLink -Path 'C:\Windows\System32\drivers\etc\hosts' -Target $currentDir'\.hosts'

# Executa as alterações no registro do Windows
Write-Host "Executando as alterações no registro do Windows..." -ForegroundColor Green
reg import $currentDir'\Windows_Registry\Disable_Snipping_Tool\Disable_Snipping_Tool.reg'
reg import $currentDir'\Windows_Registry\Disable-Bing-in-the-Start-Menu\Disable Bing Searches.reg'
reg import $currentDir'\Windows_Registry\Disable-Cortana\Disable Cortana.reg'
reg import $currentDir'\Windows_Registry\Long-Path-Names-Hacks\Remove 260 Character Path Limit.reg'
reg import $currentDir'\Windows_Registry\NVIDIA Control Panel Language Changer\English_US_400.reg'
reg import $currentDir'\Windows_Registry\PinCCF\unPinCCF.reg'
reg import $currentDir'\Windows_Registry\Remove-3D-Objects-Folder\Remove 3D Objects Folder (64-bit Windows).reg'
reg import $currentDir'\Windows_Registry\Remove-Folders-From-This-PC-on-Windows-10\64-bit versions of Windows 10\Remove All User Folders From This PC 64-bit.reg'
reg import $currentDir'\Windows_Registry\Taskbar Last Active Click Hacks\Enable Last Active Click.reg'
reg import $currentDir'\Windows_Registry\Time Fix - Windows\Windows Universal Time - On.reg'

# Cria link simbolico para backups da Apple
Write-Host "Criando um link simbolico para a pasta de backups Apple..." -ForegroundColor Green
New-Item -Path '~\AppData\Roaming\Apple Computer\MobileSync' -ItemType directory
New-Item -ItemType SymbolicLink -Path '~\AppData\Roaming\Apple Computer\MobileSync\Backup' -Target 'D:\Backups\Apple'

# Perfil do Powershell
Remove-Item 'D:\OneDrive\Documentos\WindowsPowerShell\Microsoft.PowerShell_profile.ps1' -Force
New-Item -ItemType SymbolicLink -Path 'D:\OneDrive\Documentos\WindowsPowerShell\Microsoft.PowerShell_profile.ps1' -Target $currentDir'\Preferences\powershell_profile.ps1'

# Yarn Packages
Write-Host "Instalando os pacotes Yarn..." -ForegroundColor Green
yarn global add react-native-cli cjs-to-es6 create-react-app json-server react react-native @react-native-community/cli diff-so-fancy git-jump expo-cli eslint prettier nodemon local-web-server

# NPM Packages
Write-Host "Instalando os pacotes NPM..." -ForegroundColor Green
npm install -g npm-check @angular/cli npm

# Plugins para discord
Write-Host "Baixando os plugins para o Discord..." -ForegroundColor Green
Write-Host "É necessário instalar manualmente o Discord Better App" -ForegroundColor Yellow
[string]$downloadDir = $env:USERPROFILE+'\AppData\Roaming\BetterDiscord\plugins\'
New-Item -Path $downloadDir -ItemType directory
Invoke-WebRequest -Uri https://raw.githubusercontent.com/1Lighty/BetterDiscordPlugins/master/Plugins/BetterImageViewer/BetterImageViewer.plugin.js -OutFile $downloadDir'\BetterImageViewer.plugin.js'
Invoke-WebRequest -Uri https://raw.githubusercontent.com/1Lighty/BetterDiscordPlugins/master/Plugins/MessageLoggerV2/MessageLoggerV2.plugin.js -OutFile $downloadDir'\MessageLoggerV2.plugin.js'
Invoke-WebRequest -Uri https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Plugins/BetterFriendList/BetterFriendList.plugin.js -OutFile $downloadDir'\BetterFriendList.plugin.js'
Invoke-WebRequest -Uri https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Plugins/BetterSearchPage/BetterSearchPage.plugin.js -OutFile $downloadDir'\BetterSearchPage.plugin.js'
Invoke-WebRequest -Uri https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Plugins/CompleteTimestamps/CompleteTimestamps.plugin.js -OutFile $downloadDir'\CompleteTimestamps.plugin.js'
Invoke-WebRequest -Uri https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Plugins/GameActivityToggle/GameActivityToggle.plugin.js -OutFile $downloadDir'\GameActivityToggle.plugin.js'
Invoke-WebRequest -Uri https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Plugins/ReadAllNotificationsButton/ReadAllNotificationsButton.plugin.js -OutFile $downloadDir'\ReadAllNotificationsButton.plugin.js'
Invoke-WebRequest -Uri https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Plugins/SpotifyControls/SpotifyControls.plugin.js -OutFile $downloadDir'\SpotifyControls.plugin.js'

msiexec /i "D:\Mega\Windows\CorsairHeadset.msi"
D:\Mega\Windows\3uTools_v2.57.031_Setup.exe
D:\Mega\Windows\Battle.net.exe
D:\Mega\Windows\BetterDiscord.exe
D:\Mega\Windows\Bloody7_V2021.0727.exe
D:\Mega\Windows\DeviceRemover.exe
D:\Mega\Windows\EasyWindowSwitcher.exe
D:\Mega\Windows\KasperskyTotalSecurity.exe
D:\Mega\Windows\MSI_Kombustor.exe
D:\Mega\Windows\QTTabBar.exe
D:\Mega\Windows\Sideloadly.exe
D:\Mega\Windows\TeraCopyPro\TeraCopyPro3.6.0.4.exe
