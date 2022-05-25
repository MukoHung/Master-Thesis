$latestRelease = Invoke-WebRequest https://github.com/pester/Pester/releases/latest -Headers @{"Accept"="application/json"}
$json = $latestRelease.Content | ConvertFrom-Json
$latestVersion = $json.tag_name

$url = "https://github.com/pester/Pester/archive/$latestVersion.zip"
$download_path = "$env:USERPROFILE\Downloads\pester-master.zip"

Invoke-WebRequest -Uri $url -OutFile $download_path

Get-Item $download_path | Unblock-File

$user_module_path = $env:PSModulePath -split ";" -match $env:USERNAME -notmatch "vscode"

if (-not (Test-Path -Path $user_module_path))
{
    New-Item -Path $user_module_path -ItemType Container | Out-Null
}

Expand-Archive -Path $download_path -DestinationPath $user_module_path[0] -Force

Import-Module Pester

$test_name = "Verify-Pester-" + (Get-Random)

New-Fixture -Path $PSScriptRoot\$test_name -name $test_name

(Get-Content $PSScriptRoot\$test_name\$test_name.Tests.ps1  ) | % {$_ -replace '\$true \| Should Be \$false', "$test_name | Should Be 'Hello From Pester!'" } | Set-Content $PSScriptRoot\$test_name\$test_name.Tests.ps1

"function $test_name {'Hello From Pester!'}" | Set-Content $PSScriptRoot\$test_name\$test_name.ps1 -Force

Invoke-Pester $test_name

if (Test-Path $PSScriptRoot\$test_name)
{
    Remove-Item -Path $PSScriptRoot\$test_name -Force -Recurse -Verbose
}









# https://blog.markvincze.com/download-artifacts-from-a-latest-github-release-in-sh-and-powershell/
# http://www.powershellmagazine.com/2014/03/12/get-started-with-pester-powershell-unit-testing-framework/