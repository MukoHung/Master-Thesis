This script will completely reset the Windows Update client settings. It has been tested on Windows 7, 8, 10, and Server 2012 R2. It will configure the services and registry keys related to Windows Update for default settings. It will also clean up files related to Windows Update, in addition to BITS related data. Because of some limitations of the cmdlets available in PowerShell, this script calls some legacy utilities (sc.exe, netsh.exe, wusa.exe, etc). If you have any issues with this script, please comment. 

Script made by Ryan Nemeth

Source: https://archive.is/tYKkN