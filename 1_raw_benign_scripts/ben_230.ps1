<#
.SYNOPSIS
 
.DESCRIPTION
	This script add WiFi Profile to (first) WLAN Adapter. Password in profile should be in plain text
 
.PARAMETER <Parameter_Name>
 
.INPUTS
	Path to WiFi Profile
 

.NOTES
    Version:        1.0
    Author:	Robert Rajakone
    Creation Date:	23. August 2013
    Purpose/Change: Initial script development
 
.EXAMPLE
	Add_Wifi_Profile.ps1 "\\domain.local\netlogon\scripts\wifi_profile.xml"
 
#>

Param(
	[Parameter(Mandatory=$true)] [string] $PathToProfileXML
)
Write-Host ""
Write-Host ""
Write-Host ""

$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if(-not($IsAdmin)){
	throw "Current User has no administrative rights. Restart script as administrator."
}
		


if(-not(Test-Path $PathToProfileXML)){
	throw "Profile file do not exist at give path: $PathToProfileXML"
}

$strDump=netsh wlan show interfaces
$strNameDump = $strDump[3]
$Result = [regex]::match($strNameDump, "^.*Name.*: (.*)$")
$WirlessAdapterName = $Result.Groups[1].Value

if($WirlessAdapterName){
	Write-Host "Adapter found: $WirlessAdapterName"	
	Write-Host ""
	Write-Host "Trying to add Profile"
	Write-Host $PathToProfileXML
	netsh wlan add profile filename=$PathToProfileXML interface="$WirlessAdapterName"
}else{
	Write-Host "No WiFi Adapter found" -ForegroundColor Red
}
