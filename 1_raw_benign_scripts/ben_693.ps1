### PowerShell script to install a minimal Workstation with Chocolatey
# https://chocolatey.org

## To Run This Script:
# 1. Download this PowerShell script
#    * Right-click <> ("View Raw") and "Save As" to %USERPROFILE% (/Users/<username>)
#    * If Cocolatey is not already installed, see
#      "Uncomment to install Chocolatey"
#    * If you would like to also install Anaconda
#      (Python, IPython, lots of great libraries)
#      * Scroll down to "Uncomment to install Anaconda (Python)"
#      * Check for the latest download .exe or .zip link at ./downloads
#      * Uncomment the two lines for your platform (x86 or x86_64)
# 2. Open a Command Prompt
#    * Press 'Windows-R' (Run Command); Type `cmd`; Press <Enter>
# 3. Run this PowerShell Script
#    * Type the following command:
#      @powershell -NoExit -NoProfile -ExecutionPolicy Bypass -File .\cinst_workstation_minimal.ps1

## Uncomment to install Chocolatey
# @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin

# https://http://chocolatey.org/packages/<name>

cinst GnuWin
#cint Gow
cinst sysinternals
cinst 7zip
cinst curl
cinst ConsoleZ
#cinst windbg
#cinst windirstat
#cinst Logrotate

#cinst driverbooster
#cinst drivergenius
#cinst dumo

#cinst MicrosoftSecurityEssentials
#cinst avastfreeantivirus
#cinst avgantivirusfree
#cinst bitdefenderavfree
#cinst clamwin
#cinst f-secureav
#cinst kav

# http://www.visualstudio.com/en-us/products/visual-studio-express-vs.aspx
cinst notepadplusplus
#cinst vim
cinst KickAssVim

cinst hg
#cinst tortoisehg
cinst git
#cinst TortoiseGit
#cinst svn
#cinst Tortoisesvn

cinst putty
cinst kitty.portable
cinst winscp

cinst spybot
cinst ccleaner
cinst ccenhancer
#cinst sumo
#cinst Secunia.PSI
#cinst adwcleaner
#cinst jrt

cinst vlc
#cinst camstudio

cinst Firefox
cinst GoogleChrome
#cinst Opera

cinst flashplayerplugin
#cinst flashplayeractivex
#cinst javaruntime

#cinst skype
#cinst pidgin
#cinst miranda
#cinst mirc

#cinst gimp
#cinst paint.net
#cinst inkscape
#cinst freecad

#cinst stellarium

#cinst blender
#cinst avidemux
#cinst handbrake

#cinst mixx
#cinst vvvv
#cinst vvvv-addonpack

#cinst clementine
#cinst iTunes
#cinst spotify
#cinst plexmediaserver
#cinst plex-home-theater

cinst FoxitReader
cinst adobereader

#cinst libreoffice

#cinst zotero-standalone
#cinst anki
#cinst PDFCreator
#cinst gnucash

#cinst thunderbird

#cinst dropbox
#cinst googledrive

#cinst puppet
#cinst mcollective
#cinst saltminion # /master=yoursaltmaster /minion-name=yourminionname

#cinst logstash

#cinst unetbootin
#cinst yumi
#cinst cdburnerxp
#cinst wudt
#cinst WinImage
#cinst ext2explore
#cinst ext2fsd

#cinst packer
#cinst vagrant
#cinst virtualbox


### Uncomment to install Anaconda (Python)
# 1. http://continuum.io/downloads
# 2. http://docs.continuum.io/anaconda/install.html#windows-install

## x86_64
#curl -O http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.2-Windows-x86_64.exe
#.\Anaconda-1.9.2-Windows-x86_64.exe /S /D=C:\Anaconda

## x86
#curl -O http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.2-Windows-x86.exe
#.\Anaconda-1.9.2-Windows-x86.exe /S /D=C:\Anaconda