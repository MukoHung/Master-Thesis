#https://twitter.com/guyrleech/status/1322118170002468864
Start-Job -Name "Logoff when done" { sleep (("23:59 30/10/2020" -as [datetime]) - (date)).TotalSeconds ; logoff }