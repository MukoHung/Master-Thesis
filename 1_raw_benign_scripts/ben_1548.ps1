CLS

#..............................................................................

#..............................................................................
Function Get-IPAddress($ComputerName)
{
    if($ComputerName -match "3D-PRINTER") {Return "192.168.1.227"}
}
#..............................................................................

#..............................................................................

$ReportPath      = "\IT Management\Reports\Systems"
$SourcePath      = "\IT Management\Powershell\Powershell Scripts\Reporting"
$ComputerName    = $env:COMPUTERNAME
$CurrentDateTime = $((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))
$CurrentLocation = Get-Location
$NASAddress      = "192.168.1.169"
$IPAddress       = Get-IPAddress($ComputerName)

$OutputPath = "\\" + $NASAddress + $ReportPath + '\' + $Env:COMPUTERNAME + ' - ' + $IPAddress + '\' + $CurrentDateTime

$SourcePath = "\\" + $NASAddress + $SourcePath

#..............................................................................

#..............................................................................

Write-Host "Generating Reports For: $ComputerName..."

Write-Host "Creating Report Folder: $OutputPath"
New-Item -ItemType Directory -Path $OutputPath | Out-Null

Write-Host "Setting Output Path To: $OutputPath"
Set-Location $OutputPath

#..............................................................................

#..............................................................................
Write-Host "Getting System Bad Devices Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-bad-devices.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting System BIOS Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-bios.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting System Computer Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-computer.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting System Culture Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-culture.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting System Drives Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-drives.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting System Environment Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-environment.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting Installed Software Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-installed-software.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting System Memory Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-memory.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting Miscellaneous System Reports..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-misc.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting System Network Adaptors Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-network-adaptors.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting System OS Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-os.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting System PNP Devices Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-pnp-devices.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting System Processors Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-processors.ps1"
#..............................................................................

#..............................................................................
Write-Host "Getting USB Devices Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-usb-devices.ps1"
#..............................................................................

#..............................................................................

Write-Host "Getting Printers Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\system-printers.ps1"
#..............................................................................

#..............................................................................

Write-Host "Getting System Threat Report..."

PowerShell.exe -ExecutionPolicy Bypass -File "$SourcePath\windows-defender-threats.ps1"
#..............................................................................

#..............................................................................

Set-Location $CurrentLocation
    
Write-Host "All done!"
