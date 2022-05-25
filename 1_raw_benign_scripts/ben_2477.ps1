
$CompleteDir = "D:\Movies\"
$Files = Get-ChildItem $CompleteDir -Recurse | where {!$_.psiscontainer}
$Files | Where Length -LT 400000000 | Where Extension -ne ".srt" | Remove-Item -Verbose -Force

$CompleteDir = "D:\Movies\!New Releases"

get-childitem $CompleteDir -Recurse | ForEach-Object { Move-Item -LiteralPath $_.FullName $_.FullName.Replace("[",".(") -Force}
get-childitem $CompleteDir -Recurse | ForEach-Object { Move-Item -LiteralPath $_.FullName $_.FullName.Replace("]",").") -Force}
get-childitem $CompleteDir -Recurse | ForEach-Object { Move-Item -LiteralPath $_.FullName $_.FullName.Replace("..",".") -Force}


#$Files | Where {$(Split-Path $_.DirectoryName) -eq $CompleteDir} | Select FullName

$Dirs = (Get-ChildItem $CompleteDir -Recurse | where {$_.psiscontainer}).FullName
ForEach ($Dir in $Dirs){
    $Dir = $Dir.Replace('[','``[')
    $Dir = $Dir.Replace(']','``]')
    $Movie = Get-ChildItem $Dir | where Extension -NE '.srt'
    If (Test-Path "$Dir\*.srt"){
            Rename-Item $(Resolve-Path "$Dir\*.srt") "$Dir\$($Movie.Basename).srt" -Verbose -Force
        }
    Move-Item "$Dir\*" "$CompleteDir\" -Verbose -Force
    Remove-Item "$Dir" -Verbose -Force
}




$Files = (Get-ChildItem $CompleteDir | where {!$_.psiscontainer}).FullName
ForEach ($File in $Files){
    If ($File -match "HDRIP"){
            Move-Item $File "D:\Movies\!In Theaters\" -Verbose -Force
        }
}
