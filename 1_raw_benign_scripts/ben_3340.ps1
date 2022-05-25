# Script is a workaround for a problem with Docker and WSL2 on Windows 10.
# Author: Tomasz Kyc
# Author email: tomasz.kyc7@gmail.com


Write-Host "Trying to restart Docker and WSL."
Restart-Service *LxssManager* -Force -Verbose

Write-Host "Trying to kill Docker desktop process"
$processes = Get-Process "*docker desktop*"
if ($processes.Count -gt 0)
{
    $processes[0].Kill()
    $processes[0].WaitForExit()
    Write-Host "Killed Docker Desktop process successfully. Sleeping 30 seconds"
    Sleep 30
} 
else {
    Write-Host "There is no Docker Desktop process running"
}

Stop-Service *docker*
Start-Service *docker*
Start-Process "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
Write-Host "Restart Docker and WSL has been finished successfully."