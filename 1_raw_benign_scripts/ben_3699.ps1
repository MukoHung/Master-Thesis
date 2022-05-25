Write-Host "Disabling UAC"
Set-ItemProperty -Path “HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System” -Name “EnableLUA” -Value “0”
Write-Host

Write-Host "Installing Chocolatey and applications"
iex ((new-object net.webclient).DownloadString('http://bit.ly/psChocInstall'))
Write-Host

Write-Host "Installing applications from Chocolatey"
cinst googlechrome -y
cinst cpu-z -y
cinst battle.net -y
cinst steam -y
cinst cygwin -y
cinst vlc -y
cinst atom -y
Write-Host
