# Just drop this in the 'Scripts' directory in your virtualenv and run it.
$Dir = Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path
$Scripts = Get-ChildItem $Dir | Where-Object {($_.name -match '\.py$') -and ($_.name -notmatch '^activa
te')}
foreach ($Script in $Scripts) {
	Write-Output "python $($Script.Fullname) @args" | Out-File ($Script.Fullname -replace '\.py$','.ps1')
}