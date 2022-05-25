# Find Autoelevate executables
Write-Host "System32 Autoelevate Executables" -ForegroundColor Green -BackgroundColor Black
Select-String -Path C:\Windows\System32\*.exe -pattern "<AutoElevate>true"
Write-Host "`nSysWOW64 Autoelevate Executables" -ForegroundColor Green -BackgroundColor Black
Select-String -Path C:\Windows\SysWOW64\*.exe -pattern "<AutoElevate>true"