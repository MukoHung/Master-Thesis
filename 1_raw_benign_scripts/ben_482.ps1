# These are the demos I delivered at Ignite for BRK3179 - PowerShell 7

# Not all of them are intended be run as-is, as they may require some dependency
# or be intended to showcase a more complex point (e.g. the AzVM example on &&)

# Those that were executed in the presentation were run with 7.0-preview.5 on the latest Windows 10

#region ETW Provider Definitions
$Providers = @("OAlerts","PowerShellCore/Operational","Microsoft-Windows-WMI-Activity/Operational","Microsoft-Windows-WLAN-AutoConfig/Operational","Microsoft-Windows-Wired-AutoConfig/Operational","Microsoft-Windows-WinRM/Operational","Microsoft-Windows-Winlogon/Operational","Microsoft-Windows-WinINet-Config/ProxyConfigChanged","Microsoft-Windows-WindowsUpdateClient/Operational","Microsoft-Windows-WindowsSystemAssessmentTool/Operational","Microsoft-Windows-Windows Firewall With Advanced Security/Firewall","Microsoft-Windows-Windows Defender/Operational","Microsoft-Windows-WFP/Operational","Microsoft-Windows-WebAuthN/Operational","Microsoft-Windows-WDAG-PolicyEvaluator-CSP/Operational","Microsoft-Windows-Wcmsvc/Operational","Microsoft-Windows-VPN/Operational","Microsoft-Windows-VolumeSnapshot-Driver/Operational","Microsoft-Windows-VHDMP-Operational","Microsoft-Windows-UserPnp/DeviceInstall","Microsoft-Windows-User Profile Service/Operational","Microsoft-Windows-User Device Registration/Admin","Microsoft-Windows-UniversalTelemetryClient/Operational","Microsoft-Windows-UAC-FileVirtualization/Operational","Microsoft-Windows-Time-Service/Operational","Microsoft-Windows-TerminalServices-LocalSessionManager/Operational","Microsoft-Windows-TaskScheduler/Maintenance","Microsoft-Windows-Storsvc/Diagnostic","Microsoft-Windows-StorageSpaces-Driver/Operational","Microsoft-Windows-Storage-Storport/Operational","Microsoft-Windows-Storage-Storport/Health","Microsoft-Windows-StateRepository/Operational","Microsoft-Windows-SMBServer/Operational","Microsoft-Windows-SMBClient/Operational","Microsoft-Windows-SmartCard-DeviceEnum/Operational","Microsoft-Windows-ShellCommon-StartLayoutPopulation/Operational","Microsoft-Windows-Shell-Core/Operational","Microsoft-Windows-Shell-Core/AppDefaults","Microsoft-Windows-SettingSync/Operational","Microsoft-Windows-SettingSync-Azure/Operational","Microsoft-Windows-SettingSync-Azure/Debug","Microsoft-Windows-SenseIR/Operational","Microsoft-Windows-SENSE/Operational","Microsoft-Windows-Security-SPP-UX-Notifications/ActionCenter","Microsoft-Windows-Security-Mitigations/KernelMode","Microsoft-Windows-Security-Audit-Configuration-Client/Operational","Microsoft-Windows-Resource-Exhaustion-Detector/Operational","Microsoft-Windows-RemoteDesktopServices-RemoteFX-Synth3dvsp/Admin","Microsoft-Windows-RemoteAssistance/Operational","Microsoft-Windows-ReadyBoost/Operational","Microsoft-Windows-PushNotification-Platform/Operational","Microsoft-Windows-Provisioning-Diagnostics-Provider/Admin","Microsoft-Windows-Privacy-Auditing/Operational","Microsoft-Windows-PrintService/Admin","Microsoft-Windows-PowerShell/Operational","Microsoft-Windows-Policy/Operational","Microsoft-Windows-Partition/Diagnostic","Microsoft-Windows-PackageStateRoaming/Operational","Microsoft-Windows-OfflineFiles/Operational","Microsoft-Windows-NTLM/Operational","Microsoft-Windows-Ntfs/WHC","Microsoft-Windows-Ntfs/Operational","Microsoft-Windows-NetworkProfile/Operational","Microsoft-Windows-NetworkLocationWizard/Operational","Microsoft-Windows-NCSI/Operational","Microsoft-Windows-MUI/Operational","Microsoft-Windows-MBAM/Operational","Microsoft-Windows-MBAM/Admin","Microsoft-Windows-LiveId/Operational","Microsoft-Windows-Known Folders API Service","Microsoft-Windows-Kernel-WHEA/Operational","Microsoft-Windows-Kernel-WHEA/Errors","Microsoft-Windows-Kernel-ShimEngine/Operational","Microsoft-Windows-Kernel-Power/Thermal-Operational","Microsoft-Windows-Kernel-PnP/Driver Watchdog","Microsoft-Windows-Kernel-PnP/Configuration","Microsoft-Windows-Kernel-EventTracing/Admin","Microsoft-Windows-Kernel-Boot/Operational","Microsoft-Windows-IKE/Operational","Microsoft-Windows-Hyper-V-Worker-Operational","Microsoft-Windows-Hyper-V-Worker-Admin","Microsoft-Windows-Hyper-V-VmSwitch-Operational","Microsoft-Windows-Hyper-V-Hypervisor-Operational","Microsoft-Windows-Hyper-V-Hypervisor-Admin","Microsoft-Windows-Hyper-V-Compute-Operational","Microsoft-Windows-Hyper-V-Compute-Admin","Microsoft-Windows-Host-Network-Service-Admin","Microsoft-Windows-GroupPolicy/Operational","Microsoft-Windows-Forwarding/Operational","Microsoft-Windows-Fault-Tolerant-Heap/Operational","Microsoft-Windows-Diagnosis-PCW/Operational","Microsoft-Windows-Diagnosis-DPS/Operational","Microsoft-Windows-Dhcpv6-Client/Operational","Microsoft-Windows-Dhcpv6-Client/Admin","Microsoft-Windows-Dhcp-Client/Admin","Microsoft-Windows-DeviceSetupManager/Operational","Microsoft-Windows-DeviceSetupManager/Admin","Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Operational","Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin","Microsoft-Windows-DeviceGuard/Operational","Microsoft-Windows-Crypto-NCrypt/Operational","Microsoft-Windows-Crypto-DPAPI/Operational","Microsoft-Windows-CoreSystem-SmsRouter-Events/Operational","Microsoft-Windows-Containers-Wcifs/Operational","Microsoft-Windows-Containers-BindFlt/Operational","Microsoft-Windows-CodeIntegrity/Operational","Microsoft-Windows-CloudStore/Operational","Microsoft-Windows-CertificateServicesClient-Lifecycle-User/Operational","Microsoft-Windows-CertificateServicesClient-Lifecycle-System/Operational","Microsoft-Windows-BranchCacheSMB/Operational","Microsoft-Windows-BranchCache/Operational","Microsoft-Windows-Bits-Client/Operational","Microsoft-Windows-BitLocker/BitLocker Management","Microsoft-Windows-Biometrics/Operational","Microsoft-Windows-BackgroundTaskInfrastructure/Operational","Microsoft-Windows-Audio/Operational","Microsoft-Windows-AppxPackaging/Operational","Microsoft-Windows-AppXDeployment/Operational","Microsoft-Windows-AppReadiness/Operational","Microsoft-Windows-AppReadiness/Admin","Microsoft-Windows-AppModel-Runtime/Admin","Microsoft-Windows-AppLocker/Packaged app-Execution","Microsoft-Windows-AppLocker/Packaged app-Deployment","Microsoft-Windows-Application-Experience/Program-Telemetry","Microsoft-Windows-AppID/Operational","Microsoft-Windows-AAD/Operational","Microsoft-Client-Licensing-Platform/Admin")
#endregion

