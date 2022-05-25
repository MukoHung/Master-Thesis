# Windows settings
# TODO: Add Win10 bloatware cleanup 
# Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar -EnableOpenFileExplorerToQuickAccess
# Set-TaskbarOptions -Size Large -UnLock -Dock Bottom -Combine Never -AlwaysShowIconsOn
# Enable-RemoteDesktop
# Disable-GameBarTips
# Disable-BingSearch
# Install-WindowsUpdate

# Chocolatey Packages
# Libraries
cinst dotnetfx
cinst dotnetcore-sdk
cinst powershell
cinst openjdk
cinst jre8
cinst python
cinst openssh
cinst llvm
cinst cygwin
cinst msys2
cinst ffmpeg

# ISO Utilities

cinst wincdemu
cinst rufus

# Network Tools
cinst angryip
cinst wireshark
cinst nmap
cinst winscp

# System Management Tools
cinst putty.install
cinst sysinternals
cinst veracrypt
#cinst nxlog

# Desktop utilities
cinst 7zip.install
cinst everything
cinst speccy
cinst unchecky
cinst teracopy
cinst bulk-crap-uninstaller
cinst adobereader
cinst calibre
cinst telegram.install
cinst f.lux
cinst imageglass

# Media tools
cinst vlc
cinst k-litecodecpackfull
gom-player

# Browsers
cinst googlechrome
cinst firefox

#Development Tools
cinst cmder
cinst git.install
cinst git-lfs
cinst git-credential-manager-for-windows
cinst sublimetext3
cinst vscode
cinst visualstudio2017community
cinst sql-server-management-studio
#cinst dotpeek
#cinst vagrant
#cinst vault
#cinst docker