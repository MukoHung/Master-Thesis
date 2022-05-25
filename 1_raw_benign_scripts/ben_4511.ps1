# set paths
$wgFolder='C:\WGSERV'
$backupRoot='C:\wgbackup'

# how many days to keep backups
$keepFor = 7

# set backup folder (todays date)
$backupPath = "$backupRoot\$(get-date -Format MM-dd-yyyy)"

# files to backup
$filesToBackup = @{
    wcc = "$wgFolder\wcc*.*"
    wgusr  = "$wgFolder\WGSUSR2.dat"
    wgserv = "$wgFolder"
}

# set compression options (Fastest, Optimal, NoCompression)
$compressOptions = @{
    CompressionLevel = "Fastest"
}

# create daily backup folder in backup root
New-Item -Path $backupRoot -Name $(get-date -Format MM-dd-yyyy) -ItemType Directory

# backup the files
$filesToBackup.GetEnumerator() | ForEach-Object{
    $compressOptions.DestinationPath = "$backupPath\$($_.key)-$(get-date -Format MM-dd-yyyy).zip"
    Get-ChildItem -Path $_.value | Compress-Archive @compressOptions
}

# cleanup old files
Get-ChildItem $backupRoot -Recurse | Where-Object { $_.LastWriteTime -lt $(Get-Date).AddDays("-$keepFor") } | Remove-Item -WhatIf