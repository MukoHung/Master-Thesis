###############################################################################
# Filename: elevate.ps1
# Version: 0.2
# Authors: https://social.msdn.microsoft.com/profile/Benjamin+Armstrong
# References: https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/
# Updated: Yes (alex1a)
# Description: Script that open a new window “as Administrator” (with an appropriate prompt).
###############################################################################

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
}

# Inicialization
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptPath1 = split-path -parent $scriptPath
$scriptPath2 = split-path -parent $scriptPath1
$myCommandPath = $MyInvocation.MyCommand.Path
$myCommandName = $MyInvocation.MyCommand.Name
$getLocation = (Get-Location)

# Information
Write-Host "MyCommand.Path: " $myCommandPath
Write-Host "MyCommand.Name: " $myCommandName
Write-Host $scriptPath
Write-Host $scriptPath1
Write-Host $scriptPath2
Write-Host ("CD: {0}, {1}" -f $getLocation,$PSScriptRoot)

# Env Variables
Write-Host ("`nEnv:WINDIR: {0}" -f $env:WINDIR)
Write-Host ("Env:APPDATA: {0}" -f $env:APPDATA)
Write-Host ("Env:COMSPEC: {0}" -f $env:COMSPEC)
Write-Host ("Env:PATH: {0}" -f $env:PATH)
Write-Host ("Env:PATHEXT: {0}" -f $env:PATHEXT)
Write-Host ("Env:USERPROFILE: {0}" -f $env:USERPROFILE)

# Colors
#[Enum]::GetValues([System.ConsoleColor])
#$colors = [enum]::GetValues([System.ConsoleColor])
#Foreach ($bgcolor in $colors){
#    Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
#    Write-Host " on $bgcolor"
#}

# System
#[System.Environment]::OSVersion.Version
#[System.Environment]::Is64BitProcess
#Write-Host "PSVersionTable: " $PSVersionTable.PSVersion
#Get-Host

# Test Registry
#Test-Path 'HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\1\Install'
#Test-Path 'HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\1\Install2'
#Test-Path 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\3'

$fileTest1 = "C:\cygwin64\setup-x86_64.exe"
Write-Host ("`n{0}: " -f $fileTest1); Test-Path $fileTest1
$fileTest2 = "C:\MinGW\bin\mingw32-gcc.exe"
Write-Host ("{0}: " -f $fileTest2); Test-Path $fileTest2
$fileTest3 = "C:\Program Files\mingw-w64"
Write-Host ("{0}: " -f $fileTest3); Test-Path $fileTest3
$fileTest4 = "C:\Program Files\Git\git-bash.exe"
Write-Host ("{0}: " -f $fileTest4); Test-Path $fileTest4
$fileTest5 = "C:\Program Files\Git\git-cmd.exe"
Write-Host ("{0}: " -f $fileTest5); Test-Path $fileTest5

# Installed Software
#Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -Wrap -AutoSize -Property DisplayName,DisplayVersion,Publisher,InstallDate
Write-Host "`nwhich:"
which bash
which cmd
which powershell
#C:\cygwin64

# Calling script
#& "$ScriptPath\MyScript1.ps1"
Write-Host "`nCalling Test-Suite script ..."
#echo Starting %LocalSourcePsDir%\win_testsuite.ps1 ...
#PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%LocalSourcePsDir%\win_testsuite.ps1""' -Verb RunAs}";
$includeScript = "$scriptPath2\include\ps\shell.ps1"
$includeScript2 = (Split-Path -parent $includeScript)
Write-Host ("BLABLABLA: {0}" -f $includeScript)
Write-Host ("BLABLABLA2: {0}" -f $includeScript2)
Push-Location (Split-Path -parent $includeScript)
"shell" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Write-Host $promptchar

# Run your code that needs to be elevated here
Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")