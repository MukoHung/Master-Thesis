
<#
.SYNOPSIS
    Client script to write Server specific Variables into Memory and Trigger a Controller Script

.DESCRIPTION
    This script is a Client script that writes Server specific Variables into Memory and Trigger a Controller Script on a Windows Server for Quintiq Services to Test/Start/Stop. The File-name must be specified as "servername_[test/up/down].ps1":

	1. Client File Variables: Enter this scripts File name (e.g. server01_test.ps1)
	2. Server Variables: Enter the corresponding Server-name of this script (e.g. server01)
	3. Controller Variables: Enter the objective Controller script (e.g. qservices_test.ps1)
	4. Action Variables: Enter the preferred State (e.g. Test/Start/Stop)
	5. Service Variables: Enter the preferred Services (use serial numbers to describe Action sequence)

.NOTES
    Author: Floris Bechger
	E-mail: floris.bechger@gmail.com
    Last Edit: 2020-12-09
    Version 1.0 - initial release of Service Script
#>

## Elevate privileges ##
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

## Load and Write Global Variables ##
. .\qservices_variables.ps1
Write-Host "$Admin $Domain $ShareFolder $DesktopFolder $ScriptFolder $LogFolder $Date $Time $StartTime"

## 1. Client File Variables (laptopf) ##
Set-Variable -Name ClientScript -Value laptop_test.ps1 -Scope Global -ErrorAction SilentlyContinue

## 2. Server Variables (laptopf) ##
Set-Variable -Name Server -Value laptopf -Scope Global -ErrorAction SilentlyContinue # (DV)

## 3. Controller Variables ##
Set-Variable -Name MainScript -Value qservices_test.ps1 -Scope Global -ErrorAction SilentlyContinue

## 4. Action Variables ##
Set-Variable -Name State -Value TEST -Scope Global -ErrorAction SilentlyContinue

## 5. laptopf Service Variables (UP) ##
Set-Variable -Name Service01 -Value diagnosticshub.standardcollector.service -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Wait01 -Value 0 -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Service02 -Value diagsvc -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Wait02 -Value 0 -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Service03 -Value HvHost -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Wait03 -Value 0 -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Service04 -Value IJPLMSVC -Scope Global -ErrorAction SilentlyContinue # default on
Set-Variable -Name Wait04 -Value 0 -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Service05 -Value Spooler -Scope Global -ErrorAction SilentlyContinue # default on
Set-Variable -Name Wait05 -Value 0 -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Service06 -Value VBoxSDS -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Wait06 -Value 0 -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Service07 -Value W32Time -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Wait07 -Value 0 -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Service08 -Value wuauserv -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name Wait08 -Value 0 -Scope Global -ErrorAction SilentlyContinue

## Run Main Script ##
$File = Get-Content "$Admin\$DesktopFolder\$ScriptFolder\$ClientScript"
$Command = "$Admin\$DesktopFolder\$ScriptFolder\$MainScript"
Invoke-Expression -Command "$Command"

## End Script
