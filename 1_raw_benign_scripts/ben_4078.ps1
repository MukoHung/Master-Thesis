<#

.SYNOPSIS
This bootstrap script fetches the build scripts 

.DESCRIPTION
This script downloads cake bootstrap and dockerbuild scripts for iniating docker build with specified parameters. 

.EXAMPLE
./bootstrap.ps1 
./bootstrap.ps1 -Target Publish
./bootstrap.ps1 -Target Quality


#>

param(
    [Parameter(Position=0,Mandatory=$false,ValueFromRemainingArguments=$true)]
    [string[]]$scriptArgs
)

function IsLinux() {
    "$($ENV:OS)" -eq ""
}

Write-Host "Downloading build.ps1 script"
Invoke-WebRequest "https://bitbucket.honeywell.com/projects/CEDOTNET/repos/devops.build/raw/dotnetbuild.ps1" -OutFile build.ps1

$buildScriptArgs = @();
$buildScriptArgs += $scriptArgs

if(IsLinux) {
    Write-Host "Downloading dockerbuild.ps1 script"
    Invoke-WebRequest "https://bitbucket.honeywell.com/projects/CEDOTNET/repos/devops.build/raw/dockerbuild.ps1" -OutFile dockerbuild.ps1

    & ./dockerbuild.ps1 ce-devops-docker-docker-stable-local.artifactory-na.honeywell.com/docker.build.terraform:latest $buildScriptArgs
} else {
    Write-Host "Executing build on Windows so running directly rather than via Docker container. There is a known AnyConnect issue that blocks mounting of windows volumes into linux containers. A request for IT support has been raised."
    Invoke-Expression "`./build.ps1` $buildScriptArgs"
}

exit $LASTEXITCODE
