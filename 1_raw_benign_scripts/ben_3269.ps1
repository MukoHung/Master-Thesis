#Requires -RunAsAdministrator
#Requires -Version 5.0

$ErrorActionPreference = "Stop"

function Main
{
    #Size of dummy file, that transffered by PSRemoting.
    $fileSize = 10MB

    #Create random dummy data("Set random data because it may be compressed by PSRemoting)
    $from = New-TemporaryFile
    $bytes = New-Object byte[]($fileSize)
    $rand = New-Object Random
    $rand.NextBytes($bytes)
    [IO.File]::WriteAllBytes($from.FullName, $bytes)

    #Temporary file paths
    $sendTo = Join-Path $env:TEMP "SendTo.tmp"
    $receiveTo = Join-Path $env:TEMP "ReceiveTo.tmp"

    $session = New-PSSession -ComputerName localhost
    try
    {
        #Send file to remote session
        $sw = [Diagnostics.stopwatch]::StartNew()
        Copy-Item -Path $from -Destination $sendTo -ToSession $session
        Write-Host ("Send-File Elapsed: {0}[ms]" -f $sw.ElapsedMilliseconds)
        Write-Host ("Transfer Rate   : {0:F2}[Mbps]" -f ($fileSize / 1MB / $sw.Elapsed.TotalSeconds * 8))

        #Receive file from remote session
        $sw.Restart()
        Copy-Item -Path $from -Destination $receiveTo -FromSession $session
        Write-Host ("Receive-File Elapsed: {0}[ms]" -f $sw.ElapsedMilliseconds)
        Write-Host ("Transfer Rate   : {0:F2}[Mbps]" -f ($fileSize / 1MB / $sw.Elapsed.TotalSeconds * 8))
    }
    finally
    {
        Remove-Item $from -ErrorAction Ignore
        #TODO: Need to call Invoke-Command, to remove remote files
        Remove-Item $sendTo -ErrorAction Ignore
        Remove-Item $receiveTo -ErrorAction Ignore
        Remove-PSSession $session
    }
}

#Execute
. Main
