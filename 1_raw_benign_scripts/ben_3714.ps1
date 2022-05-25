Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable | Select-Object Name, Version
# ==================================================================================
# IF EXECUTION POLICY ERROR, RUN THIS
# ==================================================================================
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# ==================================================================================
#  VARIABLES
# ==================================================================================
$varTemplateAdminUrl = 'https://tenantname-admin.sharepoint.com'
$varTemplateSiteUrl = 'https://tenantname.sharepoint.com/sites/QA-Directories'
$varSiteScript1Name = "<<Site Script 1 Name>>"
$varSiteDesignName = "<<Site Design Name>>"
$varSiteDesignDescription = "<<Give your site design a description>>"

# ==================================================================================
# GENERATE SITE SCRIPT FROM AN EXISTING SITE
# https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/get-spositescriptfromweb?view=sharepoint-ps
# ==================================================================================
Connect-SPOService -Url $varTemplateAdminUrl
$siteScriptXML = Get-SPOSiteScriptFromWeb -WebUrl $varTemplateSiteUrl -IncludedLists ("Documents", "Lists/List Name")

# ==================================================================================
# CREATE SITE DESIGN IN DESTINATION SITE
# https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/add-spositedesign?view=sharepoint-ps
# ==================================================================================
$siteScriptXmlResult = Add-SPOSiteScript -Title $varSiteScript1Name -Content $siteScriptXML
Add-SPOSiteDesign -Title $varSiteDesignName -WebTemplate "64" -SiteScripts $siteScriptXmlResult.Id -Description $varSiteDesignDescription

# ==================================================================================
# GET EXISTING SITE DESIGN ID
# https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/get-spositedesign?view=sharepoint-ps
# ==================================================================================
#Get-SPOSiteDesign

# ==================================================================================
# GET EXISTING SITE SCRIPT ID
# https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/get-spositescript?view=sharepoint-ps
# ==================================================================================
#Get-SPOSiteScript

# ==================================================================================
# UPDATE SITE DESIGN IN DESTINATION SITE (Don't forget to increment the version)
# https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/set-spositedesign?view=sharepoint-ps
# ==================================================================================
#Get-Content $siteScriptXML Set-SPOSiteScript -Identity "3747dd8c-f161-4340-be75-d6e5b16bc5de" -
#Set-SPOSiteDesign -Identity 'a54388af-063e-4662-b340-e2500ee74902' -SiteScripts "3747dd8c-f161-4340-be75-d6e5b16bc5de" -Version 2

# ==================================================================================
# REMOVE EXISTING SITE DESIGN
# https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/remove-spositedesign?view=sharepoint-ps
# ==================================================================================
#Remove-SPOSiteDesign -Identity 'a54388af-063e-4662-b340-e2500ee74902'
