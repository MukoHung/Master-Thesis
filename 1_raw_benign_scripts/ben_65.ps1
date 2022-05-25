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

# 1. Split $list into a collection of entries, as you typed them, and sort the results by length. As a bonus, see if you can sort the length without the number.
$list.Split("`r`n") -replace "\d+\s" | Sort-Object length -Descending

# 2. Turn each line into a custom object with a properties for Count and Item.
$Items = $list.Split("`r`n") |
    ForEach-Object {
        $null = $_ -match "(?'Count'\d+)\s(?'Item'[\w\s]+)"
        [PSCustomObject]@{
            Count = $Matches.Count
            Item  = $Matches.Item
        }
    }
    
$Items

# 3. Using your custom objects, what is the total number of all bird-related items?
$Birds = @('Geese','Swans','Doves','Hens','Birds')
$Items |
    ForEach-Object {
        foreach ($Bird in $Birds) { if ($_.Item -like "*$Bird*") { $_ } }
    } | Measure-Object
    
# 4. What is the total count of all items?
$Items | Select-Object -ExpandProperty Count | Measure-Object -Sum | Select-Object -ExpandProperty sum

# Bonus Challenge
# Using PowerShell what is the total number of cumulative gifts?
$Items | Select-Object -ExpandProperty Count |
    ForEach-Object {
        for ($i = $_; $i -ge 1; $i = $i - 1) { $i }
    } | Measure-Object -Sum | Select-Object -ExpandProperty Sum