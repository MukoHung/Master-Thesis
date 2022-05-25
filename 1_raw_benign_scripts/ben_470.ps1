# Before running this script run: 
# Set-ExecutionPolicy RemoteSigned
# on an elevated powershell console

# Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Boxstarter
iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); get-boxstarter -Force

# Refresh environment variables
RefreshEnv.cmd

# Run boxstarter script
Install-BoxstarterPackage -PackageName https://gist.githubusercontent.com/sgarcesc/279719023e724114db3e42cf8d69c204/raw/f9b660a512a97269ee0f34e0ac082597a0262dc6/package.ps1 -DisableReboots