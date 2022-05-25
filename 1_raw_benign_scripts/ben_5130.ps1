param (
	[switch]$cooling,
	[switch]$performance
)

$global:fansPath = ".\fans.ps1"
$global:intelCpuPath = ".\intelExtremeTuningCpuVoltageOffset.ps1"
$global:msiGpuPath = ".\msiAfterburnerGpuCustomCoreClockCurve.ps1"
$global:windowsEnergyPath = ".\windows.ps1"

Function OptimizeBasedOnDayAndTime() {
	# Home isolation format 
	Performance
    return

    $currentDay = Get-Date -Format "dddd"
    if ( ($currentDay -eq 'Saturday') -or ($currentDay -eq 'Sunday') ) {
        Performance
        return
    }

    $currentTime = Get-Date -Format "HH"
    $currentTimeHours = [int] $currentTime
    if ($currentTimeHours -gt 18) {
        Performance
    } else {
        Cooling
    }
}

Function Cooling() {
    $global:fansPath += " -auto"
    $global:intelCpuPath += " -cooling"
    $global:msiGpuPath += " -cooling"
    $global:windowsEnergyPath += " -cooling"
    echo "Cooling profile applied."
}

Function Performance() {
    $global:fansPath += " -enable"
    $global:intelCpuPath += " -performance"
    $global:msiGpuPath += " -performance"
    $global:windowsEnergyPath += " -performance"
    echo "Performance profile applied."
}

Function ExecutePowershellScript($scriptPath) {
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command $scriptPath
}

if ($cooling)
{
    Cooling
}
elseif ($performance)
{
    Performance
}
else
{
    OptimizeBasedOnDayAndTime
}

ExecutePowershellScript $global:fansPath
ExecutePowershellScript $global:intelCpuPath
ExecutePowershellScript $global:msiGpuPath
ExecutePowershellScript $global:windowsEnergyPath