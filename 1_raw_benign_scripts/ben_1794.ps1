Register-ScheduledTask `
 -Action (New-ScheduledTaskAction `
           -Execute ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe")."(default)") `
           -Argument 'https://github.com/trending') `
 -Trigger (New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 3am) `
 -TaskName "GitHub Trending" `
 -Description "Weekly check of GitHub trending repos."