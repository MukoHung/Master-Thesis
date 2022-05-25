## run 'powershell -File choco_install_apps.ps1'
## open cmd as Admin!

## install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

## install apps

# configure chocolatey
choco feature enable -n allowGlobalConfirmation

# test
choco install totalcommander
choco install windirstats

# dev
choco install git
choco install vscode

# r
choco install r
choco install r.studio
choco install rtools

# db
choco install mongodb

# imagery
choco install irfanview
choco install imagemagick
choco install greenshot

# teams
choco install microsoft-teams

# configure chocolatey
choco feature disable -n allowGlobalConfirmation

# copy settings files total commander
copy q:\Teams\Afdelingen\522.10\tools\sandbox\Tom\wincmd.ini c:\Users\steit1\AppData\Roaming\GHISLER\wincmd.ini
copy q:\Teams\Afdelingen\522.10\tools\sandbox\Tom\usercmd.ini c:\Users\steit1\AppData\Roaming\GHISLER\usercmd.ini
