Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install dotnetcore-sdk -y
choco install 7zip.install -y
choco install googlechrome -y
choco install sourcetree -y
choco install git.install -y
choco install visualstudiocode -y

shutdown /r /t 1

.