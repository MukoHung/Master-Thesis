Write-Host "Attempting to mount default registry hive"

& REG LOAD HKLM\DEFAULT C:\Users\Default\NTUSER.DAT
Push-Location 'HKLM:\DEFAULT\Software\Microsoft\Internet Explorer'
if (!(Test-Path Main)) {
  Write-Warning "Adding missing default keys for IE"
  New-Item Main
}
$sp = Get-ItemProperty -Path .\Main
Write-Host "Replacing $_ : $($sp.'Start Page')"
Set-ItemProperty -Path .\Main -Name "Start Page" -Value $site
Pop-Location
$unloaded = $false
$attempts = 0
while (!$unloaded -and ($attempts -le 5)) {
  [gc]::Collect() # necessary call to be able to unload registry hive
  & REG UNLOAD HKLM\DEFAULT
  $unloaded = $?
  $attempts += 1
}
if (!$unloaded) {
  Write-Warning "Unable to dismount default user registry hive at HKLM\DEFAULT - manual dismount required"
}