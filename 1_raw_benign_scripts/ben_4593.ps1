# file operations

New-Item -Force -Path "somefile.txt" -ItemType File

Copy-Item -Path "X:\Tutorials\Windows\PowerShell" -Force -Recurse -Destination "C:\Users\jyd1kor\Downloads"

Rename-Item -Path "C:\Users\jyd1kor\Downloads\PowerShell" -NewName "C:\Users\jyd1kor\Downloads\PowerShells"

Remove-Item -Recurse "C:\Users\jyd1kor\Downloads\PowerShells"

# read entire file. The return value is an array which you can loop through.
Get-Content "X:\Tutorials\Windows\PowerShell\trial\myfile.txt"
(Get-Content "X:\Tutorials\Windows\PowerShell\trial\myfile.txt").Length

Test-Path "X:\Tutorials\Windows\PowerShell"

New-Item -Force -Path "X:\Tutorials\Windows\PowerShell\trial\content.txt" -ItemType File

Set-Content "X:\Tutorials\Windows\PowerShell\trial\content.txt" "some test contents"

Clear-Content "X:\Tutorials\Windows\PowerShell\trial\content.txt"

Set-Content "X:\Tutorials\Windows\PowerShell\trial\content.txt" "content1"
Add-Content "X:\Tutorials\Windows\PowerShell\trial\content.txt" "content2" # adds to a new line
