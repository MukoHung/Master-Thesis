# ==========================================================================
# 
# 	Script Name:  	Install-ProgramsForWindows10.ps1
# 
# 	Author:         Andy Parkhill
# 
# 	Date Created:   22/09/2016
# 
# 	Description:    A simple environment setup script for Windows 10 PCs.
#
# =========================================================================


# ==========================================================================
# 	Imported Modules
# ==========================================================================


# ==========================================================================
# 	Constants
# ==========================================================================
Set-Variable ScriptName -option Constant -value "Install-ProgramsForWindows10.ps1"


# ==========================================================================
# 	Functions
# ==========================================================================


# ==========================================================================
#	Main Script Body
# ==========================================================================

Write-Host "Opening $ScriptName Script."

# ==========================================================================
#	Start of Script Body
# ==========================================================================


# Install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))


# Install Utilities 
choco install -y notepadplusplus.install
choco install -y greenshot
choco install -y launchy
choco install -y bleachbit.install
choco install -y 7zip.install
choco install -y windirstat
choco install -y wincdemu
choco install -y keepass.install
# choco install -y Revo.Uninstaller.install
choco install -y f.lux.install
choco install -y adobereader 
choco install -y fastcopy.install
# choco install -y cdburnerxp
# choco install -y tomighty
choco install -y itunes 
choco install -y bingdesktop 
choco install -y cobian-backup 
choco install -y vlc


# Install Browsers
choco install -y Firefox 
# choco install -y GoogleChrome
# choco install -y chromium
choco install -y brave 
# choco install -y safari -version 5.1.7.1 
choco install -y vivaldi

# Install Office Software
choco install -y libreoffice
choco install -y skype 
choco install -y markdownpad2

# Install Developer Tools
choco install -y fiddler
choco install -y winmerge
choco install -y visualstudiocode 
# choco install -y sysinternals  # Install in the tools folder
# choco install -y webpi # Web Platform installer
choco install -y gitextensions
choco install -y ilspy
choco install -y softerraldapbrowser 
# CMD Tools - Conemu/Cmder/Hyper?
# choco install -y conemu
# choco install -y cmder # Or cmdermini
# choco install -y hyper 

# ==========================================================================
#	End of Script Body
# ==========================================================================

Write-Host "Closing $ScriptName Script."

# Read-Host -Prompt "Press Enter to exit"