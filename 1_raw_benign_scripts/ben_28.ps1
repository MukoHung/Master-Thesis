# There are Two PowerShells these days
# Windows PowerShell which we have known for many years 
# (v1,v2,v3,v4,v5,v5.1) http://www.informit.com/articles/article.aspx?p=2324463
#   
#   v1 - November 2006 - Windows Server 2003, Windows Server 2008, Windows XP SP2, Windows Vista
#
#   v2 - October 2009 - Windows Server 2008 R2, Windows 7
#   remoting, jobs, modules
#
#   v3 - September 2012 - Windows Server 2012, Windows 8
#   Updatable help, code completion, snippets, resumable sessions
#
#   v4 - October 2013 - Windows Server 2012 R2, Windows 8.1
#   Desired State Configuration, exportable help, Where and ForEach methods support network diagnostics
#
#   v5 - February 2016 - Windows 10
#   Classes, Updated DSC, 
#
#   v5.1 - January 2017 - Windows 10 Anniversary Update Windows Server 2016
#   Get-ComputerInfo, Get-LocalGroup, Get-LocalUser, Improvements to DSC debugging adn Package Management
#
#   v6 - GA - 10 January 2018 - All of the OS's ;-)
#   Open Source, Cross-Platform, side by side installation - 6 monthly minor version release cycle from now on :-)
#
#
# Choose PowerShell 5.1 in menu bottom right

$PSVersionTable | clip

# and PowerShell Core 

# Choose PowerShell 6.1 in menu bottom right XXXXX CHECK version

$PSVersionTable | clip

# So there are a few differences

# In PowerShell (v6) there are a few more default variables.

$PSEdition

$IsCoreCLR

$IsLinux

$IsMacOS

$IsWindows

# No more WMI commands - But you should be using CIM now anyway
# So no more Get-WMIObject -ClassName win32_logicaldisk
Get-CimInstance -ClassName win32_logicaldisk

# Its side by side installation 
# Windows PowerShell in C:\Windows\System32\WindowsPowerShell\v1.0
# v6 
Get-ChildItem 'C:\Program Files\PowerShell'

# some commands have extra output
# Run get-verb in v6 and v5

