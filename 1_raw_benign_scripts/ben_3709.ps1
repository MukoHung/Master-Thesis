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

# 1. split by newline and sort by length (minus the number)
$sortedList = $list.Split([System.Environment]::NewLine,[System.StringSplitOptions]::RemoveEmptyEntries) |Sort-Object {($_ -replace '^\d+','').Length}

# 2. Convert to objects with count and item properties
$gifts = $sortedList |ForEach-Object {
  # split string into two at first whitespace
  $Count,$Item = $_ -split '\s+',2

  # create new object with properties
  New-Object psobject -Property @{
    Count = $Count
    Item = $Item
  }
}

# 3. Count the bird-related items
$birdCount = ($gifts |Where-Object {
  $gift = $_
  # check if the Item value matches any of the bird names
  @("partridge","doves","hens","birds","geese","swans" |ForEach-Object{
    $gift -like "*$_*"
  }) -contains $true
}) | Measure-Object -Property Count -Sum |Select-Object -ExpandProperty Sum

# 4. Count all items
$trueLoveGiftCount = $gifts | Measure-Object -Property Count -Sum |Select-Object -ExpandProperty Sum

# Bonus: Count all items with each previous gift being giving every day forward
$greedyLoveGiftCount = 1..12 |ForEach-Object { $gifts |Select-Object -First $_ }|Measure-Object -Property Count -Sum|Select-Object -ExpandProperty Sum