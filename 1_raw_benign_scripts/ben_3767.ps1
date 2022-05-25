# http://stackoverflow.com/a/5429048/2796058

$ToNatural = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
Get-ChildItem | Sort-Object $ToNatural