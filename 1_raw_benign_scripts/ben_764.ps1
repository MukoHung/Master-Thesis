<#
 	.NOTES
 		============================================================================================================
		Copyright (c) Microsoft Corporation. All rights reserved.

		File:		PS.Module.Update.ps1

		Purpose:	PowerShell Module Update Script
		
		Version: 	1.0.0.0 - 1st February 2019 - Build Release Deployment Team
	============================================================================================================

 	.SYNOPSIS
		PowerShell Module Update Script

 	.DESCRIPTION
		This script is used to update PowerShell Modules

		Run these commands if there is an issue with the PSRepository
			Get-PSRepository
			Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

	.PARAMETER ModuleNames
		Specify the Names of the PowerShell Modules.

	.EXAMPLE
		C:\PS>  .\PS.Module.Update.ps1 -ModuleNames "Pester","PSScriptAnalyzer"
 	
#>

#Requires -Version 5

#region - Global Variables
[CmdletBinding()]
param
(
	[Parameter(Mandatory = $true, Position = 1)]
	[ValidateNotNullOrEmpty()]
	[string[]]$ModuleNames
)

$script:Path = Get-Location
$script:ERRORLEVEL = -1
#endregion

#region - Functions
function Get-IsElevated
{
<#
	.SYNOPSIS
		Checks if the script is in an elevated Powershell Session

	.DESCRIPTION
		Gets the ID and security principal of the current user account
		Gets the security principal for the Administrator role
		Checks to see if currently running "as Administrator"

	.OUTPUTS
		Return [True/False]

	.NOTES
#>
	try
	{
		$WindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
		$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($WindowsID)
		$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
		
		if ($WindowsPrincipal.IsInRole($adminRole))
		{
			return $true
		}
		else
		{
			return $false
		}
	}
	catch [system.exception]
	{
		$paramWriteHost = @{
			Object = "Error in Get-IsElevated() $($psitem.Exception.Message) Line:$($psitem.InvocationInfo.ScriptLineNumber) Char: $($psitem.InvocationInfo.OffsetInLine)"
			ForegroundColor = 'Red'
		}
		Write-Host @paramWriteHost
		if ($DebugLogging) { Stop-Transcript }
		exit $ERRORLEVEL
	}
}

function Enable-PSModuleUpdate
{
<#
	.SYNOPSIS
		Updates Powershell Module

	.DESCRIPTION
		The function uses the Get-Module Cmdlet to locate the Powershell ModuleName passed.
		If the Module Name exist the module version is checked against the PowerShell Gallery
		If a new version is available it is Installed
		The Import-Module Cmdlet is used to load the Powershell Module

	.PARAMETER ModuleName
		Name of the PowerShell Module

	.OUTPUTS

	.NOTES

#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]$Module
	)
	
	try
	{
		$Update = Get-Module -listavailable | Where-Object { $psitem.Name -eq "$Module" }
		
		if ($Update)
		{
			$UpdateName = $Update.Name
			$UpdateVersion = $Update.Version
			
			$paramWriteHost = @{
				Object = " Checking for the latest $UpdateName PowerShell Module, Current installed versions $UpdateVersion"
				ForegroundColor = 'Cyan'
			}
			Write-Host @paramWriteHost
			
			$paramFindModule = @{
				Name	    = $UpdateName
				ErrorAction = 'Stop'
			}
			$Repo = Find-Module @paramFindModule
			$RepoVersion = $Repo.Version
			
			if ($RepoVersion -ne $UpdateVersion)
			{
				$paramCompareObject = @{
					ReferenceObject  = $Update
					DifferenceObject = $Repo
					Property		 = 'Name', 'Version'
				}
				$Compare = Compare-Object @paramCompareObject | Where-Object SideIndicator -eq '=>'
				
				if ($Compare)
				{
					$paramWriteHost = @{
						Object = " Installing latest $UpdateName PowerShell Module Version $RepoVersion"
						ForegroundColor = 'Cyan'
					}
					Write-Host @paramWriteHost
					
					$paramInstallModule = @{
						Name			   = $UpdateName
						SkipPublisherCheck = $true
						Force			   = $true
						ErrorAction	       = 'Stop'
					}
					Install-Module @paramInstallModule | Out-Null
					
					$paramWriteHost = @{
						Object = " Un-Installing $UpdateName PowerShell Module Version $UpdateVersion"
						ForegroundColor = 'Cyan'
					}
					Write-Host @paramWriteHost
					
					$paramUninstallModule = @{
						Name		   = $UpdateName
						MinimumVersion = $UpdateVersion
						Force		   = $true
						ErrorAction    = 'Stop'
					}
					Uninstall-Module @paramUninstallModule | Out-Null
					
					$paramImportModule = @{
						Name		   = $UpdateName
						MinimumVersion = $RepoVersion
						Force		   = $true
						ErrorAction    = 'Stop'
					}
					Import-Module @paramImportModule
					
					$paramWriteHost = @{
						Object = "$UpdateName version $RepoVersion PowerShell Module Loaded"
						ForegroundColor = 'Green'
					}
					Write-Host @paramWriteHost
				}
			}
			else
			{
				$paramImportModule = @{
					Name		   = $UpdateName
					MinimumVersion = $RepoVersion
					Force		   = $true
					ErrorAction    = 'Stop'
				}
				Import-Module @paramImportModule
				
				$paramWriteHost = @{
					Object = "$UpdateName version $RepoVersion PowerShell Module Loaded"
					ForegroundColor = 'Green'
				}
				Write-Host @paramWriteHost
			}
		}
		else
		{
			$paramWriteHost = @{
				Object = " Cannot find $Module PowerShell Module Installed"
				ForegroundColor = 'Yellow'
			}
			Write-Host @paramWriteHost
			
			$paramFindModule = @{
				Name	    = $Module
				ErrorAction = 'Stop'
			}
			$Repo = Find-Module @paramFindModule
			$RepoVersion = $Repo.Version
			
			$paramWriteHost = @{
				Object = " Installing latest $Module PowerShell Module Version $RepoVersion"
				ForegroundColor = 'Cyan'
			}
			Write-Host @paramWriteHost
			
			$paramInstallModule = @{
				Name			   = $Module
				SkipPublisherCheck = $true
				Force			   = $true
				ErrorAction	       = 'Stop'
			}
			Install-Module @paramInstallModule | Out-Null
			
			$paramImportModule = @{
				Name		   = $Module
				MinimumVersion = $RepoVersion
				Force		   = $true
				ErrorAction    = 'Stop'
			}
			Import-Module @paramImportModule
			
			$paramWriteHost = @{
				Object = "$Module version $RepoVersion PowerShell Module Loaded"
				ForegroundColor = 'Green'
			}
			Write-Host @paramWriteHost
		}
	}
	catch [system.exception]
	{
		$paramWriteHost = @{
			Object = "Error in Enable-PSModuleUpdate() $($psitem.Exception.Message) Line:$($psitem.InvocationInfo.ScriptLineNumber) Char: $($psitem.InvocationInfo.OffsetInLine)"
			ForegroundColor = 'Red'
		}
		Write-Host @paramWriteHost
		exit $ERRORLEVEL
	}
}
#endregion

