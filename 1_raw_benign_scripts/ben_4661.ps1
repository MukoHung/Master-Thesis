Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install chocolatey -y

choco install git.install -y
choco install git-credential-manager-for-windows -y
choco install github -y
#@choco install git-fork -y

choco install powershell-core -y -install-arguments='"ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 REGISTER_MANIFEST=1 ENABLE_PSREMOTING=1"'
choco install azure-cli -y

choco install wsl2 -y
choco install microsoft-windows-terminal -y
choco install 7zip.install -fy
choco install notepadplusplus
choco install microsoftazurestorageexplorer -y
choco install sysinternals -y
choco install zoomit -y
choco install powerbi -y
choco install sumatrapdf.portable -y
choco install svg-explorer-extension -y
choco install bitwarden -y
#choco install anaconda3 -y
choco install miniconda3 -y

choco install rdcman -y
choco install kdiff3 -y
choco install cpu-z -y
choco install putty -y
choco install drawio -y
choco install filezilla -y

choco install sql-server-management-studio -y
choco install vscode -y
choco install vscode-powershell -y
choco install vscode-settingssync -y
choco install vscode-drawio -y

#choco install azure-data-studio -y

choco install visualstudio2019community -fy --package-parameters "--allWorkloads --includeRecommended --includeOptional --passive --locale en-US" -fy
#choco install visualstudio2017sql -Y
#choco install visualstudio2019enterprise -fy
#choco install visualstudio2019professional --package-parameters "--allWorkloads --includeRecommended --includeOptional --passive --locale en-US" -fy

choco install ssis-vs2019 -y
choco install ssrs-2019 -y


choco install azure-functions-core-tools-3 -y
choco install azurepowershell -Y

choco install daxstudio -y
choco install tabular-editor -y

choco install datagrip -y
choco install dbeaver -y
choco install redshift-odbc -y



#choco install sqlsearch -Y
#choco install sqlsentryplanexplorer -y

#choco install sqltoolbelt -Y


#choco install minikube -y
#choco install kubernetes-helm -y
#choco install kubernetes-cli -y



#choco install treesizefree -y


#choco install microsoft-edge
#choco install googlechrome -y
#choco install microsoft-teams -y
#choco install slack -y

# Media Creations
#choco install vlc -y
#choco install youtube-dlc -y
#choco install obs-studio -y
#choco install obs-ndi -y
#choco install camtasia -y
#choco install snagit -y
#choco install handbrake -y
#choco install streamdeck -y
#choco install audacity -Y
#choco install audacity-lame -Y
#choco install audacity-ffmpeg -Y

#choco install vmware-horizon-client -y
#choco install openconnect-gui -y
