# Install Boxstarter and Chocolatey
Set-ExecutionPolicy -ExecutionPolicy "RemoteSigned" -Verbose
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force

# Set Explorer options
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar -DisableOpenFileExplorerToQuickAccess -DisableShowRecentFilesInQuickAccess -DisableShowFrequentFoldersInQuickAccess -DisableExpandToOpenFolder -DisableShowRibbon

# Set Taskbar options
Set-TaskbarOptions -Size Large -Lock -Dock Bottom -Combine Always

# Run Chocolatey script in this GIST
Install-BoxstarterPackage -PackageName https://gist.githubusercontent.com/adamrushuk/0ebd813368796e6a0554c2c3891490fd/raw/21fceea5ecbed786986a8c3d986e93136d5f8c77/02-Chocolatey.ps1 -DisableReboots
