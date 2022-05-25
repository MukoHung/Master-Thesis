### Base Windows Configuration ###

# Enable Windows Features...
Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online -NoRestart
Enable-WindowsOptionalFeature -FeatureName Containers -Online -NoRestart
Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart

### Chocolatey Installs ###

# Install Chocolatey: https://chocolatey.org/install
Set-ExecutionPolicy AllSigned; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Enable Chocolatey Autoconfirm
choco feature enable -n allowGlobalConfirmation

# Install Boxstarter: http://boxstarter.org/InstallBoxstarter
cinst -y boxstarter

# Development Tools
cinst -y 7zip
cinst -y dotnetcore
cinst -y git --params="/WindowsTerminal /NoShellIntegration"
cinst -y GoogleChrome
cinst -y nodejs
cinst -y nuget.commandline
cinst -y poshgit
# cinst -y visualstudio2017-workload-netcoretools
# cinst -y visualstudio2017-workload-vctools
cinst -y yarn

# Development Tools - Visual Studio Code
cinst -y visualstudiocode
cinst -y vscode-powershell
cinst -y vscode-gitlens
cinst -y vscode-editorconfig
cinst -y vscode-csharp

# Utilities
cinst -y adb
cinst -y everything
cinst -y filezilla
cinst -y notepad3
cinst -y notepadplusplus
cinst -y paint.net
cinst -y pandoc
cinst -y rufus
cinst -y snagit
cinst -y sudo
cinst -y sysinternals
cinst -y windirstat

# Utilities (Optional)
# cinst -y clipdiary
# cinst -y icaros
# cinst -y rescuetime
# cinst -y snagit
# cinst -y sizer
# cinst -y winaero-tweaker

# Fonts
cinst -y firacode
cinst -y inconsolata
cinst -y hackfont

# Color Theme
cinst -y colortool
refreshenv
colortool -b campbell

# Boxstarter Configuration Commands (gcm -module Boxstarter.WinConfig)
Set-WindowsExplorerOptions -EnableShowFileExtensions -DisableOpenFileExplorerToQuickAccess -DisableShowFrequentFoldersInQuickAccess -DisableShowRecentFilesInQuickAccess
Disable-BingSearch
Disable-GameBarTips
Enable-RemoteDesktop