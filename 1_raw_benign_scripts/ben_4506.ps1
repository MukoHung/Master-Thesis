iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
cinst powershell -y
cinst SublimeText3 -y
cinst git -y
cinst TortoiseGit -y 
cinst svn -y 
cinst TortoiseSVN -y 
cinst nodejs.install

npm install -g rimraf 
npm install -g grunt-cli 

Install-WindowsFeature Web-Server -IncludeAllSubfeature -IncludeManagementTools
Install-WindowsFeature MSMQ -IncludeAllSubfeature -IncludeManagementTools
Install-WindowsFeature NET-Framework-45-ASPNET
Install-WindowsFeature Web-Asp-Net45
Restart-Computer -Force 