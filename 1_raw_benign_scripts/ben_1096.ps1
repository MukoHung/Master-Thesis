# credit for getting me going in the right direction
#    http://blogs.lessthandot.com/index.php/uncategorized/access-git-commits-during-a-teamcity-build-using-powershell/

# these properties should be entered into your configuration parameters section
$project = "%Octopus.Project%"
$deployTo = "%Octopus.DefaultEnvironment%"
$buildVersion = "%BuildVersion%"
$octopusApiKey = "%Octopus.BuildDeployBot.APIKey%"
$octopusServer = "%Octopus.Server.Url%"

# these properties should already be configured for you
$vcsGitUrl = "%vcsroot.url%"
$username = "%system.teamcity.auth.userId%"
$password = "%system.teamcity.auth.password%"
$serverUrl = "%teamcity.serverUrl%"
$buildTypeId = "%system.teamcity.buildType.id%"
$buildId = "%teamcity.build.id%"
$gitPath = "%env.TEAMCITY_GIT_PATH%"
$buildNumber = "%build.vcs.number%"
$checkoutDir = "%system.teamcity.build.checkoutDir%"
 
function Get-TeamCityLastSuccessfulRun{
    $AuthString = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$username`:$password"))
    $Url = "$serverUrl/app/rest/buildTypes/id:$buildTypeId/builds/status:SUCCESS" 
    $Content = Invoke-WebRequest "$Url" -Headers @{"Authorization" = "Basic $AuthString"} -UseBasicParsing
    return $Content
}
 
function Get-CommitsFromGitLog([string] $StartCommit, [string] $EndCommit){
    $fs = New-Object -ComObject Scripting.FileSystemObject
    $git = $fs.GetFile("$gitPath").shortPath
 
    $overviewUrl = "$serverUrl/viewLog.html?buildId=$buildId&buildTypeId=$buildTypeId&tab=buildResultsDiv"
    $commitUrl = "$($vcsGitUrl.TrimEnd('.git'))/commit"
    
    $Cmd = "$git log --pretty=format:""%s [%h...]($commitUrl/%H)"" $StartCommit...$EndCommit"
 
    $Result = $(Invoke-Expression "$path $Cmd")
    $nl = [environment]::NewLine
    [string]$str = "#TeamCity Auto Deployment  $nl" + "[click here for build overview]($overviewUrl)  $nl$nl"
    $Result | % {$str += " - $_  $nl"}
    
    return $str
}
 
$Run = Get-TeamCityLastSuccessfulRun
$LatestCommitFromRun = (Select-Xml -Content "$Run" -Xpath "/build/revisions/revision/@version").Node.Value
$CommitsSinceLastSuccess = Get-CommitsFromGitLog -StartCommit "$LatestCommitFromRun" -EndCommit "$buildNumber"
 
$CommitsSinceLastSuccess > "$checkoutDir\build-artifacts\ReleaseNotes.md"
$Cmd = "octo.exe create-release --apiKey=$octopusApiKey --server='$octopusServer' --project=$project --deployto=$deployTo  --enableServiceMessages --progress --waitfordeployment --packageversion=$buildVersion --releaseNotesFile=$checkoutDir\build-artifacts\ReleaseNotes.md"
Invoke-Expression $cmd