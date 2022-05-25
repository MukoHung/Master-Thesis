$botpath = "<PATH\TO\FILE.EXE>"
$processName = "<PROCESS_NAME>"
$intervalInSeconds = 600


while(1)
{
    Clear-Host
    write-host "Restarting $processName" -ForegroundColor Green
    Write-Host ""
    write-Host "Ending current session..." -ForegroundColor Yellow
    Stop-Process -name $processName 
    start-sleep -s 5


    Write-Host "Starting..." -ForegroundColor Green
    try
    {
        Start-Process -FilePath $botpath
        Write-Host "Started." -ForegroundColor Green
    }
    catch
    {
        Write-Host $_ -ForegroundColor Red
        Write-Host ""
        Write-Host "Will try again on next loop." -ForegroundColor Yellow
    }

    $date = Get-Date -Format g
    $intervalInMinutes = $intervalInSeconds / 60
    
    Write-Host ""    
    Write-Host "Next update in $intervalInMinutes minutes from $date"
    start-sleep -seconds $intervalInSeconds
  }