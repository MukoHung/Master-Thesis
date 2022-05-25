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

$list.count

echo "`n 1 Split list into a collection of entries, as you typed them, and sort the results by length. As a bonus, see if you can sort the length without the number `n"
$($($list.split("`n")) -replace "([0-9])","").trimstart() | Sort-Object  -Property length

echo "`n 2 Turn each line into a custom object with a properties for Count and Item.`n"
$manyObj =@()
$newlist= $($list.split("`n")).trimstart()
foreach ($it in $newlist)
{
    $itemObj = New-Object System.Object
    $itemObj | Add-Member -type NoteProperty -name Item $($($it.split("`n")) -replace "([0-9])","").trimstart()
    $itemObj | Add-Member -type NoteProperty -name Count $($($it.split("`n")) -replace "([a-z])","").trimstart()
    $manyObj +=$itemObj
}
$manyObj

echo "`n 3 Using your custom objects, what is the total number of all bird-related items? `n"
$birds = 'Partridge','Doves','Hens','Birds','Geese','Swans'
$TotBirds = 0

$manyObj|%{foreach ($bird in $birds){if ($_.item -match $bird){$TotBirds += 1}}}
$TotBirds

$TotBirds = 0
$manyObj|%{foreach ($bird in $birds){if ($_.item -match $bird){$TotBirds += $_.count}}}
echo "`n while if you are looking for the number of the birds: $TotBirds"


echo "`n 4 What is the total count of all items?`n"

$manyObj.count

echo "`n otherwise see the following bonus solution `n"
function gift($days){
    if ($days -eq 1){return 1}
    $days + (gift($days - 1))
}
$totgift = gift $manyObj.count
echo "cumulative gifts = $totgift" 