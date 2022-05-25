# usage: powershell -ExecutionPolicy Bypass -file .\sqlite_backup.ps1 -dbFile .\tobackup.db3 -backupDir .\backup
# please make sure sqlite3.exe can be found in $PATH or specify it by -sqliteExe parameter
Param(
  # https://chocolatey.org/packages/sqlite.shell
  [string]$sqliteExe = "sqlite3.exe",
  [Parameter(Mandatory = $true)]
  [string]$dbFile,
  # default same as dbFile's directory
  [string]$backupDir = "",
  # [default|fullday|fulltime]
  [string]$rotateType = "default"
)

if (![System.IO.File]::Exists($dbFile)){
  Write-Warning "dbFile not found!";
  Exit 1;
}

if (![string]::IsNullOrEmpty($backupDir) -and ![System.IO.Directory]::Exists($backupDir)){
  [System.IO.Directory]::CreateDirectory($backupDir);
}

switch ($rotateType){
  fullday {
    $rotation = Get-Date -format 'yyyy-MM-dd';
    break;
  }
  fulltime {
    $rotation = Get-Date -format 'yyyyMMddHHmm';
    break;
  }
  default {
    $rotation = Get-Date -format 'dd';
    break;
  }
}

$backupFileName = [System.IO.Path]::GetFileNameWithoutExtension($dbFile) + "." + $rotation + [System.IO.Path]::GetExtension($dbFile);
$backupFilePath = [System.IO.Path]::Combine($backupDir, $backupFileName ).Replace('\','/');

Write-Host "Using SQLite Shell: [$sqliteExe] Backing up DB [$dbFile] => [$backupFilePath] ... " -NoNewline;

$proc = Start-Process -FilePath $sqliteExe `
-ArgumentList $dbFile, """.backup $backupFilePath""" `
-WorkingDirectory ([System.IO.Path]::GetDirectoryName($dbFile)) `
-NoNewWindow `
-Wait `
-PassThru

if ($proc.ExitCode -ne 0){
  Exit $proc.ExitCode;
} else {
  Write-Host "Done";
}