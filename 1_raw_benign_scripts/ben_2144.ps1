Clear-Host
Echo "Howdy..."

$WShell = New-Object -com "Wscript.Shell"

while ($true)
{
  # Shift+F15 is the key combo used by Caffeine, I prefer ScrollLock
  #$WShell.sendkeys('+{F15}')
  $WShell.sendkeys("{SCROLLLOCK}")
  Start-Sleep -Milliseconds 100
  $WShell.sendkeys("{SCROLLLOCK}")
  Start-Sleep -Seconds 240
}
