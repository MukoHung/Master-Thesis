# Author: Simone Roberto Nunzi aka (Stockmind)
# Date: 2018/01/03
# Purpouse: Enable Hyper-V in Windows 10 and add a No Hyper-V boot entry to Windows boot loader
# References:
# https://blogs.msdn.microsoft.com/virtual_pc_guy/2008/04/14/creating-a-no-hypervisor-boot-entry/
# https://stackoverflow.com/questions/35479080/how-to-turn-windows-feature-on-off-from-command-line-in-windows-10
# https://stackoverflow.com/questions/16903460/bcdedit-bcdstore-and-powershell
#
# Launch PowerShell with administrative rights issuing Windows X + A

# Enable Hyper-V feature in Windows
dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All

# Get current boot option description
$currentdescription = bcdedit /enum |
  Select-String "path" -Context 2,1 |
  Where-Object { $_.Context.PreContext[0] -Match "{current}" } |
  ForEach-Object { $_.Context.PostContext[0] -replace '^[\w]* +' }

# Append "No Hyper-V" to description
$newlabel = "$($currentdescription) - No Hyper-V"

# Copy current boot entry with new name
bcdedit /copy '{current}' /d $newlabel

# List all the boot entries
# Then select only the ones with "path" defined (real boot options)
# Then look for the one with "No Hyper-V" in the description
# Then take the first line (indentifier) and remove everything before the real "id" (we remove the label)
# We could have used regex '^identifier +' to remove the label but
# in PowerShell the labels are translated, so in different laguages systems "identifier" label may be different
$newbootid = bcdedit /enum |
  Select-String "path" -Context 2,1 |
  Where-Object { $_.Context.PostContext[0] -Match $newlabel } |
  ForEach-Object { $_.Context.PreContext[0] -replace '^[\w]* +' }

# Disable Hyper-V for the new boot entry
bcdedit /set $newbootid hypervisorlaunchtype off