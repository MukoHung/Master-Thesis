#####################
# REQUISITOS
#####################

Set-ExplorerOptions -showHiddenFilesFoldersDrives -showProtectedOSFiles -showFileExtensions
Set-TaskbarSmall

# Powershell
cinst PowerShell
cinst poshgit

#####################
# Programas
#####################

# 7Zip
cinst 7zip.install

# Algunos browsers
cinst GoogleChrome
cinst chromium
cinst brave
cinst firefox
cinst firefox-dev --pre 
cinst Opera
cinst microsoft-edge-insider
cinst microsoft-edge-insider-dev


#Plugins
cinst javaruntime

# Otras Herramientas
cinst steam
cinst twitch --ignore-checksums

# Herramientas de desarrolador
cinst git.install
cinst nvm
cinst cascadiacode
cinst vscode
cinst vscode-insiders
cinst gitkraken
cinst github-desktop
cinst postman
cinst fiddler
cinst microsoft-windows-terminal
cinst teamviewer
cinst azure-cli

# Mensajeria
cinst discord
cinst slack
cinst whatsapp
cinst telegram
cinst microsoft-teams
cinst skype

# Herramientas
cinst foxitreader
cinst vlc
cinst ccleaner

# Herramientas de diseño
cinst paint.net

# Herramientas de Audio
cinst audacity
cinst lightworks
cinst screentogif
cinst spotify --ignore-checksums