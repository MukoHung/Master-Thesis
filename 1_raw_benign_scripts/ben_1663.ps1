$Monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID
$Computer  = Get-CimInstance -Class Win32_ComputerSystem
$Bios = Get-CimInstance -ClassName Win32_Bios
foreach ($Monitor in $Monitors){
    $PSObject = [PSCustomObject]@{
        ComputerName = $Computer.Name
        ComputerType = $Computer.model
        ComputerSerial = $Bios.SerialNumber
        MonitorSerial = [string]::join('',$monitor.SerialNumberID.Where{$_ -ne 0})
        MonitorType = [string]::join('',$monitor.UserFriendlyName.Where{$_ -ne 0})
        }
    $PSObject
}