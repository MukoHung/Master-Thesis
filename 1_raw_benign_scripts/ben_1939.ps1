# http://boxstarter.org/package/nr/url?https://gist.githubusercontent.com/fire/8f72f1983b5559bcca0c5d57d5f6b32c/raw/68d7a3735a63ba4b0ed397f188d2e5c29074cc5d/install-new-machine.ps1
# See http://boxstarter.org/Learn/WebLauncher
Set-WindowsExplorerOptions -EnableShowFileExtensions
cinst clink
# Correct time is important
cinst nettime
# Dependency needed for this
cinst chocolatey
cinst ChocolateyGUI
# Web browser
cinst googlechrome
# For ssh acccess
cinst gpg4win
# Reading documents
cinst libreoffice
# Breaking locks
cinst lockhunter
# Reading archives
cinst 7zip
# Video viewer
cinst vlc
# Art tools
cinst krita
# Needed for git offworldcore access
choco install gitextensions
cinst msysgit
cinst git
cinst git.install
# Commonly used for making screenshots
cinst sharex
# Communication software
cinst slack
cinst discord
cinst skype
cinst mumble
# For steam build
cinst steam
# Perforce source control
cinst p4v
# For streaming and debugging
cinst obs
# Enable hyper-v
cinst Microsoft-Hyper-V-All -source windowsFeatures
# Unreal Engine dependencies
cinst vcredist2008
cinst vcredist2010
cinst DotNet4.5.1
cinst epicgameslauncher
cinst visualstudio2017professional -add Component.Unreal --passive --norestart
