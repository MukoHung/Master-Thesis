if(Test-Path $HOME\Documents\Powershell\Microsoft.PowerShell_profile.ps1)
{
    Rename-Item -Path $HOME\Documents\Powershell\Microsoft.PowerShell_profile.ps1 -NewName $HOME\Documents\Powershell\Microsoft.PowerShell_profile.ps1.bak
}
Move-Item -Path Microsoft.PowerShell_profile.ps1 -Destination $HOME\Documents\Powershell\Microsoft.PowerShell_profile.ps1
New-Item -Name Microsoft.PowerShell_profile.ps1 -ItemType HardLink -Value $HOME\Documents\Powershell\Microsoft.PowerShell_profile.ps1 

if(Test-Path $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json)
{
    Rename-Item -Path $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json -NewName $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json.bak
}
Move-Item -Path profiles.json -Destination $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json
New-Item -Name profiles.json -ItemType HardLink -Value $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json