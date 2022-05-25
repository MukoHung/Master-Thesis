Add-Type -Assembly System.Windows.Forms
$script:MainForm = New-Object System.Windows.Forms.Form
$script:MainForm.Text = ''
$script:MainForm.Width = 600
$script:MainForm.Height = 400
$script:MainForm.AutoSize = $false
$script:MainForm.TopMost = $true
$script:MainForm.FormBorderStyle = 'None'
$script:MainForm.WindowState = 'Maximized'
$script:MainForm.BackColor = 'Black'
$script:MainForm.Cursor = [System.Windows.Forms.Cursor]::Hide()
$script:ScreenInfo = [System.Windows.Forms.Screen]::AllScreens[0]
$script:ScreenWidth = $script:ScreenInfo.Bounds.Width
$script:ScreenHeight = $script:ScreenInfo.Bounds.Height

# Countdown 
$script:countdown = [System.Timespan]'00:05:00'
$script:timer = New-Object System.Windows.Forms.Timer
$script:timer.Interval = 1000
$script:timer.Start()
$script:timer.add_Tick( {
    $script:countdown -= [System.Timespan]'00:00:01'
    $script:WarningText.Text = @"
All your important files, documents, photos are encrypted with a unique key, generated for this computer. 

Do not try to exit the screen. That will shut the PC down and you may lose the keys to decrypt the system, and you cannot access your files again.

$countdown
"@
    $script:WarningText.Refresh()
}
)

# Title
$script:WarningTitle = New-Object System.Windows.Forms.Label
$script:WarningTitle.Text = "YOUR SYSTEM HAS BEEN HACKED!!!" 
$script:WarningTitle.Font = New-Object System.Drawing.Font("Arial", 20, [System.Drawing.FontStyle]::Bold)
$script:WarningTitle.ForeColor = 'Red'
[int]$script:titleHorizontalPosition = $script:ScreenWidth / 8
[int]$script:titleVerticalPosition = $script:ScreenHeight / 6
$script:WarningTitle.Location  = New-Object System.Drawing.Point($script:titleHorizontalPosition, $script:titleVerticalPosition)
$script:WarningTitle.AutoSize = $false
$script:WarningTitle.Width = $script:ScreenWidth * 0.75
$script:WarningTitle.Height = 40 
$script:WarningTitle.TextAlign = 'TopCenter'

# Text
$script:WarningText = New-Object System.Windows.Forms.Label
$script:WarningText.Text = @"
All your important files, documents, photos are encrypted with a unique key, generated for this computer. 

Do not try to exit the screen. That will shut the PC down and you may lose the keys to decrypt the system, and you cannot access your files again.

$countdown
"@
$script:WarningText.Width = $script:ScreenWidth * 0.75
$script:WarningText.Height = $script:ScreenHeight * 0.5
$script:WarningText.Enabled = $true
$script:WarningText.ForeColor = 'Red'
$script:WarningText.Font = New-Object System.Drawing.Font("Palatino Linotype",18,[System.Drawing.FontStyle]::Regular)
$script:WarningText.BorderStyle = 'None'
[int]$script:textHorizontalPosition = $script:titleHorizontalPosition
[int]$script:textVerticalPosition = $script:titleVerticalPosition + 50
$script:WarningText.Location  = New-Object System.Drawing.Point($script:textHorizontalPosition, $script:textVerticalPosition)
$script:WarningText.AutoSize = $false

$script:MainForm.Controls.Add($WarningTitle)
$script:MainForm.Controls.Add($WarningText)

# Events
$script:MainForm.add_FormClosing( {
    $script:timer.Stop()
    $script:timer.Dispose()
    Write-Output "Shut down the computer"
    # shutdown /s /t 0 /f /c "HACK SIMULATION"
}
)
$script:MainForm.add_LostFocus( {
    $script:timer.Stop()
    $script:timer.Dispose()
    Write-Output "Lost Focus. Shut down the computer"
    # shutdown /s /t 0 /f /c "HACK SIMULATION"
}
)

$script:WarningText.add_MouseClick( {
    return $null;
}
)

$script:MainForm.add_MouseClick( {
    return $null;
}
)

$script:MainForm.ShowDialog() | Out-Null