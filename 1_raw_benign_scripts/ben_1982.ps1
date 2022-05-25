# browsers
choco install -y firefox
choco install -y googlechrome

# utils
choco install -y 7zip.install
choco install -y conemu
choco install -y ditto
choco install -y greenshot
choco install -y adobereader
choco install -y vlc
choco install -y youtube-dl
choco install -y aria2
choco install -y ffmpeg
choco install -y keepass.install
choco install -y rufus
choco install -y irfanview
choco install -y teracopy
choco install -y foxitreader --ia '/MERGETASKS="!desktopicon,!setdefaultreader,!displayinbrowser /COMPONENTS=*pdfviewer,*ffse,*installprint,*ffaddin,*ffspellcheck,!connectedpdf"'
choco install -y advanced-renamer.install

# chocolatey packages creation
choco install -y ussf
choco install -y checksum

# wsl
choco install -y wsl 
choco install wsl-ubuntu-1804

# development
## general
choco install -y nodejs
choco install -y git
choco install -y firacode 
choco install -y cascadiacodepl
choco install -y cascadiacode
choco install -y postman
choco install -y git-fork
choco install -y powershell-preview
choco install -y sql-server-management-studio
## vscode
choco install -y vscode

## visual studio 2017 community
choco install -y visualstudio2017community 
### visual studio 2017 workloads
choco install visualstudio2017-workload-azure
choco install visualstudio2017-workload-manageddesktop
choco install visualstudio2017-workload-data
choco install visualstudio2017-workload-netcoretools
choco install visualstudio2017-workload-netcrossplat
choco install visualstudio2017-workload-netweb
choco install visualstudio2017-workload-node
choco install visualstudio2017-workload-universal

## scala 
choco install jdk8
choco install sbt
choco install intellijidea-community

