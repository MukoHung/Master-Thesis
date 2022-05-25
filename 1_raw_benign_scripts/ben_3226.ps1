param(
[parameter(Mandatory=$true)]
[string]
    $databaseDirectory
)

Function Format-FileSize() {
    Param ([int]$size)
    If     ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
    ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
    ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
    ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
    ElseIf ($size -gt 0)   {[string]::Format("{0:0.00} B", $size)}
    Else                   {""}
}

Write-Host "Running Database recovery and defragment with database directory: $databaseDirectory"

$databases = dir $databaseDirectory -Directory

$totalBefore = 0
$totalAfter = 0

foreach ($database in $databases){

    $currentDatabaseFullname = $database.FullName
    cd $currentDatabaseFullname
    $databaseFile = "$currentDatabaseFullname\data"
    $beforeLength = (Get-Item $databaseFile).Length
    iex "esentutl /d data"
    $afterLength = (Get-Item $databaseFile).Length

    $totalBefore += $beforeLength
    $totalAfter += $afterLength

    Write-Host "Processed $currentDatabaseFullname.  Size Before: $(Format-FileSize($beforeLength)) Size After: $(Format-FileSize($afterLength))"
}

Write-Host "Done Processing.  Size Before: $(Format-FileSize($totalBefore)) Size After: $(Format-FileSize($totalAfter))"

cd $PSScriptRoot