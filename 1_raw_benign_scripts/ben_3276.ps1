# Deployed via sccm "run script" mechanism to desktop collection
# You need YOUR_SHARE with "Authenticated Users" write permission
# because SCCM runs the script using SYSTEM credentials.
#
# Ref:
#https://stackoverflow.com/questions/20269202/remove-files-from-zip-file-with-powershell

$ReportFile = "\\YOUR_SERVER\YOUR_SHARE\Path\Report.txt"

#############################
# DON'T CHANGE BELOW THIS LINE
#############################
if(!(Test-Path -Path $ReportFile))
{
    "ComputerName,ZipFile,Status" | Out-File -FilePath $ReportFile
}

[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression') | Out-Null

$drives = (Get-WmiObject -Query "SELECT * from win32_logicaldisk where DriveType = '3'").DeviceID

#Collect all log4j jar files on all physical drives.
#Gonna take a while.
ForEach($drive in $drives)
{
    $log4Jfiles += Get-ChildItem -Path "$drive\" -Include "log4j*.jar" -File -Recurse -ErrorAction SilentlyContinue
}

#Check each log4j file for presense of the vuln class:
#org/apache/logging/log4j/core/lookup/JndiLookup.class
$files = "JndiLookup.class"
ForEach($zipFile in $log4jfiles.FullName)
{
    try
    {
        $stream = New-Object IO.FileStream($zipfile, [IO.FileMode]::Open)
        $mode   = [IO.Compression.ZipArchiveMode]::Update
        $zip    = New-Object IO.Compression.ZipArchive($stream, $mode)

        ($zip.Entries | ? { $files -contains $_.Name }) | % { $_.Delete() ; "$env:COMPUTERNAME,$zipFile,SUCCESS" | Out-File -FilePath $ReportFile -Append }

        $zip.Dispose()
        $stream.Close()
        $stream.Dispose()
    }
    catch
    {
        "$env:COMPUTERNAME,$zipFile,FAILED: $($PSItem.Exception.Message)" | Out-File -FilePath $ReportFile -Append
    }
}
