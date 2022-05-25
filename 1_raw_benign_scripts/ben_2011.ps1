Import-Module SqlServer -Force -ErrorAction Stop 

#Import-Module sqlps -DisableNameChecking 


if (-not (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Error "Unabled to find Invoke-SqlCmd cmdlet"
}

if (-not (Get-Module -Name SqlServer | Where-Object {$_.ExportedCommands.Count -gt 0})) {
    Write-Error "The SqlServer module is not loaded"
}

if (-not (Get-Module -ListAvailable | Where-Object Name -eq SqlServer)) {
    Write-Error "Can't find the SqlServer module"
}

$server = "." 
$db ="master"
$filename = "C:\Utilities\Enable Contained Database Authentication.sql"
Invoke-sqlcmd -ServerInstance $server -Database $db -InputFile $filename