#region - PowerShell Module Update
$host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

$paramWriteHost = @{
	Object = "======================================="
}
Write-Host @paramWriteHost

$paramWriteHost = @{
	Object		    = "Script Started"
	ForegroundColor = 'Green'
}
Write-Host @paramWriteHost

if (Get-IsElevated)
{
	try
	{
		(Get-Host).UI.RawUI.WindowTitle = "$env:USERDOMAIN\$env:USERNAME (Elevated)"
		$TimeSync = Get-Date
		$TimeSync = $TimeSync.ToString()
		
		$paramWriteHost = @{
			Object = "Script is running in an elevated PowerShell host."
		}
		Write-Host @paramWriteHost
		
		$paramWriteHost = @{
			Object = "Start time: $TimeSync `n"
		}
		Write-Host @paramWriteHost
		
		#region - Set Script Location Path
		$paramTestPath = @{
			Path	 = $Path
			PathType = 'Container'
		}
		if (Test-Path @paramTestPath)
		{
			$paramSetLocation = @{
				Path = $Path
			}
			Set-Location @paramSetLocation
		}
		else
		{
			$paramWriteHost = @{
				Object = "Invalid Script Path: $Path"
				ForegroundColor = 'Red'
			}
			Write-Host @paramWriteHost
			exit $ERRORLEVEL
		}
		#endregion
		
		#region - PowerShell Update Module
		$paramWriteHost = @{
			Object		    = "Loading PowerShell Module Deployment Script"
			ForegroundColor = 'Green'
		}
		Write-Host @paramWriteHost
		
		foreach ($ModuleName in $ModuleNames)
		{
			$paramWriteHost = @{
				Object = " PowerShell Module $ModuleName"
				ForegroundColor = 'Cyan'
			}
			Write-Host @paramWriteHost
			
			$paramEnablePSModuleUpdate = @{
				Module	    = $ModuleName
				ErrorAction = 'Stop'
			}
			Enable-PSModuleUpdate @paramEnablePSModuleUpdate
		}
		#endregion
		
		$TimeSync = Get-Date
		$TimeSync = $TimeSync.ToString()
		
		$paramWriteHost = @{
			Object    = "`nEnded at:"
			Separator = $TimeSync
		}
		Write-Host @paramWriteHost
	}
	catch [system.exception]
	{
		$paramWriteHost = @{
			Object = "Error: $($psitem.Exception.Message) Line:$($psitem.InvocationInfo.ScriptLineNumber) Char: $($psitem.InvocationInfo.OffsetInLine)"
			ForegroundColor = 'Red'
		}
		Write-Host @paramWriteHost
		exit $ERRORLEVEL
	}
}
else
{
	(Get-Host).UI.RawUI.WindowTitle = "$env:USERDOMAIN\$env:USERNAME (Not Elevated)"
	$paramWriteHost = @{
		Object		    = "Please start the script from an elevated PowerShell host."
		ForegroundColor = 'Red'
	}
	Write-Host @paramWriteHost
	exit $ERRORLEVEL
}

$paramWriteHost = @{
	Object		    = "Script Completed."
	ForegroundColor = 'Green'
}
Write-Host @paramWriteHost

$paramWriteHost = @{
	Object = "======================================="
}
Write-Host @paramWriteHost
#endregion