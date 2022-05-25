Summary
---
PowerShell script set WindowsDefender Exclusions policy.
This script intended for using with Window 8 Hyper-V.

Note
----
WindowsDefender settings stored at "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions"
but this registry entry is protected, and it can't modify from script by default.
Instead, This script WindowsDefender's *policy* registry entry at "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions"

Please note, policy settings can't removed WidowsDefender Console.

Usage
-----
``` powershell
#Add WindowsDefender Policy
Add-WindowsDefenderExclusionsPolicy

#Need to Restart WindowsDefender to apply policy
```

``` powershell
#Remove WindowsDefender Policy
Remove-WindowsDefenderExclusionsPolicy

#Need to Remove entry from WindowsDefender Console
```


