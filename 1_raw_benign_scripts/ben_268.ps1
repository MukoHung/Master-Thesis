<#

 Small Powershell ANTI-AFK Script 
 Will Slightly move your cursor +- 5 pixels from current position
 
 Usage: ./anti-afk.ps1 [MOVING_SPEED] [DURATION]
 by default, it'll move your cursor for 1 Hour at 1/3 Hertz (3 sec per cycle)
 
#>

param($sec=3, $waitInMinutes=60)

$millis = [Convert]::ToInt32($sec * 500)

$count = 0
while($count -lt $waitInMinutes * 60)
{
    Start-Sleep -Milliseconds $millis

    $pos = [System.Windows.Forms.Cursor]::Position
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($pos.X)+3), $pos.Y)

    Start-Sleep -Milliseconds $millis

    $pos = [System.Windows.Forms.Cursor]::Position
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($pos.X)-3), $pos.Y)
    
    $count += $sec
}