$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

<#
  
  PASTE YOUR ACTUAL CODE HERE

#>
Get-Process #  Example

$totaltime = [math]::Round($elapsed.Elapsed.TotalSeconds,2)

Write-Host "Total Elapsed Time: $totaltime seconds."