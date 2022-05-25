param(
	[Parameter(Mandatory=$true, Position=0)]
	[ValidateNotNullOrEmpty()]
	[string]$ScriptWorkingDirectory #TODO://Rename this to $CommonScriptWorkingDirectory
	,
	[Parameter(Mandatory=$true, Position=0)]
	[ValidateNotNullOrEmpty()]
	[string]$TCMSScriptWorkingDirectory
	,
	[Parameter(Mandatory=$true, Position=1)]
	[ValidateNotNullOrEmpty()]
	[string]$SolutionFilesDirectory
	,
	[Parameter(Mandatory=$true, Position=2)]
	[ValidateNotNullOrEmpty()]
	[string]$SolutionManifestFileName
	,
	[Parameter(Mandatory=$true, Position=3)]
	[ValidateNotNullOrEmpty()]
	[string]$BuildCommand

)

#Vars
$userName = [Environment]::UserName
$serverName = [Environment]::MachineName
$solutionManifestFullFilePath = "$SolutionFilesDirectory\$SolutionManifestFileName"

Write-Host "`t**** Build-TCMS function called ****"
Write-Host "`tScript running under username $userName"
Write-Host "`tScript running on server $serverName"

Write-Host "`tGeneric working directory set as $ScriptWorkingDirectory"
Write-Host "`tTCMS working directory set as $TCMSScriptWorkingDirectory"
Write-Host "`tSolution files directory set to $SolutionFilesDirectory"
Write-Host "`tSolution manifest file name is $SolutionManifestFileName"
		
#		[xml]$SolutionManifest = Get-Content $solutionManifestFullFilePath
		
		Write-Host "Importing Modules"

		#Set the location for the script to run from the working directory.
		#This allows modules to be imported using relative paths.
		Set-Location -LiteralPath $ScriptWorkingDirectory
		
		#Import the modules

		#Import Common Solutions
		Import-Module ".\Uninstall-Solution.ps1" -ErrorAction:Stop
		Import-Module ".\Delete-Solution.ps1" -ErrorAction:Stop
		Import-Module ".\Add-Solution.ps1" -ErrorAction:Stop
		Import-Module ".\Install-Solution.ps1" -ErrorAction:Stop
		Import-Module ".\Update-Solution.ps1" -ErrorAction:Stop
		

		#Feature
		Import-Module ".\..\Features\Deactivate-Feature.ps1" -ErrorAction:Stop
		Import-Module ".\..\Features\Activate-Feature.ps1" -ErrorAction:Stop

		#List
		Import-Module ".\..\Lists\Delete-List.ps1" -ErrorAction:Stop
		Import-Module ".\..\Lists\Get-ListItemByKeyVal.ps1" -ErrorAction:Stop #Used for the seed data routines...

		#Utilitities
		Import-Module ".\..\Utilities\Add-SnapIn.ps1" -ErrorAction:Stop
		
		
		#Set the location to the TCMS folder
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		
		#Import TCMS solution.
		Import-Module ".\FarmInstall\Deploy-TCMS.ps1" -ErrorAction:Stop
		Import-Module ".\FarmInstall\Update-TCMS.ps1" -ErrorAction:Stop
		Import-Module ".\FarmInstall\Retract-TCMS.ps1" -ErrorAction:Stop
		
		#Seed Data
		Import-Module ".\seedData\Add-Config.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-WordAddinItems.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-ChangeListItems.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-Language.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-DocumentTypes.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-OfficeElements.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-CorrespondenceHeaderBlocks.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-PicklistName.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-PrefixName.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-TranslationName.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-PicklistItems.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-PrefixItems.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-TranslationItems.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-Offices.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-OfficeLanguages.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-OfficeDetails.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-Files.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-Templates.ps1" -ErrorAction:Stop
		Import-Module ".\seedData\Add-WordTemplates.ps1" -ErrorAction:Stop
		
		
		

