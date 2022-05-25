# $InstalledLocation = 'C:\Users\Ryan\Development\Source\powershell-scriptlets\'
# Set-Location($InstalledLocation)

.\Show-ToolTip.ps1 "Starting Synergy service...`n`n(Say goodbye to your system resources)"
$Service = Get-Service -Name Synergy
$Service.Start()
$Service.WaitForStatus("Running")
#.\Show-ToolTip.ps1 "Synergy service started. Starting Synergy..."
Start-Process -FilePath "C:\Program Files\Synergy\synergy.exe"
$SynergyProcess = Get-Process synergy
Wait-Process -Id $SynergyProcess.Id
#.\Show-ToolTip.ps1 "Synergy Closed. Stopping Synergy service..."
Stop-Service -Name Synergy
.\Show-ToolTip.ps1 "Synergy service stopped.`n`n(Enjoy your reclaimed system resources)"
