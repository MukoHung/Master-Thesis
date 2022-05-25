function ApplyMergeDiscard
{
    [cmdletbinding(SupportsShouldProcess=$true)]
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $LocalPath,

        [Parameter(Mandatory=$true)]
        [ValidateSet("MainIntoDev", "DevIntoMain")]
        [string] $Direction,

        [Parameter(Mandatory=$false)]
        [string] $BaseDevBranch = "$/YOUR PROJECT/BRANCH1/",

        [Parameter(Mandatory=$false)]
        [string] $BaseMainBranch = "$/YOUR PROJECT/BRANCH2/"
    )

    $env:Path = $env:Path + ";C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE"

    $discards = @( `
        # Some stuff you shouldn't merge
        "Stuff1.publish.proj", `
        "Stuff2.publish.proj", `

        # Some more stuff you shouldn't merge
        "Some.Project/AConfiguration.Debug.config", `
        "Some.Project/AConfiguration.Release.config" `
        )

    Set-Location $LocalPath

    $discards | ForEach-Object {
        if($Direction -eq "MainIntoDev") {
            $sourcePath = $BaseMainBranch + $_
            $targetPath = $BaseDevBranch + $_
        }
        else {
            $sourcePath = $BaseDevBranch + $_
            $targetPath = $BaseMainBranch + $_
        }

        if($WhatIfPreference -eq $false) {
            Write-Verbose "Discarding $sourcePath into $targetPath"
            & tf merge /discard $sourcePath $targetPath
        }
        else {
            Write-Host "WhatIf: Discarding $sourcePath into $targetPath"
        }
    }
}