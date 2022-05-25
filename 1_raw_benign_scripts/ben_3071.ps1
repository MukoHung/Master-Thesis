$global:DefaultUser = [System.Environment]::UserName

Import-Module posh-git
Import-Module oh-my-posh
Import-Module .\cowsay.psm1
Set-Theme Paradox
function fortune {
	[System.IO.File]::ReadAllText((Split-Path $profile)+'\fortune.txt') -replace "`r`n", "`n" -split "`n%`n" | Get-Random
}

# Remove the line below if you do not want fortune to run when PowerShell starts
fortune | cowsay; echo ''
