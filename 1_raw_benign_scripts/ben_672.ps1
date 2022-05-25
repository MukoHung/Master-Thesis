Set-ExecutionPolicy RemoteSigned -Force; Set-ExecutionPolicy Unrestricted -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install dotnetcore -y
choco install dotnetcore-sdk -y
choco install webdeploy -y
choco install dotnetfx -y
choco install netfx-4.8 -y
choco install powershell-core -y
choco install azure-cli -y
choco install git -y
choco install sourcetree -y
choco install visualstudio2019buildtools -y
choco install nuget.commandline -y
choco install dacfx-18 -y
choco install docker-desktop -y
Enable-WindowsOptionalFeature -Online -FeatureName containers –All -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V –All -NoRestart
Restart-Computer -Force