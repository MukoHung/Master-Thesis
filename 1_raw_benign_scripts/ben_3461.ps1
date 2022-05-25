$action = New-ScheduledTaskAction -Execute "scoop.exe" -Argument "update"
$trigger = New-ScheduledTaskTrigger -DaysInterval 1 -Daily -At "14:00 PM"
$settings = New-ScheduledTaskSettingsSet -Hidden

$user = $env:username

Register-ScheduledTask -TaskPath \ -TaskName scoop_update -Action $action -Trigger $trigger -User $user -Settings $settings

Enable-ScheduledTask -TaskPath \ -TaskName scoop_update
Start-ScheduledTask -TaskPath \ -TaskName scoop_update

