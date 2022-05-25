# .PARAMETER WriteOnceTips
# printed at least once tips
Param (
  [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
  [switch]
  $WriteOnceTips = $False
)

function Write-Tips {
  Param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [array]
    $Tips,
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [switch]
    $Flag = $global:WriteOnceTips
  )

  $global:WriteOnceTips = $True

  if ($Flag) {
    Write-Host "`n��" -ForegroundColor Gray -NoNewLine
  } else {
    Write-Host "��" -ForegroundColor Gray -NoNewLine
  }

  Write-Host " $($Tips[0])" -ForegroundColor Cyan -NoNewLine
  Write-Host " $($Tips[1])" -ForegroundColor White -NoNewLine
  Write-Host " ... " -ForegroundColor Gray -NoNewLine
}


$systemPath = "${PSScriptRoot}\system"
$appsPath   = "${PSScriptRoot}\apps"


# system configuration
Write-Tips 'rename', 'Computer Name'
. "${systemPath}\ComputerName\_restore.ps1"

Write-Tips 'setting', 'partition DriveLetter and Volume'
. "${systemPath}\Disk\_restore.ps1"

Write-Tips 'create', 'applications shortcut'
. "${systemPath}\CreateShortcut\_restore.ps1"

Write-Tips 'restore', 'Notifications Action Center'
. "${systemPath}\Notifications_Action_Center\_restore.ps1"

Write-Tips 'restore', 'StartLayout'
. "${systemPath}\StartLayout\_restore.ps1" -NoRestart

Write-Tips 'setting', 'Taskbar'
. "${systemPath}\Taskbar\_restore.ps1" -NoRestart

Write-Tips 'setting', 'Desktop Icons'
. "${systemPath}\DesktopIcons\_restore.ps1" -NoRestart

Write-Tips 'setting', 'Windows Explorer'
. "${systemPath}\Explorer\_restore.ps1" -NoRestart

Write-Tips 'setting', 'Language'
. "${systemPath}\Language\_restore.ps1"

# restart Windows Explorer
Stop-Process -Name 'explorer'

Write-Tips 'setting', 'UTC'
. "${systemPath}\Time\_UTC.ps1"

Write-Tips 'add', 'Time Zone Clock'
. "${systemPath}\Time\_AddClock.ps1"

Write-Tips 'remove', 'appx'
. "${systemPath}\Appx\_remove.ps1"

Write-Tips 'setting', 'OneDrive'
. "${systemPath}\OneDrive\_restore.ps1"

Write-Tips 'restore', 'TaskManager'
. "${systemPath}\TaskManager\_restore.ps1"

Write-Tips 'install', 'Fonts'
. "${systemPath}\Fonts\_install.ps1"

Write-Tips 'setting', 'Command Prompt and PowerShell'
. "${systemPath}\Shell\_restore.ps1" -Silent
. "${systemPath}\Shell\PSShortcut.ps1" -Action 'Restore'

Write-Tips 'enable', 'Microsoft Windows Subsystem Linux'
. "${systemPath}\WSL\_restore.ps1"

Write-Tips 'restore', 'Windows Terminal'
. "${systemPath}\Terminal\_restore.ps1"

# apps configuration
Write-Tips 'setting', 'Shadowsocks'
. "${appsPath}\Shadowsocks\_restore.ps1"

Write-Tips 'setting', 'Sublime Text'
. "${appsPath}\SublimeText\_restore.ps1"

Write-Tips 'setting', '7-Zip'
. "${appsPath}\7-Zip\_restore.ps1"

Write-Tips 'setting', 'WinRAR'
. "${appsPath}\WinRAR\_restore.ps1"

Write-Tips 'setting', 'Steam'
. "${appsPath}\Steam\_restore.ps1"

Write-Tips 'setting', 'BaiduNetdisk'
. "${appsPath}\BaiduNetdisk\_restore.ps1"

Write-Tips 'setting', 'ASUS apps'
. "${appsPath}\ASUS\_disable.ps1"
