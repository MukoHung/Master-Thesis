$version = (Get-Content package.json) -join "`n" | ConvertFrom-Json | Select -ExpandProperty "version"
$buildCounter = "%build.counter%"
$buildNumber = "$version.$buildCounter"
Write-Host "##teamcity[buildNumber '$buildNumber']"