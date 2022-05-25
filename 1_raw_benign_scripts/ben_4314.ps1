Set-ExecutionPolicy Unrestricted

if (Get-Command choco -errorAction SilentlyContinue)
{
    Write-Host "Chocolatey gefunden..."
}else{
	Write-Host "Chocolatey wird installiert..."
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))  
	Write-Host "...installation abgeschlossen!"  
}

Write-Host "Pakete werden installiert..."

choco install -y 7zip
choco install -y adblockpluschrome
choco install -y adobereader
choco install -y git
choco install -y gitextensions
choco install -y javaruntime
choco install -y jdk8
choco install -y jre8
choco install -y nodejs
choco install -y notepadplusplus
choco install -y visualstudiocode
choco install -y windirstat
choco install -y meld
choco install -y everything
choco install -y ccleaner