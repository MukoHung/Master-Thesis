$rl = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 252950"
$uninstall = $rl.UninstallString.Replace('"', '')
Invoke-Expression $uninstall