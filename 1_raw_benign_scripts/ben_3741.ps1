$creds = Get-Credential
$tenantAdminUrl = "https://[TENANT]-admin.sharepoint.com"

Connect-SPOService -Url $tenantAdminUrl -Credential $creds

Get-Content 'C:\[PATH]\COB_ProjectSite.json' -Raw | Add-SPOSiteScript -Title "COB project site script" 