#begin PS script

### You must run "Set-ExecutionPolicy RemoteSigned" or "Set-ExecutionPolicy Unrestricted" on the server first, or the script will not run automatically. ###
### For Dell OpenManage Administrator use, run the script manually once with the -configure option to set the script in the OpenManage application. Example: "OMAlert.ps1 -configure" ###
### Rerun the script manually if you change any of the information in the Body section. ###
### To test script, you can either pull a redundant power supply, or change the temperature warning (just make sure to change it back). ###
### Source: http://lemonfilling.com/Tech/omalert.html ###
### Source: http://stackoverflow.com/questions/29029364/sending-email-with-gmail-using-powershell ###
 
param ([switch]$configure)

$Date = Get-Date
$Server = gc env:computername
$EmailFrom = "ActualAccount@yourdomain.com"
$EmailTo = "Email1@yourdomain.com,Email2@yourdomain.com,Email3@yourdomain.com"
$Subject = "Hardware Alert from $Server $Date"
$SMTPServer = "smtp.gmail.com"
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("ActualAccount@yourdomain.com", "PASSWORD")

$Body=$args[0]

if ($configure -eq $true) {` & "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=powersupply execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Power Supply Failure'"
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=powersupplywarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Power Supply Warning'"
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=tempwarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Temperature Warning'"
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=tempfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Temperature Failure'"
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=fanwarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Fan Warning'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=fanfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Fan Failure'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=voltwarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Voltage Warning'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=voltfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Voltage Failure'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=intrusion execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Chassis Intrusion Detected'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=redundegrad execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'System Redundancy Degraded'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=redunlost execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'System Redundancy Lost'"
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=memprefail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Memory Pre-Fail'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=memfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Memory Failure'"
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=processorwarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Processor Warning'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=processorfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Processor Failure'"
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=watchdogasr execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Automatic System Recovery'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=batterywarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Battery Warning'"
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=batteryfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Battery Failure'"
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=systempowerwarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'System Power Warning'"
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=systempowerfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'System Power Failure'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=systempeakpower execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'System Power'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=storagesyswarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Storage Warning'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=storagesysfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Storage Failure'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=storagectrlwarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Storage Controller Warning'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=storagectrlfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Storage Controller Failure'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=pdiskwarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Physical Disk Warning'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=pdiskfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Physical Disk Failure'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=vdiskwarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Virtual Disk Warning'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=vdiskfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'Virtual Disk Failure'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=enclosurewarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'System Enclosure Warning'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=enclosurefail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'System Enclosure Failure'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=storagectrlbatterywarn execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'RAID Battery Warning'" 
& "c:\program files\dell\sysmgt\oma\bin\omconfig.exe" system alertaction event=storagectrlbatteryfail execappath="powershell C:\Scripts\DellSMTPNotify\OMAlert.ps1 'RAID Battery'"}

else{$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)}
#end PS script