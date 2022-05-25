# See if choco.exe is available. If not, stop execution
$chocoCmd = Get-Command -Name 'choco' -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Select-Object -ExpandProperty Source
if ($chocoCmd -eq $null) { break }

# Settings for the scheduled task
$taskAction = New-ScheduledTaskAction –Execute $chocoCmd -Argument 'upgrade all -y'
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskUserPrincipal = New-ScheduledTaskPrincipal -UserId 'SYSTEM'
$taskSettings = New-ScheduledTaskSettingsSet -Compatibility Win8

# Set up the task, and register it
$task = New-ScheduledTask -Action $taskAction -Principal $taskUserPrincipal -Trigger $taskTrigger -Settings $taskSettings
Register-ScheduledTask -TaskName 'Run a Choco Upgrade All at Startup' -InputObject $task -Force