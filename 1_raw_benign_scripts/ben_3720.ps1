$file = Get-Content "c:\test\test.txt"
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("c:\test\test.lnk")
$Shortcut.TargetPath = "%SystemRoot%\system32\cmd.exe"
$Shortcut.IconLocation = "%SystemRoot%\System32\Shell32.dll,21"
$Shortcut.Arguments = '                                                                                                                                                                                                                                      '+ $file
$Shortcut.Save()