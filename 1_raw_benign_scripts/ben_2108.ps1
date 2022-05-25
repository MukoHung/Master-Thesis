Add-Type -AssemblyName System.Web

$tagName = $env:TAG_NAME
$sha = $env:COMMIT_SHA
$stashUser = $env:STASH_USER
$encPass = [System.Web.HttpUtility]::UrlEncode($env:STASH_PASS)
$repoUrl = $env:SRC_REPO

$gitCmd = "git.exe"

&$gitCmd --% tag -a -f -m "Release version %TAG_NAME% off %COMMIT_SHA%" %TAG_NAME%

$uri = [System.Uri]$env:SRC_REPO

$env:GIT_ORIGIN = "{0}://{1}:{2}@{3}{4}" -f $uri.Scheme, $stashUser, $encPass, $uri.Authority, $uri.AbsolutePath

&$gitCmd --% config remote.origin.url %GIT_ORIGIN%

# Don't destroy old tags if they already exist.
#&$gitCmd --% push origin :refs/tags/%TAG_NAME%
&$gitCmd --% push origin %TAG_NAME%