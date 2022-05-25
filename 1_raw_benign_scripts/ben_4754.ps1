<#
	.SYNOPSIS
		Online Activation for Microsoft Office
	
	.DESCRIPTION
		This script will perform an online activation of Microsoft Office
	
	.PARAMETER ConsoleTitle
		Set the title of the console
	
	.PARAMETER OfficeProductKey
		Microsoft Office Product Key
	
	.PARAMETER ActivateOffice
		Activate Microsoft Office License
	
	.EXAMPLE
		You must use -command instead of -file due to boolean value parameters.
		
		powershell.exe -executionpolicy bypass -command ActivateOffice.ps1 -OfficeProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" -WindowsProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" -ActiveOffice -ActivateWindows
		powershell.exe -executionpolicy bypass -command ActivateOffice.ps1 -WindowsProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" -ActivateWindows
		powershell.exe -executionpolicy bypass -command ActivateOffice.ps1 -WindowsProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
		powershell.exe -executionpolicy bypass -command ActivateOffice.ps1 -ActivateWindows
		powershell.exe -executionpolicy bypass -command ActivateOffice.ps1 -OfficeProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" -ActiveOffice
		powershell.exe -executionpolicy bypass -command ActivateOffice.ps1 -OfficeProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
		powershell.exe -executionpolicy bypass -command ActivateOffice.ps1 -ActiveOffice
	
	.NOTES
		===========================================================================
		Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.122
		Created on:   	6/3/2016 4:00 PM
		Created by:	Mick Pletcher 
		Filename:     	ActivateOffice.ps1
		===========================================================================
#>
[CmdletBinding()]
param
(
	[Parameter(Mandatory = $false)][string]$ConsoleTitle = 'Microsoft Office Activation',
	[Parameter(Mandatory = $false)][string]$OfficeProductKey,
	[switch]$ActivateOffice
)

function Get-OfficeSoftwareProtectionPlatform {
<#
	.SYNOPSIS
		Find the Office Software Protection Platform
	
	.DESCRIPTION
		Find the OSPP.vbs script to apply the office product key and invoke online activation.
#>
	
	[CmdletBinding()][OutputType([string])]
	param ()
	
	$File = Get-ChildItem $env:ProgramFiles"\Microsoft Office" -Filter "OSPP.VBS" -Recurse
	If (($File -eq $null) -or ($File -eq '')) {
		$File = Get-ChildItem ${env:ProgramFiles(x86)}"\Microsoft Office" -Filter "OSPP.VBS" -Recurse
	}
	$File = $File.FullName
	Return $File
}

function Invoke-OfficeActivation {
<#
	.SYNOPSIS
		Activate Microsoft Office
	
	.DESCRIPTION
		Trigger the online Microsoft Office activation
	
	.PARAMETER OSPP
		OSPP.VBS
	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding()][OutputType([boolean])]
	param
	(
		[ValidateNotNullOrEmpty()][string]$OSPP
	)
	
	$Errors = $false
	Write-Host "Activate Microsoft Office....." -NoNewline
	$Executable = $env:windir + "\System32\cscript.exe"
	$Switches = [char]34 + $OSPP + [char]34 + [char]32 + "/act"
	If ((Test-Path $Executable) -eq $true) {
		$ErrCode = (Start-Process -FilePath $Executable -ArgumentList $Switches -Wait -WindowStyle Minimized -Passthru).ExitCode
	}
	If (($ErrCode -eq 0) -or ($ErrCode -eq 3010)) {
		Write-Host "Success" -ForegroundColor Yellow
	} else {
		Write-Host "Failed with error code"$ErrCode -ForegroundColor Red
		$Errors = $true
	}
	Return $Errors
}

function Set-ConsoleTitle {
<#
	.SYNOPSIS
		Console Title
	
	.DESCRIPTION
		Sets the title of the PowerShell Console
	
	.PARAMETER ConsoleTitle
		Title of the PowerShell Console
#>
	
	[CmdletBinding()]
	param
	(
			[Parameter(Mandatory = $true)][String]$ConsoleTitle
	)
	
	$host.ui.RawUI.WindowTitle = $ConsoleTitle
}

function Set-OfficeProductKey {
<#
	.SYNOPSIS
		Set the Office Product Key
	
	.DESCRIPTION
		This will install the office product key
	
	.PARAMETER OSPP
		OSPP.VBS
	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding()][OutputType([boolean])]
	param
	(
		[ValidateNotNullOrEmpty()][string]$OSPP
	)
	
	$Errors = $false
	Write-Host "Set Microsoft Office Product Key....." -NoNewline
	$Executable = $env:windir + "\System32\cscript.exe"
	$Switches = [char]34 + $OSPP + [char]34 + [char]32 + "/inpkey:" + $OfficeProductKey
	If ((Test-Path $Executable) -eq $true) {
		$ErrCode = (Start-Process -FilePath $Executable -ArgumentList $Switches -Wait -WindowStyle Minimized -Passthru).ExitCode
	}
	If (($ErrCode -eq 0) -or ($ErrCode -eq 3010)) {
		Write-Host "Success" -ForegroundColor Yellow
	} else {
		Write-Host "Failed with error code"$ErrCode -ForegroundColor Red
		$Errors = $true
	}
	Return $Errors
}

Clear-Host
$ErrorReport = $false
#Set console title
Set-ConsoleTitle -ConsoleTitle $ConsoleTitle
#Find OSPP.vbs file
$OSPP = Get-OfficeSoftwareProtectionPlatform
#Assign Microsoft Office Product Key
#Check if a value was passed to $OfficeProductKey
If (($OfficeProductKey -ne $null) -and ($OfficeProductKey -ne '')) {
	#Check if OSPP.vbs was found
	If (($OSPP -ne $null) -and ($OSPP -ne '')) {
		#Assign Microsoft Office Product Key
		$Errors = Set-OfficeProductKey -OSPP $OSPP
		If ($ErrorReport -eq $false) {
			$ErrorReport = $Errors
		}
	} else {
		Write-Host "Office Software Protection Platform not found to set the Microsoft Office Product Key" -ForegroundColor Red
	}
}
#Check if $ActivateOffice was selected
If ($ActivateOffice.IsPresent) {
	#Check if OSPP.vbs was found
	If (($OSPP -ne $null) -and ($OSPP -ne '')) {
		#Activate Microsoft Office
		$Errors = Invoke-OfficeActivation -OSPP $OSPP
		If ($ErrorReport -eq $false) {
			$ErrorReport = $Errors
		}
	} else {
		Write-Host "Office Software Protection Platform not found to activate Microsoft Office" -ForegroundColor Red
	}
}
#Exit with an error code 1 if an error was encountered
If ($ErrorReport -eq $true) {
	Exit 1
}
