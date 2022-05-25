$Database = 'Processing database: [DBName] @ 2017-11-13 05:07:18 [SQLSTATE 01000]', 'Processing database: [Database] @ 2017-11-13 05:27:39 [SQLSTATE 01000]'

foreach ($Db in $Database)
{
    [PSCustomObject]@{
        OriginalLine         = $Db
        IndexOfOpeningSquare = $Db.IndexOf('[')
        IndexOfClosingSquare = $Db.IndexOf(']')
    }
}

#Substrings
#1
foreach ($Db in $Database)
{
    $Db.Substring($Db.IndexOf('[') + 1)
}
#Finished
foreach ($Db in $Database)
{
    $Db.Substring($Db.IndexOf('[') + 1, ($Db.IndexOf(']') - $Db.IndexOf('[')) - 1)
}

#split nested arrays
#1
foreach ($Db in $Database)
{
    ($Db -split '\[')
}
#2
foreach ($Db in $Database)
{
    ($Db -split '\[')[1]
}
#3
foreach ($Db in $Database)
{
    ($Db -split '\[')[1] -split '\]'
}
#Finished
foreach ($Db in $Database)
{
    (($Db -split '\[')[1] -split '\]')[0]
}

#first multiple delimiter split
#1
foreach ($Db in $Database)
{
    ($Db -split {$_ -eq '[' -or $_ -eq ']'})
}
#Finished
foreach ($Db in $Database)
{
    ($Db -split {$_ -eq '[' -or $_ -eq ']'})[1]
}

#Final method
#1
foreach ($Db in $Database)
{
    ($Db -split '[\[\]]')
}
#Finished
foreach ($Db in $Database)
{
    ($Db -split '[\[\]]')[1]
}