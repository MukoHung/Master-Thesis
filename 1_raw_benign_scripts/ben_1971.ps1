<#
.SYNOPSIS
Installer/Upgrade Script for Windows Home PC

.DESCRIPTION
This script installs and upgrades applications and utilities for a Windows home PC

.EXAMPLE
.\Install-WindowsBox.ps1

.LINK
https://github.com/michaeloa/windows-box
#>

Write-Verbose "Installing Windows Box..."
# Define Utility functions
Set-ExecutionPolicy Bypass -Scope Process -Force
. .\libs\Set-TempDirectory
. .\libs\Get-UserSID
# Install Chocolatey
.\scripts\Install-Chocolatey.ps1
# Configure Windows
.\scripts\Configure-Windows.ps1
# Run Scripts
.\scripts\Remove-DefaultApps.ps1
.\scripts\Install-CommonApps.ps1
# Supplementary Packages
if (test-path .\Install-PrivateApps.ps1) {
    .\Install-PrivateApps.ps1
}