if($BuildCommand.Tolower() -eq "build" -or $BuildCommand.Tolower() -eq "retract" -or $BuildCommand.Tolower() -eq "update" -or $BuildCommand.Tolower() -eq "seeddata")
{
#	Write-Host $BuildCommand
	[xml]$SolutionManifest = (Get-Content $solutionManifestFullFilePath)
	
	if($BuildCommand -eq "retract")
	{
		Write-Host "Retract command called"
#		Retract-TCMS -SolutionManifest (Get-Content $solutionManifestFullFilePath)
		Retract-TCMS -SolutionManifest $SolutionManifest
	}
	if($BuildCommand -eq "build")
	{
		Write-Host "Build command called"
#		Deploy-TCMS -SolutionManifest (Get-Content $solutionManifestFullFilePath)
		Deploy-TCMS -SolutionManifest $SolutionManifest
	}
	
	if($BuildCommand -eq "update")
	{
		Update-TCMS -SolutionManifest $SolutionManifest
	}
	
	if($BuildCommand -eq "seeddata")
	{
		Write-Host "SeedData command called"
		
		Write-Host "Deactivating Feature AO.SPS2010.TCMS.FeatureReceivers.csproj_AO.SPS2010.TCMS.EventReceivers"

		Deactivate-Feature -FeatureName "AO.SPS2010.TCMS.FeatureReceivers.csproj_AO.SPS2010.TCMS.EventReceivers" -Url $SolutionManifest.SolutionDeployment.WebApplication

		Write-Host "*** Adding Request ID Items ***" -ForegroundColor Blue
		Add-ChangeListItems -ListName "Request ID" -NumberOfItemsToAdd 1 -Url $SolutionManifest.SolutionDeployment.WebApplication

		Write-Host "*** Adding Config Setting Items ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-Config -ListName "Config Settings" -Url $SolutionManifest.SolutionDeployment.WebApplication -ConfigSettingElements (Import-Csv -Path ".\seedData\ConfigSettings.csv")
		
		Write-Host "*** Adding Language Items ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-Language -ListName "Language" -Url $SolutionManifest.SolutionDeployment.WebApplication -Languages (Import-Csv -Path ".\seedData\Languages.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory
		
		Write-Host "*** Adding Document Types ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-DocumentTypes -ListName "Document Type" -Url $SolutionManifest.SolutionDeployment.WebApplication -DocumentTypes (Import-Csv -Path ".\seedData\DocumentTypes.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory

		Write-Host "*** Adding Office Elements ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-OfficeElements -ListName "Office Elements" -Url $SolutionManifest.SolutionDeployment.WebApplication -OfficeElements (Import-Csv -Path ".\seedData\OfficeElements.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory

		Write-Host "*** Adding Correspondence Header Blocks ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-CorrespondenceHeaderBlocks -ListName "Correspondence Header Blocks" -Url $SolutionManifest.SolutionDeployment.WebApplication -CorrespondenceHeaderBlocks (Import-Csv -Path ".\seedData\CorrespondenceHeaderBlocks.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory

		Write-Host "*** Adding Resource Images ***" -ForegroundColor Blue
		Add-Files -Url $SolutionManifest.SolutionDeployment.WebApplication -ListName "TCMS - Graphics" -DestinationFolderName "Resources" -ImagePath "$TCMSScriptWorkingDirectory\seedData\Resources" -CommonScriptWorkingDirectory $ScriptWorkingDirectory
		
		Write-Host "*** Adding Alternative Office Titles Images ***" -ForegroundColor Blue
		Add-Files -Url $SolutionManifest.SolutionDeployment.WebApplication -ListName "TCMS - Graphics" -DestinationFolderName "Alternative Office Titles" -ImagePath "$TCMSScriptWorkingDirectory\seedData\Alternative Office Titles" -CommonScriptWorkingDirectory $ScriptWorkingDirectory
		
		Write-Host "*** Adding Logo Images ***" -ForegroundColor Blue
		Add-Files -Url $SolutionManifest.SolutionDeployment.WebApplication -ListName "TCMS - Graphics" -DestinationFolderName "Logos" -ImagePath "$TCMSScriptWorkingDirectory\seedData\Logos" -CommonScriptWorkingDirectory $ScriptWorkingDirectory
		
		Write-Host "*** Adding Excel Templates ***" -ForegroundColor Blue
		Add-Templates -Url $SolutionManifest.SolutionDeployment.WebApplication -ListName "TCMS - Templates" -DestinationFolderName "Excel" -TemplatePath "$TCMSScriptWorkingDirectory\seedData\Excel"
		
		Write-Host "*** Adding PowerPoint Templates ***" -ForegroundColor Blue
		Add-Templates -Url $SolutionManifest.SolutionDeployment.WebApplication -ListName "TCMS - Templates" -DestinationFolderName "PowerPoint" -TemplatePath "$TCMSScriptWorkingDirectory\seedData\PowerPoint"
		
		#Need to activate the event receivers for the word addins...
		Activate-Feature -FeatureName "AO.SPS2010.TCMS.FeatureReceivers.csproj_AO.SPS2010.TCMS.EventReceivers" -Url $SolutionManifest.SolutionDeployment.WebApplication
		
		Write-Host "*** Adding WordAddins Templates ***" -ForegroundColor Blue
		Add-Templates -Url $SolutionManifest.SolutionDeployment.WebApplication -ListName "TCMS - Templates" -DestinationFolderName "WordAddins" -TemplatePath "$TCMSScriptWorkingDirectory\seedData\WordAddins"
		
		Deactivate-Feature -FeatureName "AO.SPS2010.TCMS.FeatureReceivers.csproj_AO.SPS2010.TCMS.EventReceivers" -Url $SolutionManifest.SolutionDeployment.WebApplication
		
		Write-Host "*** Adding Word Addin Items ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-WordAddinItems -ListName "Word Addins" -Url $SolutionManifest.SolutionDeployment.WebApplication -WordAddinElements (Import-Csv -Path ".\seedData\WordAddinItems.csv")
		
		Write-Host "*** Adding Word Templates ***" -ForegroundColor Blue
		Add-WordTemplates -Url $SolutionManifest.SolutionDeployment.WebApplication -ListName "TCMS - Templates" -DestinationFolderName "Word" -TemplatePath "$TCMSScriptWorkingDirectory\seedData\Word" -DocumentTypes (Import-Csv -Path "$TCMSScriptWorkingDirectory\seedData\TemplateTypes.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory
		
		Write-Host "*** Adding Picklist Names ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-PicklistName -ListName "Picklist Names" -Url $SolutionManifest.SolutionDeployment.WebApplication -PicklistNames (Import-Csv -Path ".\seedData\PicklistNames.csv")  -CommonScriptWorkingDirectory $ScriptWorkingDirectory
		
		Write-Host "*** Adding Prefix Names ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-PrefixName -ListName "Prefix Names" -Url $SolutionManifest.SolutionDeployment.WebApplication -PrefixNames (Import-Csv -Path ".\seedData\PrefixNames.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory
	
		Write-Host "*** Adding Translation Names ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-TranslationName -ListName "Translations" -Url $SolutionManifest.SolutionDeployment.WebApplication -TranslationNames (Import-Csv -Path ".\seedData\TranslationNames.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory
	
		Write-Host "*** Adding Picklist Items ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-PicklistItems -ListName "Picklist Items" -Url $SolutionManifest.SolutionDeployment.WebApplication -PicklistItems (Import-Csv -Path ".\seedData\PicklistItems.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory

		Write-Host "*** Adding Picklist Items Manual ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-PicklistItems -ListName "Picklist Items" -Url $SolutionManifest.SolutionDeployment.WebApplication -PicklistItems (Import-Csv -Path ".\seedData\Manual_PicklistItems.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory

		Write-Host "*** Adding Prefix Items ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-PrefixItems -ListName "Prefix Items" -Url $SolutionManifest.SolutionDeployment.WebApplication -PrefixItems (Import-Csv -Path ".\seedData\PrefixItems.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory
	
		Write-Host "*** Adding Translation Items ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-TranslationItems -ListName "Translation Items" -Url $SolutionManifest.SolutionDeployment.WebApplication -TranslationItems (Import-Csv -Path ".\seedData\TranslationItems.csv")  -CommonScriptWorkingDirectory $ScriptWorkingDirectory

		Write-Host "*** Adding Offices ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-Offices -ListName "Office" -Url $SolutionManifest.SolutionDeployment.WebApplication -Offices (Import-Csv -Path ".\seedData\Offices.csv")  -CommonScriptWorkingDirectory $ScriptWorkingDirectory

		Write-Host "*** Adding Office Languages ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-OfficeLanguages -ListName "Office Language" -Url $SolutionManifest.SolutionDeployment.WebApplication -OfficeLanguages (Import-Csv -Path ".\seedData\OfficeLanguages.csv")  -CommonScriptWorkingDirectory $ScriptWorkingDirectory

		Write-Host "*** Adding Office Details ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-OfficeDetails -ListName "Office Details" -Url $SolutionManifest.SolutionDeployment.WebApplication -OfficeDetails (Import-Csv -Path ".\seedData\OfficeDetails.csv") -OfficeDetailsToRemove (Import-Csv -Path ".\seedData\OfficeDetailsCleanup.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory

		Write-Host "*** Adding Office Details Manual ***" -ForegroundColor Blue
		Set-Location -LiteralPath $TCMSScriptWorkingDirectory
		Add-OfficeDetails -ListName "Office Details" -Url $SolutionManifest.SolutionDeployment.WebApplication -OfficeDetails (Import-Csv -Path ".\seedData\Manual_OfficeDetails.csv")  -OfficeDetailsToRemove (Import-Csv -Path ".\seedData\OfficeDetailsCleanup.csv") -CommonScriptWorkingDirectory $ScriptWorkingDirectory

		Write-Host "Activating Feature AO.SPS2010.TCMS.FeatureReceivers.csproj_AO.SPS2010.TCMS.EventReceivers"

		Activate-Feature -FeatureName "AO.SPS2010.TCMS.FeatureReceivers.csproj_AO.SPS2010.TCMS.EventReceivers" -Url $SolutionManifest.SolutionDeployment.WebApplication

	}
		
}
else
{
	Write-Error "Unknown command."
	
	exit 999
}
