Function Get-FilePath {
    Write-Output "$env:TEMP\myfile.txt"
}
"Some Content" | Out-File (Get-FilePath)