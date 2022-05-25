$ErrorActionPreference = "Stop"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

$webClient = New-Object System.Net.WebClient
$webClient.Headers['User-Agent'] = 'AutomaticWindowsSetup'

cp .\StartMenuLayout.xml "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"
Invoke-Item .\WindowsTheme.theme

regedit /s Explorer.reg
regedit /s StartMenu.reg
regedit /s StartMenuLayout.reg
regedit /s Taskbar.reg
regedit /s WindowsTheme.reg
Invoke-Expression .\fix_start_menu_tile_accent.ps1
Start-Process "$env:WINDIR\system32\SystemPropertiesPerformance.exe"

Invoke-Expression .\update_wsl.ps1
Invoke-Expression .\install_winget.ps1
winget install --exact --id Canonical.Ubuntu
winget install --exact --id Microsoft.WindowsTerminal
winget install --exact --id Microsoft.dotnet
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
dotnet tool install -g dotnet-script
Start-Process (where.exe ubuntu*.exe) "run ""exit""" -Wait
Start-Process (where.exe wt.exe) exit.bat -Wait
Invoke-Expression .\remap_terminal_hotkeys.ps1
Invoke-Expression .\set_default_shell_as_ubuntu.ps1
Invoke-Expression .\merge_terminal_settings.ps1

winget install --exact --id Docker.DockerDesktop
Invoke-Expression .\install_visualstudio.ps1
winget install --exact --id Microsoft.VisualStudioCode
Invoke-Expression .\fix_visualstudio_newline_settings.ps1

Invoke-Expression $webClient.DownloadString('https://chocolatey.org/install.ps1')

. (where.exe ubuntu*.exe) run "./setup_linux.sh"

regedit /s RDP.reg
regedit /s GameDVR.reg
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Invoke-Expression .\mount_wsl_drive.ps1
