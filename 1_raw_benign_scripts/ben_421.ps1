param(
    [Parameter(Mandatory=$true)][string]$dirToBackup,
    [string]$description = "backup",
    [string]$type = "7z"
)

$typepar = "-t$($type)"
Write-Host $typepar

$date = get-date -f yyyy-mm-dd

7z a $typepar $date-$description.$type $dirToBackup

pause