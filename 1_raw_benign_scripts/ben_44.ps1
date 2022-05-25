# 0. open a PowerShell as administrator

# 1. Enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 2. Enable VM Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 3. RESTART system, then open a PowerShell as administrator again
# MAKE SURE YOU HAVE RESTARTED BEFORE YOU CONTINUE

# 4. Set WSL 2
wsl --set-default-version 2
# if error: WSL 2 requires an update to its kernel component. For information please visit https://aka.ms/wsl2kernel
# go to the link and install wsl2 kernel

# 5. Install a Linux distribution
# - Open Windows Store, find Ubuntu 20.04, Install
# - Run Ubuntu

# Go to no. 6 in `2.ubuntu-steps.sh`

# 11. Install X server
# - VcXsrv https://sourceforge.net/projects/vcxsrv/ (RECOMMENDED, free)
# - x410 https://x410.dev/ (paid)

# 12. Download, install, launch VcXsrv
# - Pick "Multiple Windows", next
# - Pick "Start No Client", next
# - Check all boxes,  including "Disable access control", finish
# - FIREWALL: allow VcXsrv to access your network

# Go to no. 13 in `2.ubuntu-steps.sh`

