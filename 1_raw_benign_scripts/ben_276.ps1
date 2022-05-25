param(
    [Parameter(Mandatory=$true)][string]$pathToBeAdded
)

$local:oldPath = get-content Env:\Path
$local:newPath = $local:oldPath + ";" + $pathToBeAdded
set-content Env:\Path $local:newPath
