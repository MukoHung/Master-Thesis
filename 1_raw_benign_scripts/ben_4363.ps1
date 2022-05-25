<#
.SYNOPSIS
Sets the system fields for a specific list/library item.

.DESCRIPTION
This will set the system fields (created, created by, modified, modified by)
for a specific list/library item.

Provide any or all of those system fields as a parameter and they will be set.
If no modified date is provided, the item keeps its current modified date.

NOTE: Setting the CreatedBy may only work for document library items if you
also set the ModifiedBy.

.EXAMPLE
$SPClient = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$context = New-Object Microsoft.SharePoint.Client.ClientContext("https://mytenant.sharepoint.com/sites/site1")
$securePwd = Read-Host "password" -AsSecureString
$context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials("jdoe@mycompany.com", $securePwd)

.\Update-SPSystemFields -context $context -listTitle "Documents" -listItemId 1 -CreatedBy "John Doe"

.EXAMPLE
.\Update-SPSystemFields -context $context -listTitle "Custom List" -listItemId 5 -CreatedBy "jdoe@mycompany.com" -Created ((Get-Date).AddDays(-2)) -ModifiedBy "Jane Smith" -Modified ((Get-Date).AdDays(-1))
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$false)]$context,
	[Parameter(Mandatory=$true)][string]$listTitle,
	[Parameter(Mandatory=$true)][Int32]$listItemId,
	[Parameter(Mandatory=$false)][string]$createdBy = $null,
	[Parameter(Mandatory=$false)][DateTime]$created = [System.DateTime]::MinValue,
	[Parameter(Mandatory=$false)][string]$modifiedBy = $null,
	[Parameter(Mandatory=$false)][DateTime]$modified = [System.DateTime]::MinValue
)

Set-StrictMode -Version "3.0"
$SPClient = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$SPClientRuntime = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
$SP = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")

function GetUserLookupString{
	[CmdletBinding()]
	param($context, $userString)
	
	try{
		$user = $context.Web.EnsureUser($userString)
		$context.Load($user)
		$context.ExecuteQuery()
		
		# The "proper" way would seem to be to set the user field to the user value object
		# but that does not work, so we use the formatted user lookup string instead
		#$userValue = New-Object Microsoft.SharePoint.Client.FieldUserValue
		#$userValue.LookupId = $user.Id
		$userLookupString = "{0};#{1}" -f $user.Id, $user.LoginName
	}
	catch{
		Write-Host "Unable to ensure user '$($userString)'."
		$userLookupString = $null
	}
	
	return $userLookupString
}

function Main{
	[CmdletBinding()]
	param()
	
	# Get the created by/modified by user if provided
	$createdByUser = $null
	if ($createdBy -ne $null -and $createdBy.Length -gt 0){
		Write-Host "Ensuring $($createdBy)"
		$createdByUser = GetUserLookupString $context $createdBy
	}
	$modifiedByUser = $null
	if ($modifiedBy -ne $null -and $modifiedBy.Length -gt 0){
		Write-Host "Ensuring $($modifiedBy)"
		$modifiedByUser = GetUserLookupString $context $modifiedBy
	}
	
	# Get the list
	$list = $context.Web.Lists.GetByTitle($listTitle)
	$context.Load($list)
	$context.ExecuteQuery()
	
	# Temporarily turn off versioning if it is on
	$enableVersioning = $list.EnableVersioning
	if ($enableVersioning -eq $true){
		$list.EnableVersioning = $false
		$list.Update()
		$context.ExecuteQuery()
	}
	
	try{
	
		# Get the list item
		$item = $list.GetItemByid($listItemId)
		$context.Load($item)
		$context.ExecuteQuery()
		
		# Set the author (created by) if provided
		# Not that this only seeems to work if you also set the editor (modified by)
		# when doing this on document library items in SharePoint Online
		if ($createdByUser -ne $null){
			Write-Host "Setting Author to $($createdByUser)"
			$item["Author"] = $createdByUser
		}
		
		# Set the editor (modified by) if provided
		if ($modifiedByUser -ne $null){
			Write-Host "Setting Editor to $($modifiedByUser)"
			$item["Editor"] = $modifiedByUser
		}
		
		# Set the created date if provided
		if ($created -gt [System.DateTime]::MinValue){
			Write-Host "Setting Created to $($created)"
			$item["Created"] = $created
		}
		
		# Set the modified date if provided
		if ($modified -ne [System.DateTime]::MinValue){
			Write-Host "Setting Modified to $($modified)"
			$item["Modified"] = $modified
		}
		else{
			# No modified date change provided, so force the modified date to the old modified date
			# (otherwise it will become the current date)
			$origDate = $item["Modified"]
			$item["Modified"] = $origDate
		}
		
		$item.Update()
		$context.ExecuteQuery()
	}
	finally{
		# Turn versioning back on if we turned it off
		if ($enableVersioning -eq $true){
			$list.EnableVersioning = $true
			$list.Update()
			$context.ExecuteQuery()
		}
	}
}

Main