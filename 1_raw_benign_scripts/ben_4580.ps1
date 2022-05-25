# Create directory for scripts
if (-not (Test-Path "$PSScriptRoot\functions")) {
    New-Item -Path "$PSScriptRoot" -Name "functions" -ItemType "Directory"
}

# Get neeeded files
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/functions.ps1' -OutFile "$PSScriptRoot\functions\functions.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/configure_app_privacy.ps1' -OutFile "$PSScriptRoot\functions\configure_app_privacy.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/configure_firewall.ps1' -OutFile "$PSScriptRoot\functions\configure_firewall.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/configure_ntp.ps1' -OutFile "$PSScriptRoot\functions\configure_ntp.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/disable_cortana.ps1' -OutFile "$PSScriptRoot\functions\disable_cortana.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/disable_telemetry.ps1' -OutFile "$PSScriptRoot\functions\disable_telemetry.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/enable_controlled_folder_access.ps1' -OutFile "$PSScriptRoot\functions\enable_controlled_folder_access.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/install_applications.ps1' -OutFile "$PSScriptRoot\functions\install_applications.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/remove_default_apps.ps1' -OutFile "$PSScriptRoot\functions\remove_default_apps.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/env_example.ps1' -OutFile "$PSScriptRoot\functions\env_example.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/configure_user.ps1' -OutFile "$PSScriptRoot\functions\configure_user.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/configure_windows_10_admin.ps1' -OutFile "$PSScriptRoot\functions\configure_windows_10_admin.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/configure_windows_10.ps1' -OutFile "$PSScriptRoot\functions\configure_windows_10.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/install_applications_admin.ps1' -OutFile "$PSScriptRoot\functions\install_applications_admin.ps1"
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/Windows-10-Configuration/stable/windows_scripts/functions/windows_10_uac.ps1' -OutFile "$PSScriptRoot\functions\windows_10_uac.ps1"

if (-not (Test-Path "$PSScriptRoot\functions\env.ps1")) {
    Read-Host 'Variables stored in env.ps1 is not setup, create an env.ps1 file in the functions folder. An example is in the functions folder. '
    exit
}

# Start scripts
. "$PSScriptRoot\functions\windows_10_uac.ps1"
