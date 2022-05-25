# Remove PS Security
set-executionpolicy Unrestricted

# Basic Windows config
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar

# Chocolatey Init
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# Chocolatey Packages
choco install firefox -force --yes
choco install google-chrome-x64  -force --yes
choco install skype -force --yes
choco install notepadplusplus.install -force --yes
choco install git.install -force --yes
choco install fiddler4 -force --yes
choco install sublimetext2 -force --yes
choco install gitextensions -force --yes
choco install spotify -force --yes
choco install filezilla  -force --yes
choco install paint.net  -force --yes
choco install keepass  -force --yes
choco install kdiff3  -force --yes
choco install opera -force --yes
choco install safari -force --yes
choco install nodejs -force --yes
choco install rdcman -force --yes
choco install windirstat -force --yes
choco install putty -force --yes
choco install poshgit -force --yes
cinst 7zip -force --yes
cinst sysinternals -force --yes

choco install slack -force --yes
choco install ilspy -force --yes

cinst logexpert -force --yes
cinst mRemoteNG -force --yes
cinst python3 -force --yes
cinst pip -force --yes
cinst procexp -force --yes
cinst R.Project -force --yes
cinst rufus -force --yes
cinst vlc -force --yes
cinst winscp -force --yes
cinst netscan -force --yes

cinst docker
cinst docker-compose

. $profile

npm install -g cordova ionic bower
gem install sass