#region ForEach-Object -Parallel

Measure-Command {1..10 | ForEach-Object { Start-Sleep 2 }}
Measure-Command {1..10 | ForEach-Object -Parallel { Start-Sleep 2 }}
Measure-Command {1..10 | ForEach-Object -Parallel { Start-Sleep 2 } -ThrottleLimit 10}

Measure-Command { $serial = $Providers | ForEach-Object {Get-WinEvent -LogName $_}} 
Measure-Command { $parallel = $Providers | ForEach-Object -Parallel {Get-WinEvent -LogName $_}}

Compare-Object $serial $parallel

#endregion

#region New Operators

# Ternary operator

$a = $someConditional ? "it's true!" : "it's false"
$a
$someConditional = $true
$a = $someConditional ? "it's true!" : "it's false"
$a

$env:path += $IsWindows ? ";C:\tools" : ":~/tools"

# Pipeline chain operators (&& and ||)
# These rely on $?

Install-Module posh-git && Import-Module posh-git
sudo apt update && sudo apt upgrade
npm build && npm test
./build.ps1 || Import-Module ./out/myBuiltModule

## Null-coalescing operators

# If $x is null, return 1, otherwise return $x
$x ?? 1
$x = 2
$x ?? 1

# Assign 2 to $y, and if $y is null (it isn't) return 1, otherwise return $y (2)
$y = 2
$y ?? 1

# If I can't find `Graphical` as an available module, install it
(Get-Module -ListAvailable Posh-SSH) ?? (Install-Module Posh-SSH -WhatIf -Force)

# If there's no service called WinRM that's running, start WinRM
(Get-Service WinRM | ? Status -eq 'Running') ?? (Start-Service WinRM -Verbose)

# If $z is null, assign 100 to it, otherwise do nothing
$z ??= 100
$z

# Create a new variable $myArrayList and set it to null
$myArrayList = $null
# If it's null (it is), set it to a new ArrayList with 4 elements
$myArrayList ??= ([System.Collections.ArrayList]::new(4))
# Validate that $myArrayList can house 4 elements
$myArrayList.Capacity

# Create a new Azure VM, and get some info about it after it's created`
New-AzVM @$params && Get-AzVM @$params

#endregion

#region PowerShellGet 3.0

# First, we get a local copy of the repo metadata
Update-PSResourceCache

# Then we can search with the new cmdlets, as well as pipe to install
Find-PSResource *git*
Find-PSResource Az -Module | Install-PSResource

# Install/Find-Module wrap the PSResource cmdlets for easy usage
Find-Module Az | Install-Module

# You will also be able to use Nuget version range syntax like [1.0,2.0)
#endregion
