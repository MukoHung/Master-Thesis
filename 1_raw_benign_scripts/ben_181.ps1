#------------ Add path to system variable -------------------------------------

$path2add = ';C:\path;'
$systemPath = [Environment]::GetEnvironmentVariable('Path', 'machine');

If (!$systemPath.contains($path2add)) {
    $systemPath += $path2add
    $systemPath = $systemPath -join ';'
    [Environment]::SetEnvironmentVariable('Path', $systemPath, 'Machine');
    write-host "Added to path!"
    write-host $systemPath
}

#------------ Delete path from system variable --------------------------------

$path2delete = 'C:\path;'
$systemPath = [Environment]::GetEnvironmentVariable('Path', 'machine');

$systemPath = $systemPath.replace($path2delete, '')
$systemPath = $systemPath -join ';'

[Environment]::SetEnvironmentVariable('Path', $systemPath, 'Machine');

write-host "Deleted from path!"
write-host $systemPath

#------------ Clean system variable -------------------------------------------

$systemPath = [Environment]::GetEnvironmentVariable('Path', 'machine');

while ($systemPath.contains(';;')) {
    $systemPath = $systemPath.replace(';;', ';')
}

[Environment]::SetEnvironmentVariable('Path', $systemPath, 'Machine');

write-host "Cleaned path!"
write-host $systemPath
