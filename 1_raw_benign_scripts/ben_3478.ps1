$list = @"
1 Partridge in a pear tree
2 Turtle Doves
3 French Hens
4 Calling Birds
5 Golden Rings
6 Geese a laying
7 Swans a swimming
8 Maids a milking
9 Ladies dancing
10 Lords a leaping
11 Pipers piping
12 Drummers drumming
"@

#1:

$sortedList = $list -split '\r?\n' | Sort-Object -Property { ($_ -replace '^\s*\d+\s*').Length }
Write-Host "`r`nSorted by length (not including number):`r`n"
$sortedList | Out-Host

#2:

$objectsList = @(
    foreach ($string in $sortedList)
    {
        if ($string -match '^\s*(\d+)\s*(.*)$')
        {
            [pscustomobject]@{
                Count = [int]$matches[1]
                Item  = $matches[2]
            }
        }
    }
)

Write-Host "`r`nAs objects:"
$objectsList | Format-Table -Property Item,Count -AutoSize | Out-Host

#3: 

$birdRelated = $objectsList | Where Item -Match 'Hen|Dove|Bird|Geese|Swan|Partridge'
Write-Host "Bird-related lines:"
$birdRelated | Out-Host
$totalBirds = $birdRelated | Measure-Object -Sum -Property Count | % Sum
Write-Host "Total number of birds: $totalBirds"

#4:

$sum = ($objectsList | Measure-Object -Sum -Property Count).Sum
Write-Host "Total number of items: $sum"


#Bonus:

function IncrementalSum
{
    param ([int] $UpperLimit)
    $array = [int[]](0..$UpperLimit)
    return $array | Measure-Object -Sum | % Sum
}

$cumulativeCountList = $objectsList| ForEach-Object { IncrementalSum $_.Count }
$cumulativeCount = $cumulativeCountList | Measure-Object -Sum | % Sum
Write-Host "Total cumulative gifts: $cumulativeCount"
