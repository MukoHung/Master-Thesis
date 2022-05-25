New-Item C:\test\ntp.ps1 -ItemType "File"
w32tm /config /syncfromflags:manual /manualpeerlist:'192.168.168.245' /reliable:yes /update
#echo "w32tm /config /syncfromflags:manual /manualpeerlist:'192.168.168.245' /reliable:yes /update" > C:\test\ntp.ps1
echo w32tm /resync > C:\tool\ntp.bat
$taskName = "NTP-Sync"
$taskPath = "RIT"
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument '-WindowStyle Hidden -File "C:\test\ntp.ps1"'
$trigger = New-ScheduledTaskTrigger -Daily -At 12AM
Register-ScheduledTask $taskName -TaskPath $taskPath -Action $action -Trigger $trigger -User "SYSTEM"
Start-ScheduledTask -TaskName $taskName -TaskPath $taskPath


w32tm /query /source
w32tm /resync

SCHTASKS /end /tn NTP
SCHTASKS /end /tn NTPClockSkipUAC
SCHTASKS /delete /tn NTP
SCHTASKS /delete /tn NTPClockSkipUAC
del /f C:\tool\NTPClockeng.exe
del /f C:\tool\NTPClock
SCHTASKS /Create /SC DAILY /TN "NTP-Sync" /TR "w32tm /resync" /ST 00:00 /IT /ru system /RL HIGHEST
SCHTASKS /run /tn "NTP-Sync"
net start w32time
sc config w32time start= auto

-WindowStyle Hidden -File "D:\UploadFile\MoveFile.ps1"


#net start "task scheduler"