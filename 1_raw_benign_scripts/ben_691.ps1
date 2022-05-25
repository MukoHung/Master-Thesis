if (! (Test-Path variable:script:ENV))
{
    Set-Variable -Name ENV -Value ci -Scope Script
}

$ScriptPath            = $MyInvocation.MyCommand.Path
$ScriptDir             = Split-Path $ScriptPath
$CommonScript          = Join-Path $ScriptDir "common.ps1"
. $CommonScript

Write-Notice "==> cibuild"

Invoke-Script "bootstrap.ps1"
Invoke-Script "setup.ps1"
Push-Location $ScriptDir
$ServerJob = Start-Job -ScriptBlock { pwsh -File "server.ps1" }
Pop-Location
Invoke-Script "test.ps1"
Receive-Job ${ServerJob}
Remove-Job -Force ${ServerJob}
Invoke-Script "destroy.ps1"
