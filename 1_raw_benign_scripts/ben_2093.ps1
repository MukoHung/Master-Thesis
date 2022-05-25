$Measurement = get-childitem -Path C:\temp -Recurse -File | Measure-Object -Property Length -sum -Average
[pscustomobject]@{
    Count = $Measurement.Count
    Average = $Measurement.Average
    Sum = $Measurement.Sum
    Date = Get-Date
    ComputerName = $env:Computername 
}