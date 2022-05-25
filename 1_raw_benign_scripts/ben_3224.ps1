<#
Powershell script to create and monitor a ransomware canary file;
If the canary is modified, the script will notify the user, log the data, 
create an entry in the event log, and stop the workstation service, 
crippling the machine's ability to map or access network drives.  
Modified from a script found at freeforensics.org
#>


$DirPath = "C:\Temp\"
$FName = "Abrogado*.docx"
$FilePath = Join-Path -Path $Dirpath -ChildPath $FName

function CreateWatcher {
$global:FSWatcherObj = New-Object IO.FileSystemWatcher $DirPath, $FName -Property @{
IncludeSubdirectories = $false;
EnableRaisingEvents = $true;
NotifyFilter = [IO.NotifyFilters]'LastWrite'
  }
} 
function RegisterWatcher {
Register-ObjectEvent $FSWatcherObj Changed -SourceIdentifier FileChanged -Action {
$name = $Event.SourceEventArgs.Name
$changeType = $Event.SourceEventArgs.ChangeType
$timeStamp = $Event.TimeGenerated
Write-Host "The file '$name' was $changeType at $timeStamp" -fore red
$logdata = "$(Get-Date), $changeType, $FilePath, was altered! Disconnecting Drives"
Add-content "C:\Users\user\Desktop\Redemptio.bla" -value $logdata
New-EventLog –LogName Application –Source "Ransomware Canary”
$message = "Ransomware File Canary has been written to on " + $env:computername,"Information on the event: " + $logdata
Write-EventLog –LogName Application –Source “Ransomware Canary” –EntryType Warning –EventID 1 –Message $message
Stop-Service Workstation -force
[System.Windows.Forms.MessageBox]::Show("Your workstation is showing activity consistent with ransomware compromise.  All network drives have been disconnected, and a message dispatched to IT Security.  Please take your
 computer offline and contact the helpdesk immediately for malware remediation.","Ransomware detected","OK","Warning")
  }
} 
function CreateCanary {
New-Item C:\Temp\Abrogado-canary.docx -ItemType File -value "Ransomware canary file - do not edit"
}
CreateCanary
CreateWatcher
RegisterWatcher