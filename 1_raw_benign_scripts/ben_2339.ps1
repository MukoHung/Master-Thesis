Write-Host "`nStart install"

if(Test-Path -Path "C:\FILEPATH\\Microsoft\1903"){
    
    Write-Host "`nC:\FILEPATH\\Microsoft\1903"
    Start-BitsTransfer -Source "\\FILEPATH\Windows10x64Professional1903_tw8075-44367en.iso" -Destination "C:\FILEPATH\\Microsoft\1903"
    Start-BitsTransfer -Source "\\FILEPATH\menuItems\1903\Win1903Upgrade.ps1" -Destination "C:\FILEPATH\\Microsoft\1903"
    powershell.exe -NoExit -File "C:\FILEPATH\\Microsoft\1903\Win1903Upgrade.ps1"

} elseif (Test-Path -Path "C:\FILEPATH\\Microsoft") {
    
    Write-Host "`nC:\FILEPATH\\Microsoft"
    New-Item -Path "C:\FILEPATH\\Microsoft" -Name "1903" -ItemType "directory"
    Start-BitsTransfer -Source "\\FILEPATH\Windows10x64Professional1903_tw8075-44367en.iso" -Destination "C:\FILEPATH\\Microsoft\1903"
    Start-BitsTransfer -Source "\\FILEPATH\menuItems\1903\Win1903Upgrade.ps1" -Destination "C:\FILEPATH\\Microsoft\1903"
    powershell.exe -NoExit -File "C:\FILEPATH\\Microsoft\1903\Win1903Upgrade.ps1"
    
} elseif (Test-Path -Path "C:\FILEPATH\") {

    Write-Host "`nC:\FILEPATH\"
    New-Item -Path "C:\FILEPATH\" -Name "Microsoft" -ItemType "directory"
    New-Item -Path "C:\FILEPATH\\Microsoft" -Name "1903" -ItemType "directory"
    Start-BitsTransfer -Source "\\FILEPATH\Windows10x64Professional1903_tw8075-44367en.iso" -Destination "C:\FILEPATH\\Microsoft\1903"
    Start-BitsTransfer -Source "\\FILEPATH\menuItems\1903\Win1903Upgrade.ps1" -Destination "C:\FILEPATH\\Microsoft\1903"
    powershell.exe -NoExit -File "C:\FILEPATH\\Microsoft\1903\Win1903Upgrade.ps1"
    
} elseif (Test-Path -Path "C:\FILEPATH") {
    
    Write-Host "`nC:\FILEPATH"
    New-Item -Path "C:\FILEPATH" -Name "Windows" -ItemType "directory"
    New-Item -Path "C:\FILEPATH\" -Name "Microsoft" -ItemType "directory"
    New-Item -Path "C:\FILEPATH\\Microsoft" -Name "1903" -ItemType "directory"
    Start-BitsTransfer -Source "\\FILEPATH\Windows10x64Professional1903_tw8075-44367en.iso" -Destination "C:\FILEPATH\\Microsoft\1903"
    Start-BitsTransfer -Source "\\FILEPATH\menuItems\1903\Win1903Upgrade.ps1" -Destination "C:\FILEPATH\\Microsoft\1903"
    powershell.exe -NoExit -File "C:\FILEPATH\\Microsoft\1903\Win1903Upgrade.ps1"
    
} elseif (Test-Path -Path "C:\FILEPATH") {
    
    Write-Host "`nC:\FILEPATH"
    New-Item -Path "C:\FILEPATH" -Name "packages" -ItemType "directory"
    New-Item -Path "C:\FILEPATH" -Name "Windows" -ItemType "directory"
    New-Item -Path "C:\FILEPATH\" -Name "Microsoft" -ItemType "directory"
    New-Item -Path "C:\FILEPATH\\Microsoft" -Name "1903" -ItemType "directory"
    Start-BitsTransfer -Source "\\FILEPATH\Windows10x64Professional1903_tw8075-44367en.iso" -Destination "C:\FILEPATH\\Microsoft\1903"
    Start-BitsTransfer -Source "\\FILEPATH\menuItems\1903\Win1903Upgrade.ps1" -Destination "C:\FILEPATH\\Microsoft\1903"
    powershell.exe -NoExit -File "C:\FILEPATH\\Microsoft\1903\Win1903Upgrade.ps1"
    
} else {

    Write-Host "`nError has occurred"

}