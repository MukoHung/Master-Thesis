param([string]$VMNameStr)
$VMNameStr -split ',' | Where-Object {$_}