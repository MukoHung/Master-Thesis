$gdata = $printsLogs | Group-Object -Property userId

$test = @()

$test += foreach($item in $gdata){

    $item.Group | Select -Unique userId,
    @{Name = 'PageTotal';Expression = {(($item.Group) | measure -Property pages -sum).Sum}}

}
