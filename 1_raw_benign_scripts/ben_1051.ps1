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

#Question 1
#Split $list into a collection of entries, as you typed them, and sort the results by length. As a bonus, see if you can sort the length without the number.
$list -replace '\d{1,2}\s','' -Split '\n' | sort -Property Length

#Question 2
# Turn each line into a custom object with a properties for Count and Item.
$list -split "\n" | ForEach-Object { 
 	[PSCustomObject]@{'count' = $_.Split(' ')[0]; 
                      'item' = ($_ -replace '^\d{1,2}\s')} 
}


#Question 3
#Using your custom objects, what is the total number of all bird-related items?
($list -split "\n" | ForEach-Object { 
 	[PSCustomObject]@{'count' = $_.Split(' ')[0]; 
                      'item' = ($_ -replace '^\d{1,2}\s')} 
} | Select-String 'Geese|Swans|Birds|Hens|Doves|Partridge').count

#Question 4
#What is the total count of all items?
($list -split '\n' | select @{Name='Item';Expression={$_}}).count

#Bonus
#coal question
(($list | Select-String '\d{1,2}' -AllMatches).Matches.Value | Measure -Sum).Sum