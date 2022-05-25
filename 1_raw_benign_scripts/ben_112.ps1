# A Windows PowerShell drive is a data store location that you can access like a file system drive in Windows PowerShell.
# Such drives are file system drives (including C: and D:), the registry drives (HKCU: and HKLM:), and the certificate drive (Cert:), and you can create your own Windows PowerShell drives.

#
# Using PowerShell drives
#

# List available PowerShell drives
Get-PSDrive

# Check syntax
Get-Command -Name Get-PSDrive -Syntax

# Display only the Windows PowerShell drives that are supported by the Windows PowerShell FileSystem provider
Get-PSDrive -PSProvider FileSystem

# View the Windows PowerShell drives that represent registry hives
Get-PSDrive -PSProvider Registry

# Standard Location cmdlets can be used with the Windows PowerShell drives
Set-Location HKLM:\SOFTWARE
Push-Location .\Microsoft
Get-Location

#
# Adding New Windows PowerShell Drives (New-PSDrive)
#

# Get syntax of New-PSDrive cmdlet
Get-Command -Name New-PSDrive -Syntax

# Create a drive named "Office" that is mapped to the folder that contains the Microsoft Office applications on your computer
New-PSDrive -Name Office -PSProvider FileSystem -Root "C:\Program Files\Microsoft Office\OFFICE11"

# To view and change items in the CurrentVersion registry key, you can create a Windows PowerShell drive that is rooted in that key
New-PSDrive -Name cvkey -PSProvider Registry -Root HKLM\Software\Microsoft\Windows\CurrentVersion
Set-Location cvkey: -PassThru

# NOTE: The New-PsDrive cmdlet adds the new drive only to the current Windows PowerShell session. If you close the Windows PowerShell window, the new drive is lost. To save a Windows PowerShell drive, use the Export-Console cmdlet to export the current Windows PowerShell session,
#       and then use the PowerShell.exe PSConsoleFile parameter to import it. Or, add the new drive to your Windows PowerShell profile.

#
# Deleting Windows PowerShell Drives (Remove-PSDrive)
#

# Deleted added Office and cvkey drives
Remove-PSDrive -Name Office
Remove-PSDrive -Name cvkey