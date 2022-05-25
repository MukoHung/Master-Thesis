# Connect to Office365 service using PowerShell 

## Type AzureAD\Office365 Credentials

### Get Credential for all services
$creds=Get-Credential -UserName eshlomo@cyberint.co -Message Office365 

### Connect MSOnline
Connect-MsolService -Credential $creds

### Connect AzureAD
Install-Module AzureADPreview -Force
$creds=Get-Credential
Connect-AzureAD -Credential $creds

### Connect AIPService
Install-Module -Name AIPService -Force
Connect-AipService -Credential $creds
Get-Command -Module AIPService

### Connect to SharePoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Connect-SPOService -Url https://<domainhost>-admin.sharepoint.com -credential $credential #Replace <domainhost> with the actual value for your domain

### Connect to Skype for Business Online
Import-Module SkypeOnlineConnector
$sfboSession = New-CsOnlineSession -Credential $credential
Import-PSSession $sfboSession

### Connect to Exchange Online
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $creds -Authentication "Basic" -AllowRedirection 
Import-PSSession $exchangeSession -DisableNameChecking

### Connect to the Security & Compliance Center
$SccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $creds -Authentication "Basic" -AllowRedirection
Import-PSSession $SccSession -Prefix cc

### Connect Exchange Online with MFA
Start-Process https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application
Connect-EXOPSSession -UserPrincipalName eshlomo@cyberint.co #Change UPN value

### Connect to Microsoft Teams
Install-Module MicrosoftTeams -Force
Connect-MicrosoftTeams -Credential $creds 

# Connect Exchange Online via Proxy (Based on WinHttpConfig)
Connect-EXOPSSession -PSSessionOption (New-PSSessionOption -ProxyAccessType WinHttpConfig)

### Connect to all service
$orgName="<Something .onmicrosoft.com>"
$credential = Get-Credential
Connect-AzureAD -Credential $credential
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Connect-SPOService -Url https://$orgName-admin.sharepoint.com -credential $credential
Import-Module SkypeOnlineConnector
$sfboSession = New-CsOnlineSession -Credential $credential
Import-PSSession $sfboSession
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking
$SccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $SccSession -Prefix cc

#-------------------------------------------------------------------------------------------------------------------------------------------