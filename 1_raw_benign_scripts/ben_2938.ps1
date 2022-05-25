#Requires -RunAsAdministrator

# Include Powershell functions, needed for the link function
. .\.powershell\functions.ps1

# TODO: Change assumed "git_repos\dotfiles" path to use scriptDirectory
$Script:DotfilesPowerShell = "${Env:UserProfile}\git_repos\dotfiles\powershell"

# Link the .powershell functions and unique configuration files to home
ln "${Script:DotfilesPowerShell}\.powershell" "${Env:UserProfile}\.powershell"

# Create PowerShell directory if it doesn't already exist
$Script:WindowsPowerShellHome = "${Env:UserProfile}\Documents\WindowsPowerShell"
if (-not (Test-Path $Script:WindowsPowerShellHome)) {
    New-Item -Path $Script:WindowsPowerShellHome -ItemType 'Directory'
}

# Use the same directory for Windows PowerShell and PowerShell Core
$Script:PowerShellCoreHome = "${Env:UserProfile}\Documents\PowerShell"
New-Link -TargetPath $Script:WindowsPowerShellHome -LinkPath $Script:PowerShellCoreHome -LinkType 'Junction'

# If the user's documents directory is not at '~/Documents', link the PowerShell directories into place there too.
# This will be the case if 'Documents' is being backed up to OneDrive.
$Script:MyDocumentsPath = [Environment]::GetFolderPath("MyDocuments")
if ($Script:MyDocumentsPath -ne "${Env:UserProfile}\Documents") {
    New-Link -TargetPath $Script:WindowsPowerShellHome -LinkPath "${Script:MyDocumentsPath}\WindowsPowerShell" -LinkType 'Junction'
    New-Link -TargetPath $Script:PowerShellCoreHome -LinkPath "${Script:MyDocumentsPath}\PowerShell" -LinkType 'Junction'
}

# Link PowerShell profile into place
$Script:PowerShellProfile = "${Script:WindowsPowerShellHome}\Microsoft.PowerShell_profile.ps1"
New-Link -TargetPath "${Script:DotfilesPowerShell}\profile.ps1" -LinkPath $Script:PowerShellProfile -LinkType 'SymbolicLink'
