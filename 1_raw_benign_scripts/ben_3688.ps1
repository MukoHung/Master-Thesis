Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install notepad2
choco install googlechrome
choco install notepadplusplus
choco install 7zip
choco install paint.net
choco install autoruns

choco install vcredist140
choco install dotnetfx
choco install dotnetcore
choco install scriptcs
choco install jre8
choco install nodejs.install
choco install yarn
choco install python
choco install golang
choco install azure-cli
choco install maven
choco install gradle
choco install docker-cli
choco install p4merge

choco install git
choco install tortoisegit
choco install microsoft-windows-terminal
choco install vscode
choco install visualstudio2019community
choco install resharper-ultimate-all
choco install ncrunch-vs2019
choco install webstorm
choco install openjdk12
choco install intellijidea-ultimate

choco install sysinternals
choco install filezilla
choco install curl
choco install wget
choco install putty
choco install cpu-z
choco install gpu-z
choco install hwmonitor
choco install procmon

choco install slack
choco install discord
choco install sonos-controller
choco install etcher
choco install audacity
choco install audacity-lame
choco install steam
choco install epicgameslauncher
choco install kindle

iwr "https://cdn.porter.sh/latest/install-windows.ps1" -UseBasicParsing | iex