ECHO Installing Apps

ECHO Configure Chocolatey
choco feature enable -n allowGlobalConfirmation

# System Apps

## Browsers
choco install googlechrome
choco install firefox

## Misc
choco install keepassxc
choco install 7zip
choco install deluge

## Work
choco install libreoffice
choco install adobereader

# Dev Apps
choco install php
choco install composer
choco install virtualbox
choco install vagrant
choco install visualstudiocode
choco install phpstorm
choco install bitvise-ssh-client

## Vagrant Plugins
refreshenv # Refresh the env. variables to access vagrant
vagrant plugin install vagrant-hostsupdater

## Git
choco install git
choco install gitkraken
choco install smartgit

# Games
choco install steam

choco feature disable -n allowGlobalConfirmation

# Customize PowerShell

## Install Scoop
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

## Install concfg and import the Solarized theme
scoop install concfg
concfg import solarized

## Install Pshazz
scoop install pshazz