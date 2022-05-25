# Perform 'git pull' command on main|master branch in all subfolders
Get-ChildItem -directory -force -recurse -depth 1 -filter .git | ForEach-Object {
    $cmd = "pull"
    $path = $_.Parent.FullName
    Push-Location $path
    $branch = git rev-parse --abbrev-ref HEAD
    if (($branch -eq "main") -or ($branch -eq "master")) {
        Write-Host "$path [$branch]> git $cmd" -foregroundColor green
        & git $cmd
    } else {
        Write-Host "$path [$branch]> skip" -foregroundColor yellow
    }
    Pop-Location
}
