# Set Script Start Time
$StartTime = Get-Date

<#
-----------
Your script here
-----------
#>

# Set Script Finish Time and do math
$FinishTime = Get-Date
$TotalTime = ($FinishTime - $StartTime).TotalMilliseconds

Write-Host "This script executed in $TotalTime ms."

# You can change milliseconds to seconds/ minutes etc: https://msdn.microsoft.com/en-us/library/system.timespan_properties(v=vs.110).aspx