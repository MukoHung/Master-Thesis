# Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.WorkflowServices.dll”

# Specify tenant admin and site URL
$SiteUrl = "mysiteurl"
$ListName = "mylistname"
$UserName = "myusername"
$SecurePassword = ConvertTo-SecureString "mypassword" -AsPlainText -Force

# Bind to site collection
$ClientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
$ClientContext.Credentials = $credentials
$ClientContext.ExecuteQuery()

# Get List
$List = $ClientContext.Web.Lists.GetByTitle($ListName)
$ClientContext.Load($List)
$ClientContext.ExecuteQuery()

# Create Single List Item
$ListItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
$NewListItem = $List.AddItem($ListItemCreationInformation)
$NewListItem["Title"] = 'xxx'
$NewListItem.Update()
$ClientContext.ExecuteQuery()

# Loop Create List Item
for ($i=11; $i -le 20; $i++)
{
  $ListItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
  $NewListItem = $List.AddItem($ListItemCreationInformation)
  $NewListItem["Title"] = "abc$($i)"
  $NewListItem.Update()
  $ClientContext.ExecuteQuery()
}
