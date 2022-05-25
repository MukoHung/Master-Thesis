# Set Execution Policy to RemoteSigned
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Install Azure Active Directory PowerShell for Graph module (Newer)​
Install-Module -Name AzureAD​

​
# Install Microsoft Azure Active Directory Module for Windows PowerShell (Older)​
Install-Module -Name MSOnline​


# Install Exchange Online PowerShell V2 module​
Install-Module -Name ExchangeOnlineManagement​

​
# Install MicrosoftTeams Module​
Install-Module -Name MicrosoftTeams​

### ​Prepare Single Script to Connect to Office 365 PowerShell All Services ###

# Store O365 admin user name vaule
$username = "powershell@qpebas.com"
#$password = "Dux11673"

#Save password in secure string inside txt. (execute once and then comment out below line)
read-host -assecurestring | convertfrom-securestring | out-file "$ENV:UserProfile\PowerShell Scripts\Connect M365\M365_Cred.txt"

#Get saved password in $password varible
$password = Get-Content "$ENV:UserProfile\PowerShell Scripts\Connect M365\M365_Cred.txt" | convertto-securestring

# Store existing Username and password variable value in $Credential varible to re-use
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password

#Connect to AzurrAD (Newer)
Connect-AzureAD -Credential $credential

#Connect to O365 (Older)
Connect-MsolService -Credential $credential

#Connect to SharePoint
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
#Connect-SPOService -Url https://example-admin.sharepoint.com -credential $credential

#Connect to Skype for Business Online.
Import-Module SkypeOnlineConnector
$sfboSession = New-CsOnlineSession -Credential $credential
Import-PSSession $sfboSession

#Connect to Teams
Connect-MicrosoftTeams -Credential $credential

# Connect to Exchange Online.
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange `
 -ConnectionUri "https://outlook.office365.com/powershell-liveid/" `
  -Credential $credential `
  -Authentication "Basic" 
Import-PSSession $exchangeSession -DisableNameChecking -ErrorAction silentlycontinue -AllowClobber

# Connect to Security & Compliance Center.
$SccSession = New-PSSession -ConfigurationName Microsoft.Exchange `
 -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ `
  -Credential $credential `
  -Authentication "Basic" 
  -AllowRedirection
Import-PSSession $SccSession -Prefix cc