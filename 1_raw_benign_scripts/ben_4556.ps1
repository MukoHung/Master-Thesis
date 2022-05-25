<#
.SYNOPSIS
    Decrapify Windows 10 by uninstalling default crapware and disable Telemetry services

.DESCRIPTION
    Uninstall stupid useless garbage that Microsoft ships with Windows 10 by default.

.NOTES
    Uninstall stupid useless garbage that Microsoft ships with Windows 10 by default.

.VERSION
    11.14.2017

.GUID
    d2372bca-35bd-4589-ac9e-cbe6a399c969

.AUTHOR
    Lucas Halbert <contactme@lhalbert.xyz>

.COPYRIGHT
    Lucas Halbert 2017

.TAGS
    Decrapify, Windows10, Crapware, Bloatware, Garbage

.RELEASENOTES
  11.16.2017 - Testing

  11.15.2017 - Add lists of apps, services, and tasks to disable/uninstall
  
  11.14.2017 - Initial Draft

#>


# Set Variables
$stupidApps = "3DBuilder","Advertising","Bing","Candy","Getstarted","MicrosoftOfficeHub","Minecraft","Office.OneNote","Solitare","People","Print3d","Skype","Twitter","WindowsAlarms","WindowsCommunicationApps","WindowsMaps","WindowPhone","XboxApp","ZuneMusic","ZuneVideo"
$stupidServices = "Diagtrack","DmwApPushService","OneSyncSvc","XblAuthManager","XblGameSave","XboxNetApiSvc","WMPNetworkSv"
$stupidTasks = "SmartScreenSpecific","Microsoft Compatibility Appraiser","Consolidator","KernelCeipTask","UsbCeip","Microsoft-Windows-DiskDiagnosticDataCollector", "GatherNetworkInfo","QueueReporting"


Function RemoveApps($appsList) {
    # Remove the stupid apps
    Get-AppxPackage -AllUsers | select-string -pattern $appsList -simplematch | foreach {
        Write-host "Removing App: $_"
        Remove-AppxPackage $_ -ea 0
    }
}




Function DisableServices($servicesList) {
    # Stop and Disable services
    Get-Service $servicesList -ea 0 | stop-service -passthru | set-service -startuptype disabled
}


# Disable Cortana
Function DisableCortana() {
    Write-host "Disabling Cortana..."
    # Check if HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search exists
    if(-Not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
        New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    }

    # Check if AllowCortana DWORD exists
    if(-not [string]::IsNullOrEmpty((Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\" -Name "AllowCortana" -ea 0).AllowCortana)) {
        Write-host "Registry item already exists. Update it"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\" -Name "AllowCortana" -Value 0  -Force
    } else {
        Write-host "Registry item does not exists. Create it"
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\" -Name "AllowCortana" -Value 0 -PropertyType DWORD -Force
    }
}


# Remove Stupid Scheduled Tasks
Function RemoveScheduledTasks ($tasksList) {
    Write-host "Disabling Telemetry scheduled tasks"
    Get-Scheduledtask $tasksList -ea 0 | Disable-scheduledtask -ea 0
}

RemoveApps($stupidApps)

DisableServices($stupidServices)

RemoveScheduledTasks($stupidTasks)

DisableCortana