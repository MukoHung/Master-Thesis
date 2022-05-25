# Windows PowerShell Script to use restic to backup files using the Volume Shadow Copy Service, allowing
# that are in use to be backed up. The script must be run with elevated privileges.
# The Volume Shadow Copy Service must be enabled for the disk volume that contains the files to be backed up.
#
# Parameters
$resticExe = 'C:\Users\Username\go\bin\restic.exe'
$resticRepository = '\\SYNOLOGY212J\backups\restic-workstation'
$rootVolume = "C:\"
# List of folders to backup, separated by commas
$foldersToBackup = @(
    'Users\Username\AppData\Local\Microsoft\Outlook',
    'Users\Username\AppData\Local\Microsoft\Microsoft SQL Server Local DB'
)

# Your Restic password should be available in the RESTIC_PASSWORD environment variable.
# If not uncomment the following line with the actual password
#$env:RESTIC_PASSWORD = "secret_password"

###### No need to modify anything below this line ######
$ShadowPath = $rootVolume + 'shadowcopy\'

# Create a volume shadow copy and make it accessible
$s1 = (Get-WmiObject -List Win32_ShadowCopy).Create($rootVolume, "ClientAccessible")
$s2 = Get-WmiObject Win32_ShadowCopy | Where-Object { $_.ID -eq $s1.ShadowID }
$device  = $s2.DeviceObject + "\"

# Create a symbolic link to the shadow copy
cmd /c mklink /d $ShadowPath "$device"

# Run Restic on the data files in the shadowcopy

ForEach ($folderToBackup in $foldersToBackup) {
    cmd /c $resticExe backup -r $resticRepository ($ShadowPath + $folderToBackup)
}

# Delete the shadow copy and remove the symbolic link
$s2.Delete()
cmd /c rmdir $ShadowPath
echo "Done"