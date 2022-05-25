Param(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$SvnFolderPath,
    [Parameter(Mandatory=$true, Position=2)]
    [string]$TargetFolder,
    [Parameter(Mandatory=$true, Position=3)]
    [string]$GitUrl
)

git svn clone --stdlayout --no-metadata -A users.txt $SvnFolderPath "$TargetFolder-tmp"

cd "$TargetFolder-tmp"
$remoteBranches = git branch -r

foreach($remoteBranch in $remoteBranches)
{
    $remoteBranch = $remoteBranch.Trim()

    if($remoteBranch.StartsWith("tags/"))
    {
        $tagName = $remoteBranch.Substring(5)

        git checkout -b "tag-$tagName" $remoteBranch
        git checkout master
        git tag $tagName "tag-$tagName"
        git branch -D "tag-$tagName"
    }
    elseif($remoteBranch -notlike "trunk")
    {
        git checkout -b $remoteBranch $remoteBranch
    }
}

cd ..
git clone "$TargetFolder-tmp" $TargetFolder
rm -Recurse -Force "$TargetFolder-tmp"
cd $TargetFolder

$remoteBranches = git branch -r
foreach($remoteBranch in $remoteBranches)
{
    $remoteBranch = $remoteBranch.Trim()

    if($remoteBranch -notcontains "HEAD" -and $remoteBranch -notcontains "master")
    {
        $branchName = $remoteBranch.Substring(7)
        git checkout -b $branchName $remoteBranch
    }
}

git checkout master
git remote rm origin

git remote add origin $GitUrl
git push --all 