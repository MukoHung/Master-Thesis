#INSTALL CHOCOLATEY: https://chocolatey.org/docs/installation
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Install GIT FORK: https://chocolatey.org/packages/git-fork
choco install git-fork -y

#Install Visual Studio: https://chocolatey.org/packages?q=visual+studio+2019
choco install visualstudio2019enterprise -y

#Install Visual Studio Code: https://chocolatey.org/packages/vscode
choco install vscode -y

#Install Beyond Compare: https://chocolatey.org/packages/beyondcompare
choco install beyondcompare -y

#Install Visual Studio 2017 Build tools: https://chocolatey.org/packages/visualstudio2017buildtools
choco install visualstudio2017buildtools -y

#Install SQL Server: https://chocolatey.org/packages/sql-server-express
choco install sql-server-express -y

#Install SQL Server Management Studio: https://chocolatey.org/packages/sql-server-management-studio
choco install ssms -y

#Install Google Chrome:
choco install googlechrome -y

#Install 7zip:
choco install 7zip.install -y

