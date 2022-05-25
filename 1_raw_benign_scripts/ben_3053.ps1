<# print-current-script-name.ps1
   This script prints the name of the currently executing script 
   https://scriptech.io #>

#Print script name
$Scriptname = $MyInvocation.MyCommand.Name 
Write-Host -ForegroundColor White "`n[$Scriptname]`n"