
function Add-SnapIn()
{
	<#
		.SYNOPSIS
    	Loads the Microsoft.SharePoint.PowerShell if not already loaded into memory.
		.DESCRIPTION
		The Microsoft.SharePoint.PowerShell snapin loads SharePoint specific PowerShell commands.
		
	#>
	begin{
		Write-Output "`tAdd-SnapIn function called"
	}
	process{

		If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
		{
			Write-Output "Loading Microsoft.SharePoint.PowerShell snapin"
			Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell
			Write-Output "Microsoft.SharePoint.PowerShell snapin loaded"
			
		}
		else
		{
			Write-Output "`tMicrosoft.SharePoint.PowerShell already loaded"
		}
	}
	end{
		Write-Output "`tAdd-SnapIn function complete"
	}
}