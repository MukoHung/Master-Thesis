$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    
#Chocolatey install script

$testchoco = powershell choco -v
if(-not($testchoco)){
    Write-Output "Installing Chocolatey now"
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
else{
    Write-Output "Chocolatey Version $testchoco is already installed, trying to upgrade chocolatey"
    choco upgrade chocolatey
}

#Install all the packages
# -y confirm yes for any prompt during the install process 

choco install putty -y
choco install openssh -y
choco install git -y
choco install cmder -y # dont forget to add /f and context menu integration
choco install vcredist140 -y
choco install firefox -y #profile
choco install thunderbird -y
choco install keepass -y #config
choco install sumatrapdf -y
choco install 7zip -y #icon
choco install nodejs -y
choco install open-shell -y #config
choco install honeyview -y
choco install discord -y
# choco install steam -y #outdated
choco install youtube-dl -y
choco install wincdemu -y
choco install line -y
choco install qbittorrent -y #config - download path

Write-Output "Finished! Don't forget to upgrade all your app"
}
else {
    Start-Process -FilePath "powershell" -ArgumentList "$('-File ""')$(Get-Location)$('\')$($MyInvocation.MyCommand.Name)$('""')" -Verb runAs
}
