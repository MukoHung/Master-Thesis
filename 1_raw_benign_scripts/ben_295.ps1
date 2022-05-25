# Halt immediately if there is a problem
$ErrorActionPreference = "Stop"

git config --global user.email "nBuildKit.AppVeyor@example.com"
git config --global user.name "nBuildKit AppVeyor deployment"

$currentDir = $pwd
$scriptDir = "c:\projects\scripts"
$installDir = "c:\tools\githubrelease"

# clone the powershell scripts repository
git clone -q https://github.com/pvandervelde/Scripts.git $scriptDir

# 'Install' the github-release application
try
{
    sl (Join-Path $scriptDir "src\ps")
    .\install-github-release.ps1 -installPath $installDir
}
finally
{
    sl $currentDir
}