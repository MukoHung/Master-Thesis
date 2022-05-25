if ($args.count -ne 0)
{
    if(Test-Path ./version.txt)
    {
        $ver = get-content ./version.txt
        $major = [Int]($ver.Split(".")[0])
        $minor = [Int]($ver.Split(".")[1])
        $patch = [Int]($ver.Split(".")[2])

        switch($args[0])
        {
            "major" { $major = ($major+1) }
            "minor" { $minor = ($minor+1) }
            "patch" { $patch = ($patch+1) }
        }
        
        "$major.$minor.$patch" > ./version.txt
     }
     else { Write-Warning "No version file in this directory" }
}
else { Write-Warning "Please specify: major, minor or patch" }