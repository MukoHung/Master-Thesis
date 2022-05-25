# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Script to confgure settings in Windows 10

# Source Functions
. "$PSScriptRoot\env.ps1"
. "$PSScriptRoot\functions.ps1"
. "$PSScriptRoot\configure_app_privacy.ps1"
. "$PSScriptRoot\configure_firewall.ps1"
. "$PSScriptRoot\configure_ntp.ps1"
. "$PSScriptRoot\disable_cortana.ps1"
. "$PSScriptRoot\disable_telemetry.ps1"
. "$PSScriptRoot\enable_controlled_folder_access.ps1"
. "$PSScriptRoot\install_applications.ps1"
. "$PSScriptRoot\install_applications_admin.ps1"
. "$PSScriptRoot\remove_default_apps.ps1"
. "$PSScriptRoot\configure_user.ps1"

function InteractiveMenu {
    function Show-Menu {
        param (
            [string]$Title = 'Configuration Options'
        )
        Clear-Host
        Write-Host "================ $Title ================"

        Write-Host "1: Press '1' to map network drives."
        Write-Host "14: Press '2' to install applications."
        Write-Host "q: Press 'q' to quit."
    }
    do {
        Show-Menu
        $selection = Read-Host "Select an option"
        switch ($selection) {
            '1' {
                MapDrives
            }
            '2' {
                InstallApplications
            }
        }
        Pause
    }
    until ($selection -eq 'q')
}

# Call functions
InteractiveMenu
