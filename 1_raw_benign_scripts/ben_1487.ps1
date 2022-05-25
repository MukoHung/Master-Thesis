Clear-Host
$DaysPast = Read-Host "Enter Number of Days"
$Start = (Get-Date).AddDays(-$DaysPast)
$Path = Read-Host "Enter Search Path"
$Extenstion = Read-Host "Enter Extenstion"

Clear-Host
$Stopwatch = [system.diagnostics.stopwatch]::startNew()
Get-ChildItem -Path $Path -Include $Extenstion -Recurse |
Where-Object { $_.LastWriteTime -ge "$Start" } |
Select-Object Directory,Name,LastWriteTime |
Sort-Object LastWriteTime -Descending |
Format-Table -AutoSize
Write-Host "Search of -"$Path "- Completed!"
Write-Host "Search took" $Stopwatch.Elapsed.Milliseconds"ms."
$Stopwatch.Stop()
