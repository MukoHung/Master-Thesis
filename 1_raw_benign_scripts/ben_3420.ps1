# SAMPLE SCRIPT for SharePoint Migration
# This PowerShell script is only a summary of several code-snippets and needs to be adjusted.
# It is not a complete solution for your migration and will not work without further adjustments.
# It should help you with building your own solution.
# The script is provided "as-is". You bear the risk of using it.

function isUserMigratedfromAD($UserName)
{
	$ismigrated = $false
	try
	{
		$user = Get-ADUser -Identity $UserName -Properties customAttribute1
		
		if ($user.customAttribute1 -eq "MIGRATED")
		{
			$ismigrated = $true
		}

		return $ismigrated
	}
	catch
	{
		return $true
	}
}

function setUserMigrationStatusInAD($UserName)
{
	Set-ADUser -Identity $UserName -Add @{customAttribute1="MIGRATED"}
}


$testingOnly = $true

# Calculate Log File Path and File Name
$LogFileName = "$ENV:temp\SPMigration_$(Get-Date -format yyyy-MM-dd)_$($env:COMPUTERNAME).log"
Start-Transcript -Path $LogFileName -append

# here you pass the sAMAccountName of the account in the Source Domain for the user to be migrated
# you might trigger this script passing this value as an agrument to the script
$OldUserName = "OldUser4711"

# - START - ERROR CHECKING -
# This section can also be used within the Pre-Migration script
# here you can perform various checks, some examples given
if ($OldUserName -ne $null)
{	
	# Read the Mapping Data, e.g. from SQL Table or Excel File or whatever you prefer
	# of course, you need to implement your own function for 'getUserDataFromMappingTable' here
	Write-Output "----- $OldUserName --------"
	$UserAccount = getUserDataFromMappingTable $OldUserName
	
	# - User not found in Mapping Table
	if ($UserAccount -eq $null)
	{ 
		Write-Output "----- WARNING: User not found in Mapping Table -----"
		Stop-Transcript
		break
	}
	# - User found in Mapping Table
	else
	{
		# check for duplicate entries
		if($UserAccount.GetType().BaseType.Name -eq "Array")
		{
			Write-Output "----- ERROR: Duplicate Records found in Mapping Table -----"
			Stop-Transcript
			break
		}
		else
		{
			Write-Output " --> INFO: User found in Mapping Table"
		}
	}
	
	# Check in Mapping Table: SharePointMigrationStatus = MIGRATED
	If ($UserAccount.SharePointMigrationStatus -eq "MIGRATED")
	{
		Write-Output "----- WARNING: According to Mapping Table User Account has already been migrated -----"
		Stop-Transcript
		break
	}
		
	# Check AD customAttribute1 = MIGRATED
	if ($(isUserMigratedfromAD $UserAccount.OldUserName )-eq $true)
	{
		Write-Output " --> WARNING: According to customAttribute1 User Account has already been migrated"
		Stop-Transcript
		break
	}
	
	# further requirement checks here ...
}
else 
{ 
	Write-Output "----- Missing User  -----"
	Stop-Transcript
	break
}
# - END - ERROR CHECKING -

