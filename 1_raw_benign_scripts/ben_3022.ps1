$Splatting = Get-Help about_Splatting
$SortByWordCount = $Splatting -Split('\W+') | Where-Object {$_ -ne 'the'} | Group-Object | Sort-Object -Property Count -Descending
$Splatting | Select-Object Name,
    @{l='NumberOfWords';e={$_.ToString() | Measure-Object -Word | Select-Object -ExpandProperty Words}},
    @{l='TopWord';e={$SortByWordCount[0].Name}},@{l='TopWordCount';e={$SortByWordCount[0].Count}},
    @{l='Top5Words';e={($SortByWordCount.Name | Select-Object -First 5) -join ','}}