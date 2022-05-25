# http://boxstarter.org/Weblauncher
# https://gist.github.com/racingcow/3e099ee7dc4ad3e4c8ae

# Windows customization/settings
# ==============================

Set-ExplorerOptions -showHidenFilesFoldersDrives -showProtectedOSFiles -showFileExtensions

if (Test-PendingReboot) { Invoke-Reboot }

# Update Windows and reboot if necessary
# ======================================

Install-WindowsUpdate -AcceptEula
 
if (Test-PendingReboot) { Invoke-Reboot }

# Make sure Chocolatey packages that can leverage
# binroot are installed in a common location
# ===============================================

cinst binroot

# General Windows Tools
# =====================

cinst 7zip.install
cinst windirstat
cinst notepadplusplus.install
cinst jing
cinst mousewithoutborders
cinst systraymeter.install

# Web Browsers
# ============

cinst GoogleChrome
cinst Firefox