Write-Output $UserAccount.OldUserName
try 
{
	try
	{
		# check if old user account exists
		Write-Output " - checking Old user profile $($UserAccount.OldUserName)"
		$oldProfile = $profileManager.GetUserProfile($UserAccount.OldUserName)
	}
	# SharePoint User Profile does not exist (Old)
	catch
	{		
		Write-Output "----- ERROR: Old UserProfile not found -----"
		Stop-Transcript
		break
	}
	
	$OldUserDisplayName = $oldProfile.DisplayName
	
	Write-Output "   - Old UserProfile found for: $($oldProfile.DisplayName)"
	
	# here you can check the mandatory user profile properties and implement you own error handling
	if ($oldProfile["Department"] -ne $null)
	{
		Write-Output "     - Department: $($oldProfile['Department'])"
	}
	else
	{
		Write-Output "     - Department: empty!"
	}
	
	# Check if Old Personal Site has been created
	Write-Output "     - Personal Page status: ($($oldProfile.PersonalSiteInstantiationState))"
	
	# WRITE ALL PROPERTIES
	Write-Output "  ---- OLD User Profile Properties ----"
	
	try
	{
		Write-Output "     - RecordId : $($oldProfile.RecordId)"
		$oldProfile.properties | % {
			if ($oldProfile[$_.Name] -ne $NULL)
			{
				$Name = $_.Name
				$Value = $oldProfile[$_.Name].tostring()
				Write-Output "     - $Name : $Value"
			}
		}
	}
	catch
	{
		Write-Output "----- ERROR: Old UserProfile cannot be queried -----"
		Stop-Transcript
		break
	}
	
	Write-Output "  -------------------------------------"
	
	# Check if Old OfB has been created
	Write-Output "     - PersonalUrl: ($($oldProfile.PersonalUrl))"
	$MySite = Get-SPSite $($oldProfile.PersonalUrl) -ErrorAction silentlycontinue
	if ($MySite -ne $null)
	{
		Write-Output "       --> exists ($($oldProfile.PersonalSite))"
		# Check MySiteQuota
		try
		{
			$contentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
			$QuotaTemplates = $contentService.QuotaTemplates
			
			$OldMySite = get-spsite $oldProfile.PersonalUrl
			$used = "{0:N2}" -f (($OldMySite).Usage.Storage /(1024*1024))
			Write-Output "     - MySite Storage Used   : $used"
			$noOfDocsOld = $OldMySite.RootWeb.Lists["Documents"].itemcount
			Write-Output "     - MySite No of Documents: $noOfDocsOld"
			$QT = $QuotaTemplates | ?{$_.QuotaID -eq $OldMySite.Quota.QuotaID}
			$OldQuotaTempleteName = $($QT.Name)
			Write-Output "     - MySite Quota Template : $($QT.Name)"
			Write-Output "     - MySite Quota Size     : $($QT.StorageMaximumLevel)"
			Write-Output "     -----------------------------------------------------"
			$OldMySite.Dispose()
		}
		catch
		{
			Write-Output "     - ERROR reading MySite Quota"
		}
		
		
		# BACKUP MySite
		# you need to implement your own function here
		BackupMySite $UserAccount $oldProfile.PersonalUrl
	}
	else
	{
		Write-Output "       --> does not exist"
	}
	
	# SharePoint User Profile does not exist (New)
	try
	{
		# check if new user account exists
		Write-Output " - checking New user profile $($UserAccount.NewUserName)"
		$newProfile = $profileManager.GetUserProfile($UserAccount.NewUserName)
	}
	# SharePoint User Profile does not exist (New)
	catch
	{		
		Write-Output "----- WARNING: New UserProfile not found -----"
		Stop-Transcript
		break
	}
	
	$NewUserDisplayName = $newProfile.DisplayName

	Write-Output "   - New UserProfile found for: $($newProfile.DisplayName)"
	Write-Output "     - Department: $($newProfile['Department'])"

	# Check if New Personal Site has been created
	Write-Output "     - Personal Page status: ($($newProfile.PersonalSiteInstantiationState))"
	
	# WRITE ALL PROPERTIES
	Write-Output "  ---- NEW User Profile Properties ----"
	
	try
	{
		Write-Output "     - RecordId : $($newProfile.RecordId)"
		$newProfile.properties | % {
			if ($newProfile[$_.Name] -ne $NULL)
			{
				$Name = $_.Name
				$Value = $newProfile[$_.Name]
				Write-Output "     - $Name : $Value"
			}
		}
	}
	catch
	{
		Write-Output "----- ERROR: New UserProfile cannot be queried -----"
		Stop-Transcript
		break
	}
	Write-Output "  -------------------------------------"
	
	# Cancel if User Profiles have already been migrated
	if ($newProfile.PersonalSiteInstantiationState -eq "Created")
	{
		Write-Output "     - New User Profile already has been created"
		BackupMySite $UserAccount $newProfile.PersonalUrl
		
		Write-Output "----- ERROR: The New SharePoint User Profile needs to be deleted first -----"
		Stop-Transcript
		break
	}
		
	Write-Output " - migrating user profile"
	
	# migrate only if not testing
	if ($testingOnly -eq $false)
	{
		# STSADM Migration Error
		try
		{	
			# Here comes the STSADM migration command
			# you can use your own preferred migration command (e.g. Move-SPUser) here of course
			# the STSADM command is not the only way
			Write-Output "   --> invoking STSADM command (from $UserAccount.OldUserName to $NewUserName)"
			$rServiceMessage = & "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\BIN\STSADM.EXE" -o migrateuser -oldlogin "i:0#.w|SourceDomain\$UserAccount.OldUserName" -newlogin "i:0#.w|TargetDomain\$UserAccount.NewUserName" -ignoresidhistory 2>&1
		}
		# STSADM Migration Error
		catch
		{
			Write-Output "     --> Result"
			Write-Output "****** Exception ******"
			Write-Output $rServiceMessage.Exception
			Write-Output "****** LASTEXITCODE *******************"
			Write-Output $LASTEXITCODE
			Write-Output "***************************************"
			
			Write-Output "----- ERROR: STSADM EXCEPTION -----"
			Stop-Transcript
			break
		}
		Write-Output "     --> Result"
		Write-Output "*****************************"
		Write-Output $rServiceMessage
		Write-Output "****** LASTEXITCODE *********"
		Write-Output $LASTEXITCODE
		Write-Output "*****************************"
	}
	else
	{
		Write-Output "   --> TESTING ONLY"
		$LASTEXITCODE = 0
	}
	
	if ($LASTEXITCODE -eq 0)
	{
		Write-Output "     --> account was successfully migrated"

		# Setting SharePoint Migration Status in your Mapping Table
		# you need to implement that function depending on your environment
		SetSharePointMigrationStatusStatus $UserAccount.OldUserName "MIGRATED"
		
		# Set AD Attribute
		Write-Output "     --> setting AD Attribute"
		# Setting AD Attribute (Old)
		# this helps you with excluding already migrated profiles from being re-synced
		try
		{
			if ($testingOnly -eq $false) { setUserMigrationStatusInAD $UserAccount.OldUserName }
		}
		# Setting AD Attribute (Old)
		catch
		{
			Write-Output "----- ERROR: Setting AD Attribute -----"
			Stop-Transcript
			break
		}
		
		# OPTIONAL
		# sending final E-Mail to SharePoint user
		# ...
		
		Write-Output "----- INFO: account was successfully migrated -----"
	}
	else
	{
		Write-Output "----- ERROR: User Profile could not be migrated -----"
		Write-Output "$rServiceMessage"
	}
}
catch
{
	Write-Output "----- ERROR: an error was encountered while retrieving the user profile -----"
}

Stop-Transcript