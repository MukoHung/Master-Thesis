#===============================================================================================
# AUTHOR:  Lee Cuevas, Dan Shepard
# DATE:
# Version
# COMMENT:
#===============================================================================================

##First of all, make sure there are enough real estate on the powershell console
$BufferWidth = 250
$BufferHeight = 600
$bUpdateSize = $false
$RawUI = (Get-Host).UI.RawUI
$BufferSize = $RawUI.BufferSize

if ($BufferSize.Width -lt $BufferWidth) {$BufferSize.Width = $BufferWidth; $bUpdateSize = $true}
if ($BufferSize.Height -lt $BufferHeight) {$BufferSize.Height = $BufferHeight; $bUpdateSize = $true}
if ($bUpdateSize -eq $true) {$RawUI.BufferSize = $BufferSize}

Remove-Variable bUpdateSize

$ErrorActionPreference = 'Continue'

Write-Host "Executing build scripts"

# Copy files needed for Windows Update Script

#Copy-item .\PSWindowsupdate -Destination C:\WIndows\System32\WindowsPowershell\v1.0\Modules\ -recurse

# Unblock files - Add path and unzip all to c:\temp
Get-ChildItem C:\Scripts\*.ps1 -Recurse | Unblock-File
Get-ChildItem C:\Scripts\*.ps1xml -Recurse | Unblock-File
Get-ChildItem C:\Scripts\*.psm1 -Recurse | Unblock-File
Get-ChildItem C:\Windows\System32\WindowsPowerShell\v1.0\Modules\*.ps1 -Recurse | Unblock-File
Get-ChildItem C:\Windows\System32\WindowsPowerShell\v1.0\Modules\*.ps1xml -Recurse | Unblock-File
Get-ChildItem C:\Windows\System32\WindowsPowerShell\v1.0\Modules\*.psm1 -Recurse | Unblock-File

#Clear-Host

# Write-Host "Configuring Features"

# C:\Windows\System32\cmd.exe /k %windir%\System32\reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f

Write-Host "Disable Windows Defender"
'powershell "& {c:\Scripts\windows10-configuration\scripts\psh_1-disable-windows-defender.ps1}"'
Start-Sleep 10
#Clear-Host

Write-Host "Optimize Windows Update"
'powershell "& {c:\Scripts\windows10-configuration\scripts\psh_4-optimize-windows-update.ps1}"'
Start-Sleep 10
#Clear-Host

Write-Host "Block-Telemetry"
'powershell "& {c:\Scripts\windows10-configuration\scripts\psh_2-block-telemetry.ps1}"'
Start-Sleep 10
#Clear-Host

Write-Host "Fixing Privacy Settings"
'powershell "& {c:\Scripts\windows10-configuration\scripts\psh_fix-privacy-settings.ps1}"'
Start-Sleep 10
#Clear-Host

Write-Host "Disable Services"
'powershell "& {c:\Scripts\windows10-configuration\scripts\psh_3-disable-services.ps1}"'
Start-Sleep 10
#Clear-Host

Write-Host "Optimize Windows Update"
'powershell "& {c:\Scripts\windows10-configuration\scripts\psh_4-optimize-windows-update.ps1}"'
Start-Sleep 10
#Clear-Host

Write-Host "Remove One-Drive"
'powershell "& {c:\Scripts\windows10-configuration\scripts\psh_5-remove-onedrive.ps1}"'
Start-Sleep 10
#Clear-Host

Write-Host "Remove Default Apps"
'powershell "& {c:\Scripts\windows10-configuration\scripts\psh_6-remove-default-apps.ps1}"'
Start-Sleep 10
#Clear-Host

# Write-Host "Install some apps"
# .\install-basic-software.ps1
#Start-Sleep 10
# Clear-Host

Write-Host "Enable Windows Defender"
'powershell "& {c:\Scripts\windows10-configuration\scripts\psh_enable-windows-defender.ps1}"'
#Clear-Host

#If-Else statement to determine what drivers to push out
If (((Get-CimInstance -ClassName Win32_Processor | Select-Object -Property Name) -match "i7") -and ((Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property Model) -match "Precision 5520"))
  {
    $RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    set-itemproperty $RunOnceKey "NextRun" 'powershell "& {c:\scripts\psh_5520i7drivers.ps1}"'
    Start-Sleep 10
    Restart-Computer

}

ElseIf (((Get-CimInstance -ClassName Win32_Processor | Select-Object -Property Name) -match "Xeon") -and ((Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property Model) -match "Precision 5520"))
  {
    $RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    set-itemproperty $RunOnceKey "NextRun" 'powershell "& {c:\scripts\psh_5520xdrivers.ps1}"'
    Start-Sleep 10
    Restart-Computer
}
ElseIF ((Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property Model) -match "Precision 5530")
  {
    $RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    set-itemproperty $RunOnceKey "NextRun" 'powershell "& {c:\scripts\psh_5530Xdrivers.ps1}"'
    Start-Sleep 10
    Restart-Computer
}

Else
  {
    $RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    set-itemproperty $RunOnceKey "NextRun" 'powershell "& {c:\scripts\psh_updates.ps1}"'
    Start-Sleep 10
    Restart-Computer
  }
