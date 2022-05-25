# Call another script in the same directory with command line args without
# waiting for it to exit while keeping a handle to the process
$arguments = "-File `"$PSScriptRoot\Other-Script.ps1`" -SomeArg $SomeVar"
$process = Start-Process powershell.exe -ArgumentList $arguments -WindowStyle Hidden -PassThru
Write-Host "$($process.ID) has started"