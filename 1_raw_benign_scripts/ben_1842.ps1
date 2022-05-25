#Requires -RunAsAdministrator

#Create shortcut with target : C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -File "K:\miHoYo\Honkai Impact 3rd\HonkaiLauncher.ps1"

$currentDir = (Split-Path $script:MyInvocation.MyCommand.Path)

$originalCulture = Get-Culture

Set-Culture 'en-GB'

& "$currentDir\falcon_glb.exe"

Start-Sleep -Seconds 3

Wait-Process -InputObject (Get-Process falcon_glb)

Set-Culture $originalCulture