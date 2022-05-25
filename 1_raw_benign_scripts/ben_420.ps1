#############################################  
##  
## PostgreSQL base backup automation 
## Author: Stefan Prodan   
## Date : 20 Oct 2014  
## Company: VeriTech.io    
#############################################
 
# path settings
$BackupRoot = 'C:\Database\Backup';
$BackupLabel = (Get-Date -Format 'yyyy-MM-dd_HHmmss');
 
# pg_basebackup settings
$PgBackupExe = 'C:\Program Files\PostgreSQL\9.3\bin\pg_basebackup.exe';
$PgUser = 'postgres';
 
# purge settings
$ExpireDate = (Get-Date).AddDays(-7);

# log settings
$EventSource = 'pg_basebackup';

# log erros to Windows Application Event Log
function Log([string] $message, [System.Diagnostics.EventLogEntryType] $type){
    # create EventLog source
    if (![System.Diagnostics.EventLog]::SourceExists($EventSource)){
        New-Eventlog -LogName 'Application' -Source $EventSource;
    }

    # write to EventLog
    Write-EventLog -LogName 'Application'`
        -Source $EventSource -EventId 1 -EntryType $type -Message $message;

}
 
# remove expired backups
function Purge([string] $backupRoot, [DateTime] $expireDate){
    # remove old files
    Get-ChildItem -Path $backupRoot -Recurse -Force -File | 
        Where-Object { $_.CreationTime -lt $expireDate } | 
        Remove-Item -Force;
 
    # remove old dirs
    Get-ChildItem -Path $backupRoot -Recurse -Force -Directory | 
        Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -Force -File) -eq $null } | 
        Where-Object { $_.CreationTime -lt $expireDate } | 
        Remove-Item -Force -Recurse;
}
 
# check free space based on last backup size if destination is local
function CheckDiskSpace([string] $backupRoot){
 
    $currentDrive = Split-Path -qualifier $backupRoot;
    $logicalDisk = Get-WmiObject Win32_LogicalDisk -filter "DeviceID = '$currentDrive'";
 
    if ($logicalDisk.DriveType -eq 3){
 
        # get free space 
        $freeSpace = $logicalDisk.FreeSpace;
 
        # calculate last backup size
        $lastBackup = Get-ChildItem -Directory $backupRoot | sort CreationTime -desc | select -f 1;
        $lastBackupDir = Join-Path $backupRoot $lastBackup;
        $totalSize = Get-ChildItem -path $lastBackupDir | Measure-Object -property length -sum;
 
        # space check
        if($totalSize.sum -ge $freeSpace){
            # format error message
            $sizeMB = "{0:N2}" -f ($totalSize.sum / 1MB) + " MB";
            $spaceError = "Not enough free space to backup on $backupRoot last backup $lastBackup was $sizeMB";
            # log and break execution
            Log $spaceError Error;
            Exit 1;
        }
    }
}
 
 
$BackupDir = Join-Path $BackupRoot $BackupLabel;
$PgBackupErrorLog = Join-Path $BackupRoot ($BackupLabel + '-tmp.log');
 
# check free space
CheckDiskSpace $BackupRoot;
 
# create backup dir
New-Item -ItemType Directory -Force -Path $BackupDir;

# execution time
$StartTS = (Get-Date);

# start pg_basebackup
try
{
    Start-Process $PgBackupExe -ArgumentList "-D $BackupDir", "-Ft", "-z", "-x", "-R", "-U $PgUser"`
     -Wait -NoNewWindow -RedirectStandardError $PgBackupErrorLog;
}
catch
{
    Write-Error $_.Exception.Message;
    Log $_.Exception.Message Error;
    Exit 1;
}

# check pg_basebackup output
If (Test-Path $PgBackupErrorLog){
 
    # read errors
    $errors = Get-Content $PgBackupErrorLog;
 
    If($errors -eq $null){
        # backup successful, purge old backups
        Purge $BackupRoot $ExpireDate;
    }
    else{
        # write error to Event Log
        Log $errors Error;
    }
 
    # delete tmp error log
    Remove-Item $PgBackupErrorLog -Force;
}

# Log backup duration
$ElapsedTime = $(get-date) - $StartTS;
Log "Backup done in $($ElapsedTime.TotalMinutes) minutes" Information;