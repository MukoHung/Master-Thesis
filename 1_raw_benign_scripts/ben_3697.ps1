
winget install Google.Chrome
winget install Microsoft.PowerToys
winget install Git.Git
winget install Microsoft.dotnet
winget install OpenJS.NodeJS
winget install EclipseAdoptium.Temurin.17
winget install Microsoft.VisualStudioCode
winget install Docker.DockerDesktop
winget install Postman.Postman
winget install TimKosse.FileZilla.Client
winget install Zoom.Zoom
winget install Discord.Discord
winget install Amazon.AWSCLI
winget install Microsoft.AzureCLI
winget install SlackTechnologies.Slack
winget install Discord.Discord
winget install JanDeDobbeleer.OhMyPosh

Set-ExecutionPolicy RemoteSigned -scope CurrentUser

iwr -useb get.scoop.sh | iex
scoop install starship

Add-Content $Profile "Invoke-Expression (&starship init powershell)"

Install-Module PSWindowsUpdate
Get-WindowsUpdate
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

wsl --install