function New-DataOpsRelease
{
    Begin
    {
        function Format-Issue
        {
            param(
                [Parameter(ValueFromPipelineByPropertyName = $true)]
                [Alias('Issue')]
                [string] $Key,
                [Parameter(ValueFromPipelineByPropertyName = $true)]
                [Alias('Title')]
                [string] $Summary
            )
            Process
            {
                $url = "https://evestment.atlassian.net/browse/$Key"
                '<a href="{0}">{1}</a> - {2}' -f $url, $Key, $Summary
            }
        }

        function Format-Branches
        {
            param(
                [Parameter(ValueFromPipeline = $true)]
                [string[]] $Branches
            )
            process
            {
                foreach ($branch in $Branches)
                {
                    $details = Get-BranchDetails -BranchName $branch
                    $issue = Get-JiraIssue -IssueId $details.Issue

                    $inputObject = if ($issue) { $issue } else { $details }
                    $fmt = $inputObject | Format-Issue
                    Write-Output "<li>$fmt</li>"
                }
            }
        }

        function Get-BranchesMergedSinceRelease
        {
            param(
                [version] $Start,
                [version] $End
            )

            $startCommit = $Start.ToString()
            $endCommit = if ($End) { $End.ToString() } else { 'HEAD' }

            git log --format="%C(auto)%h %s%d" --merges "${startCommit}..${endCommit}" |
                Select-String "to master" |
                Where-Object { $_ -match '([0-9a-fA-f]+) Merge.*from (.*?-\d*.*?) to master.*' } |
                ForEach-Object { $matches[2] } |
                Select-Object -Unique
        }

        function Get-CurrentVersion
        {
            Set-StrictMode -Version Latest

            [version]$currentVersion = $null
            $tag = git describe --match "*.*.*.*" --abbrev=0
            if (!($tag -and [version]::TryParse($tag, [ref]$currentVersion)))
            {
                Write-Warning "Unable to determine current version."
                $currentVersion = [version]::New(0, 0, 0, 0)
            }

            Write-Output $currentVersion
        }

        function Invoke-GitStash
        {
            Set-StrictMode -Version Latest
            $stashesBefore = git stash list
            git stash save -u
            $stashesAfter = git stash list
            Write-Output ($stashesBefore.Count -ne $stashesAfter.Count)
        }
    }

    Process
    {
        Set-StrictMode -Version Latest

        $srcPath = $DATA_OPS
        $destPath = $DATA_OPS_BUILDS

        $template = @'
<p>Hello,</p>
<p><br></p>
<p>A new release of DataOperations ({0}) is available. Tickets included in this release:</p>
<p><br></p>
<ul>
{1}
</ul>
<p><br></p>
<p>
Thanks,<br>
-sam
</p>
'@

        Push-Location $srcPath
        $currentBranch = Get-CurrentBranch

        $stashed = Invoke-GitStash
        git checkout master
        Start-Sleep -Seconds 1
        git pull

        $testResults = Invoke-Pester -PassThru
        if ($testResults.FailedCount -gt 0)
        {
            Write-Error "Tests did not pass."
            $testResults.TestResult | Where-Object { !$_.Passed }
            return
        }

        $currentVersion = Get-CurrentVersion
        $build = ./build.ps1 -Release
        Copy-Item $build.Path $destPath

        $branches = @(Get-BranchesMergedSinceRelease $currentVersion $build.Version)
        $listItems = $branches | Format-Branches
        $email = $template -f $build.Version.ToString(), ($listItems -join "`n")

        Write-Host "`n"
        Write-Host "`n"
        Write-Host $email
        $email | Out-BrowserView

        git checkout $currentBranch
        if ($stashed)
        {
            git stash pop
        }
        Pop-Location
    }
}
