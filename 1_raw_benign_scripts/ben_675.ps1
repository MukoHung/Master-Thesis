[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install chocolatey -y
choco install sql-server-management-studio -y
choco install azure-data-studio -y
choco install git.install -y
choco install vscode -y
choco install powershell-core -y -install-arguments='"ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 REGISTER_MANIFEST=1 ENABLE_PSREMOTING=1"'
choco install wsl2 -y
choco install handbrake -y

choco install snagit -y
choco install vscode-powershell -y
choco install vscode-settingssync -y
choco install powerbi -y
choco install mobaxterm -y
choco install docker-desktop -y

choco install docker-compose -y
choco install docker-cli -y
choco install microsoft-windows-terminal -y

choco install 1password -y
choco install sqlsearch -Y
choco install sqlsentryplanexplorer -y
choco install git-fork -y
choco install visualstudio2017sql -Y
choco install visualstudio2017enterprise -y
choco install visualstudio2019enterprise -y
# choco install googlechrome -y
choco install sysinternals -y
choco install sqltoolbelt -Y
choco install microsoft-teams -y
choco install slack -y
choco install minikube -y
choco install kubernetes-helm -y
choco install kubernetes-cli -y
choco install microsoftazurestorageexplorer -y
choco install vlc -y
choco install cpu-z -y
choco install treesizefree -y
choco install azure-cli -y
## choco install poshgit -y ## Now I need the pre-release for the prompt
choco install git-credential-manager-for-windows -y
choco install rdcman -y


choco install logitech-presentation -y
choco install logitech-options -y

choco install powershell-core --install-arguments='"ADD\_EXPLORER\_CONTEXT\_MENU\_OPENPOWERSHELL=1 "ENABLE\_PSREMOTING=1"' 
choco install microsoft-windows-terminal

choco install microsoft-edge-insider-dev
