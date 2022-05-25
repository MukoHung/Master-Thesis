# powershell

# install choco
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco -V

# install compression
choco install 7zip bandizip -y

# install brosers
choco install googlechrome -y

# Process management tool
choco install processhacker python3 -y

# install language
choco install python3 -y

# install redistributable package
choco install vcredist-all -y --install-arguments='/install /Q /norestart'

refreshenv

# taskbar - hide search box
New-ItemProperty -LiteralPath 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -PropertyType "DWORD" -Value "1" -Force

# tasbar -> Combine buttons Never
New-ItemProperty -LiteralPath 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarGlomLevel' -PropertyType "DWORD" -Value "2" -Force

# folder option -> Quick Access = ThisPC
New-ItemProperty -LiteralPath 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -PropertyType "DWORD" -Value "1" -Force

# folder option -> Show system file
New-ItemProperty -LiteralPath 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowSuperHidden' -PropertyType "DWORD" -Value "1" -Force

# folder option -> Show hidden file
New-ItemProperty -LiteralPath 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -PropertyType "DWORD" -Value "1" -Force

# folder option -> show extension
New-ItemProperty -LiteralPath 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -PropertyType "DWORD" -Value "1" -Force

# apply and restart
Stop-Process -ProcessName explorer

Write-Host "Installation is complete."
