$release = Invoke-RestMethod -Uri "https://api.github.com/repos/Seddryck/NBi/releases/latest"
Write-Output "Latest release found: $($release.name)"
$url = $release.assets[0].browser_download_url

# Possible improvements:
#  params for outdir/tempdir/release
#  use GetTempPath() to download .zip file to (or use current folder)
	
pushd $PSScriptRoot

md -Force ".temp" | Out-Null

[Environment]::CurrentDirectory = $PSScriptRoot  # PS's pushd does NOT set CurrentDirectory
$output = [IO.Path]::GetFullPath(( Join-Path ".temp" ([IO.Path]::GetFileName($url)) ))
$start_time = Get-Date

Write-Output "Downloading from: $url to: $output"

wget $url -OutFile $output

md -Force "packages\NBi" | Out-Null
Remove-Item packages\NBi\* -Recurse -Force

Write-Output "Extracting to: $([IO.Path]::GetFullPath("packages\NBi")) ..."

Expand-Archive $output packages\NBi -Force

Write-Output "Time taken: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"  

popd