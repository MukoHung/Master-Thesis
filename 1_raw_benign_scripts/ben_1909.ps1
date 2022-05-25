

# Determine OS
if ($IsWindows) {
    New-Item -ItemType Directory -Force -Path "$HOME\Documents\PowerShell"

    # Setup for PowerShell 7 on macOS
    New-Item -ItemType SymbolicLink -Path "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Value "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"
    New-Item -ItemType SymbolicLink -Path "$HOME\Documents\PowerShell\alias.ps1" -Value "$PSScriptRoot\alias.ps1"
    New-Item -ItemType SymbolicLink -Path "$HOME\Documents\PowerShell\azure.ps1" -Value "$PSScriptRoot\azure.ps1"
    New-Item -ItemType SymbolicLink -Path "$HOME\Documents\PowerShell\profile.windows.ps1" -Value "$PSScriptRoot\profile.windows.ps1"

    if (Test-Path "$PSScriptRoot\profile.secrets.ps1") {
        New-Item -ItemType SymbolicLink -Path "$HOME\Documents\PowerShell\profile.secrets.ps1" -Value "$PSScriptRoot\profile.secrets.ps1"
    }
}
elseif ($IsMacOS) {
    # Setup for PowerShell 7 on macOS
    New-Item -ItemType SymbolicLink -Path "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1" -Value "$PSScriptRoot/Microsoft.PowerShell_profile.ps1"
    New-Item -ItemType SymbolicLink -Path "$HOME/.config/powershell/alias.ps1" -Value "$PSScriptRoot/alias.ps1"
    New-Item -ItemType SymbolicLink -Path "$HOME/.config/powershell/azure.ps1" -Value "$PSScriptRoot/azure.ps1"
    New-Item -ItemType SymbolicLink -Path "$HOME/.config/powershell/profile.macos.ps1" -Value "$PSScriptRoot/profile.macos.ps1"

    if (Test-Path "$PSScriptRoot\profile.secrets.ps1") {
        New-Item -ItemType SymbolicLink -Path "$HOME/.config/powershell/profile.secrets.ps1" -Value "$PSScriptRoot/profile.secrets.ps1"
    }
}
else {
    Write-Output "OS Setup Not Implemented";
}


