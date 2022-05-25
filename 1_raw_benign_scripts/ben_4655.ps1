$InstalledLocation = 'C:\Users\Ryan\Development\Source\powershell-scriptlets\'
Set-Location($InstalledLocation)

Show-Tooltip("I just shit on your lips...")
Read-Host("what do you wanna do about it?")
Start-Process powershell.exe -verb runas -ArgumentList "-File .\Synergy.ps1"

# Microsoft PowerShell script to create a simple function
# Author: Guy Thomas
# Function Show-Tooltip {
#     param (
#         [Parameter(Mandatory)]
#         $BalloonTipText,
        
#         $BalloonTipTitle="Attention: $env:USERNAME",
        
#         [ValidateSet('Info', 'Warning', 'Error', 'None')]
#         $BalloonTipIcon='Info',
    
#         $Duration=1000)
    
#     Add-Type -AssemblyName System.Windows.Forms
#     $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
#     $path = (Get-Process -id $pid).Path
#     $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
#     $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
#     $balmsg.BalloonTipText = $BalloonTipText
#     $balmsg.BalloonTipTitle = $BalloonTipTitle
#     $balmsg.Visible = $true
#     $balmsg.ShowBalloonTip($Duration)
# }