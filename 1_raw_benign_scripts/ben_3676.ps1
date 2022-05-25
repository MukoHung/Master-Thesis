function Is-Default-Branch {
    return "%teamcity.build.branch.is_default%" -eq "true"
}

function Set-TeamCity-Parameter($name, $value) {
    Write-Host "##teamcity[setParameter name='$name' value='$value']" 
}

if (Is-Default-Branch) {
    $releaseNumber = "%octopus.master.releaseNumber%"
    $deployTo = "%octopus.master.deployTo%"
    $packageVersion = "%octopus.master.packageVersion%"
}
else {
    $releaseNumber = "%octopus.release.releaseNumber%"
    $deployTo = "%octopus.release.deployTo%"
    $packageVersion = "%octopus.release.packageVersion%"
}

Set-TeamCity-Parameter "octopus.releaseNumber" $releaseNumber
Set-TeamCity-Parameter "octopus.packageVersion" $packageVersion
Set-TeamCity-Parameter "octopus.deployTo" $deployTo