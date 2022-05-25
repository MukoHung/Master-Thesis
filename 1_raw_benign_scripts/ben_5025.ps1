#
# This script is run at Windows installation time
# It calls other scripts that prepares Windows and makes it ready for Ansible
#
# When run by hand on a new windows machine, use the following commands:
#   wget -Outfile PrepareWindows.ps1 https://raw.githubusercontent.com/ewassink/force/master/PrepareWindows.ps1
#   Set-ExecutionPolicy Bypass -Scope Process -Force; .\PrepareWindows.ps1

cd \windows\temp

# Enable WinRM
wget -Outfile ConfigureRemotingForAnsible.ps1 https://raw.githubusercontent.com/ewassink/force/master/ConfigureRemotingForAnsible.ps1
.\ConfigureRemotingForAnsible.ps1 2>&1 >> PrepareWindows.log

# Install Chocolatey package manager
wget -Outfile InstallChocolatey.ps1  https://raw.githubusercontent.com/ewassink/force/master/InstallChocolatey.ps1
.\InstallChocolatey.ps1 2>&1 >> PrepareWindows.log
