#
# Simplify forensic evidence collection on Windows hosts.
# Author: Starke427
# Modified: 2021 Feb 24

# Move to C:\ to prevent accidentally touching to SystemRoot
cd C:\

# Download Kansa from davehull/Kansa
$url1 = "https://github.com/davehull/Kansa/archive/master.zip"
$file1 = "C:\Kansa.zip"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url1, $file1)

# Unzip Kansa
Expand-Archive -LiteralPath 'C:\Kansa.zip' -DestinationPath 'C:\Kansa'

# Download Autoruns.sc from Microsoft Sysinternals
$url2 = "https://download.sysinternals.com/files/Autoruns.zip"
$file2 = "C:\Autoruns.zip"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url2, $file2)

# Unzip Autoruns
Expand-Archive -LiteralPath "C:\Autoruns.zip" -DestinationPath "C:\Autoruns"

# Move Autoruns to Kansa Directory
Move-Item -Path "C:\Autoruns\Autoruns.exe" -Destination "C:\Kansa\Kansa-master\Modules\bin"

# Overwrite Modules.conf
$ModuleConf = @"
# Use this file to configure the modules you want to run and the order you want to run them in.
# Below order is "the order of volatility" more or less. Long-running jobs should go at the end.
# Get-SecEventLog.ps1 is commented out below because depending on the environment, it can take ages and
# if centralized logging is enabled, may not be necessary.

Process\Get-PrefetchListing.ps1
# Process\Get-PrefetchFiles.ps1
# Process\Get-WMIRecentApps.ps1
Net\Get-Netstat.ps1
Net\Get-DNSCache.ps1
# Net\Get-Arp.ps1
Net\Get-SmbSession.ps1
# Process\Get-Prox.ps1
Process\Get-Tasklistv.ps1
# Process\Get-Handle.ps1
# Process\Get-RekalPslist.ps1
Process\Get-ProcsWMI.ps1
# Process\Get-ProcDump.ps1
# Process\Get-ProcsNModules.ps1
# Net\Get-NetRoutes.ps1
# Net\Get-NetIPInterfaces.ps1
# Net\Get-WMIIETelemetry.ps1
Log\Get-LogUserAssist.ps1
# Log\Get-LogWinEvent.ps1 Security
# Log\Get-LogWinEvent.ps1 Microsoft-Windows-# Application-Experience/Program-Inventory
# Log\Get-LogWinEvent.ps1 Microsoft-Windows-Application-Experience/Program-Telemetry
# Log\Get-LogWinEvent.ps1 Microsoft-Windows-AppLocker/EXE and DLL
# Log\Get-LogWinEvent.ps1 Microsoft-Windows-AppLocker/MSI and Script
# Log\Get-LogWinEvent.ps1 Microsoft-Windows-AppLocker/Packaged app-Deployment
# Log\Get-LogWinEvent.ps1 Microsoft-Windows-Shell-Core/Operational
# Log\Get-LogWinEvent.ps1 Microsoft-Windows-TerminalServices-LocalSessionManager/Operational
# Log\Get-LogWinEvent.ps1 Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational
# Log\Get-LogCBS.ps1
# Log\Get-LogOpenSavePidlMRU.ps1
# Log\Get-OfficeMRU.ps1
Log\Get-RdpConnectionLogs.ps1
ASEP\Get-SvcAll.ps1
ASEP\Get-SvcFail.ps1
ASEP\Get-SvcTrigs.ps1
ASEP\Get-WMIEvtFilter.ps1
ASEP\Get-WMIFltConBind.ps1
ASEP\Get-WMIEvtConsumer.ps1
ASEP\Get-PSProfiles.ps1
Disk\Get-TempDirListing.ps1
# Disk\Get-File.ps1 C:\Windows\WindowsUpdate.log
# Disk\Get-DiskUsage.ps1 C:\Users
# Disk\Get-FileHashes.ps1 MD5,C:\Users
# Disk\Get-FilesByHash.ps1 BF93A2F9901E9B3DFCA8A7982F4A9868,MD5,C:\Windows\System32
# Disk\Get-WebrootListing.ps1
# Disk\Get-FilesByHashes.ps1
# Disk\Get-IOCsByPath.ps1
Config\Get-LocalAdmins.ps1
# Config\Get-CertStore.ps1
# Config\Get-AMHealthStatus.ps1
# Config\Get-AMInfectionStatus.ps1
# Config\Get-Products.ps1
# Config\Get-PSDotNetVersion.ps1
# Config\Get-GPResult.ps1
# Config\Get-Hotfix.ps1
# Config\Get-IIS.ps1
# Config\Get-SmbShare.ps1
# Config\Get-SharePermissions.ps1
# Config\Get-ClrVersion.ps1

## Long running jobs go here so they're always last.
ASEP\Get-Autorunsc.ps1
# ASEP\Get-AutorunscDeep.ps1
# ASEP\Get-Sigcheck.ps1
# ASEP\Get-SigcheckRandomPath.ps1
# Disk\Get-FlsBodyFile.ps1
# IOC\Get-Loki.ps1
# Disk\Get-MasterFileTable.ps1
"@
Set-Content -Path "C:\Kansa\Kansa-master\Modules\Modules.conf" -Value $ModuleConf

# Overwrite Get-Autorunsc.ps1
$AutorunscScript = @'
if (Test-Path "C:\Autoruns\Autorunsc.exe") {
    & C:\Autoruns\Autorunsc.exe /accepteula -a * -c -h -s '*' -nobanner 2> $null | ConvertFrom-Csv | ForEach-Object {
        $_
    }
} else {
    Write-Error "Autorunsc.exe not found in C:\Autoruns\."
}
'@
Set-Content -Path "C:\Kansa\Kansa-master\Modules\ASEP\Get-Autorunsc.ps1" -Value $AutorunscScript

# Set up localhost to run Kansa
Enable-PSRemoting -force
ls -r C:\Kansa\Kansa-master\*.ps1 | Unblock-File
Set-ExecutionPolicy Unrestricted
$User = whoami
#$PWord = ConvertTo-SecureString -String "CHANGEME" -AsPlainText -Force
#AltCredential = New-Object -TypeName System.Management.AUtomation.PSCredential -ArgumentList $User, $PWord
$Credential = Get-Credential -Credential $User
C:\Kansa\Kansa-master\kansa.ps1 -Pushbin -Target localhost -ModulePath C:\Kansa\Kansa-master\Modules -Credential $Credential -Authentication Negotiate

# Remove traces
Remove-Item "C:\Kansa*" -Recurse
Remove-Item "C:\run_kansa.ps1"
Remove-Item "C:\Autoruns*" -Recurse

$Message = @"

You have successfully run Kansa!! 

An output of forensic data is now available in your C:\ directory.

It is highly advised that you install Eric Zimmerman's [Timeline Explorer]
(https://f001.backblazeb2.com/file/EricZimmermanTools/TimelineExplorer.zip) 
for opening CSV's within Windows for easier viewing. Alternatively, you can 
import them into excel or view them directly within PowerShell using 
Import-Csv C:\Output*.csv | Format-Table.

Note: If downloading Timeline Explorer, DO NOT USE WINDOWS TO EXTRACT THINGS. 
Use 7-Zip or Winrar as Windows will block the DLLs!

"@
echo $Message
