Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install git
choco install googlechrome
choco install notepadplusplus
choco install adobereader
choco install 7zip
choco install vlc
choco install nodejs
choco install paint.net
choco install dotnetcore-sdk
choco install dotnetcore-sdk --version=2.1.300
choco install azure-cli
choco install slack
choco install spotify
choco install postman
choco install google-drive-file-stream
choco install docker-for-windows --version=1.12.1
choco install azure-functions-core-tools
choco install vscode
choco install visualstudio2019enterprise
choco feature disable -n allowGlobalConfirmation
code --install-extension msjsdiag.debugger-for-chrome
code --install-extension ms-vscode.azurecli
code --install-extension ms-vscode.powershell
code --install-extension ms-vscode.csharp
code --install-extension ms-vscode.docker
code --install-extension donjayamanne.githistory
code --install-extension GitHub.vscode-pull-request-github
code --install-extension marp-team.marp-vscode
code --install-extension msazurermtools.azurerm-vscode-tools
code --install-extension evilz.vscode-reveal
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension ms-azuretools.vscode-azurefunctions