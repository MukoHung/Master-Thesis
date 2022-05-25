<#
.SYNOPSIS
    Removes and tames most of the Windows 11 Bloatware
.DESCRIPTION
    This script removes most of the bloatware that is shipped with Windows 11, including useless
    services, app packages and tracking programs.
.NOTES
    File Name : Windows11Debloat.ps1
    Author    : Dave
.LINK
    https://github.com/det-builder/scripts/blob/master/Windows11Debloat.ps1
#>

# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force;
# Set-ExecutionPolicy RemoteSigned
# Get-AppxPackage | select-Object -Property Name
# https://docs.microsoft.com/en-us/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services
# https://github.com/TheWorldOfPC/Windows11-Debloat-Privacy-Guide/blob/main/README.md
# https://github.com/teeotsa/windows-11-debloat/blob/main/win11debloat.ps1
# https://github.com/simeononsecurity/Windows-Optimize-Harden-Debloat/blob/master/sos-optimize-windows.ps1
# https://github.com/timwelchnz/windows10debloat/blob/main/AllInOneProgramRemoval.ps1
# https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/optimize-user-interface.ps1
# https://docs.microsoft.com/en-us/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services
# https://github.com/microsoft/winget-pkgs/tree/master/manifests

# DT - Must be running this script as an admin or elevated UAC.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Output ""
    Write-Output "ERROR!  You must run this script as an administrator!  Exiting..."
    Write-Output ""
	Exit
}

# DT - This function will restart Windows Explorer to ensure changes are reflected.
function RestartWindowsExplorer
{
    Stop-Process -Name "explorer" -Force -PassThru -ErrorAction SilentlyContinue | Out-Null
    Start-Sleep -Seconds 2
    if (!(Get-Process -Name "explorer")){
        Start-Process -FilePath "explorer"  | Out-Null
    }
}

# DT - Privacy & Security -> Diagnostics & Feedback
Start-Job -Name "Privacy_Security_Feedback" -ScriptBlock {

    # Privacy & Security -> Diagnostics & Feedback -> Diagnostic Data.  This section disables all voluntary diagnostic data.
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows'
    Set-ItemProperty $key -Name "AllowTelemetry" -Value 0 -Type "DWORD"
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
    set-ItemProperty $key -Name "AllowTelemetry" -Value 0 -Type "DWORD"
    $key = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
    set-ItemProperty $key -Name "AllowTelemetry" -Value 0 -Type "DWORD"
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
    set-ItemProperty $key -Name "AllowTelemetry" -Value 0 -Type "DWORD"
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat'
    if (!(Test-Path $key)) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "AppCompat"
    }
    set-ItemProperty $key -Name AITEnable -Value 0 -Type "DWORD"

    # Improve inking and typing
    $key = 'HKCU:\SOFTWARE\Microsoft\InputPersonalization'
    if (!(Test-Path $key)) {
        New-Item -Path $key -Force | Out-Null
    }
    Set-ItemProperty -Path $key -Name "RestrictImplicitTextCollection" -Type "DWORD" -Value 1
    Set-ItemProperty -Path $key -Name "RestrictImplicitInkCollection" -Type "DWORD" -Value 1

    # Tailored Experiences
    $key = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy'
    if (!(Test-Path $key)) {
        New-Item -Path $key -Force | Out-Null
    }
    Set-ItemProperty $key -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type "DWORD"


}

# DT - Privacy & Security -> Activity History
Start-Job -Name "Privacy_Security_Activity" -ScriptBlock {

    # DT - Disable activity history
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    Set-ItemProperty -Path $key -Name "EnableActivityFeed" -Type "DWORD" -Value 0
    Set-ItemProperty -Path $key -Name "PublishUserActivities" -Type "DWORD" -Value 0
    Set-ItemProperty -Path $key -Name "UploadUserActivities" -Type "DWORD" -Value 0

}

# DT - Privacy & Security -> Search Permissions
Start-Job -Name "Privacy_Security_Search" -ScriptBlock {

    $key = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings'
    If (!(Test-Path $key)) {
        New-Item -Path $key -Force | Out-Null
    }
    Set-ItemProperty -Path $key -Name "IsAADCloudSearchEnabled" -Type "DWORD" -Value 0
    Set-ItemProperty -Path $key -Name "IsDeviceSearchHistoryEnabled" -Type "DWORD" -Value 0
    Set-ItemProperty -Path $key -Name "IsMSACloudSearchEnabled" -Type "DWORD" -Value 0
}

# DT - Privacy & Security -> Windows Permissions
Start-Job -Name "Privacy_Security_Windows_Permissions" -ScriptBlock {

    # Location
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\Location'
    Set-ItemProperty $key -Name "Value" -Value "Deny" -Type "String"

    # Camera & Microphone
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam'
    Set-ItemProperty $key -Name "Value" -Value "Deny" -Type "String"    
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone'
    Set-ItemProperty $key -Name "Value" -Value "Deny" -Type "String"

    # Phone
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall'
    Set-ItemProperty $key -Name "Value" -Value "Deny" -Type "String"  
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory'
    Set-ItemProperty $key -Name "Value" -Value "Deny" -Type "String"

    # App Diagnostics
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics'
    Set-ItemProperty $key -Name "Value" -Value "Deny" -Type "String"

}

# All done, restart Windows Explorer and finish.
RestartWindowsExplorer
Write-Output "Done"
exit

