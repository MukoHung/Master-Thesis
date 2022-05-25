Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install 7zip brave compact-timer cura-new deno epicgameslauncher ffmpeg firacode foobar2000 git github-desktop goggalaxy itch jre8 libreoffice julia microsoft-windows-terminal nodejs openscad steam uplay vlc vscode