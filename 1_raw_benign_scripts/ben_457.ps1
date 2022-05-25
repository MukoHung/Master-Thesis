
# Start logging, overwriting any existing log file.
$LogFile = "C:\cse-bootstrap.log"
Start-Transcript -Path $LogFile

Write-Host "Hello World!"

# Get info about host
# @see https://docs.microsoft.com/en-us/powershell/scripting/getting-started/cookbooks/collecting-information-about-computers?view=powershell-6

Get-WmiObject -Class Win32_ComputerSystem

Get-WmiObject -Class Win32_BIOS -ComputerName .

Get-CimInstance Win32_OperatingSystem | FL *

Get-WmiObject -Class Win32_Processor -ComputerName . | Select-Object -Property [a-z]*




