$drive = Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR 
$drive = Get-Disk | Where NumberOfPartitions -eq 0
$drive |  New-Partition -DriveLetter 'E'  -Size 25GB | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false -AllocationUnitSize 65536
$drive |  New-Partition -DriveLetter 'I'  -Size 10GB | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Logs" -Confirm:$false -AllocationUnitSize 65536
$drive |  New-Partition -DriveLetter 'N'  -Size 25GB | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Temp" -Confirm:$false -AllocationUnitSize 65536
$drive |  New-Partition -DriveLetter 'S'  -Size 25GB | Format-Volume -FileSystem NTFS -NewFileSystemLabel "System" -Confirm:$false -AllocationUnitSize 65536
$drive |  New-Partition -DriveLetter 'W'  -Size 25GB | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Backup" -Confirm:$false -AllocationUnitSize 65536