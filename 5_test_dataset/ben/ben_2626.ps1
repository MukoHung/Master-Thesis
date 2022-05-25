#  You must be running Windows PowerShell as an Administrator

#  Configure PowerShell to run scripts
#  -- http://technet.microsoft.com/en-us/library/hh849812.aspx
#  -- Note: You'll need registry edit access on the local machine to run the following command
Set-ExecutionPolicy RemoteSigned

#  Pull in the Office 365 PowerShell module
Import-Module MsOnline

#  Establish a reusable credential
#  -- This user must have global administrator rights in Office 365
$username = "username"
$password = "password"
$credential = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password -asplaintext -force) 

#  Connect to Office 365 with credential
Connect-MsolService -Credential $credential
<#
    You can now run Office 365 PowerShell cmdlets.  To test your connection, run this command:
    
    Get-MsolDomain
    
    You should get back the domain associated to the Office 365 tenant
#>

#  Pull in the SharePoint Online PowerShell module
Import-Module Microsoft.Online.SharePoint.PowerShell

#  Connect to SharePoint Online
#  -- The url used should be the url of the admin site for the tenant. Format:  https://domainhost.sharepoint.com
#  -- If you get an error message about unapproved verbs, it is safe to ignore the warning.
Connect-SPOService -Url https://<domainhost>.sharepoint.com -credential $credential
<#
    You can now run SharePoint Online cmdlets.  To test your connection, run this command:
    
    Get-SPOSite
    
    You should get back a list of all your SharePoint Online sites.
#>

#  Pull in the Lync Online PowerShell module
Import-Module LyncOnlineConnector

#  Establish a remote PowerShells session with the Lync Online servers
$lyncSession = New-CsOnlineSession -Credential $credential

#  Start the Lync Online remote PowerShell session
Import-PSSession $lyncSession
#  -- Wait for creation of implicit remoting module to complete
<#
    You can now run Lync Online cmdlets.  To test your connection, run this command:
    
    Get-CsMeetingConfiguration
    
    You should get back the meeting configuration attributes set in Lync
#>

#  Establish a remote PowerShell session with the Exchange Online servers
#  -- It is save to ignore the warning message about the connection being redirected
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection

#  Start the Exchange Online remote PowerShell session
#  -- If you get an error message about unapproved verbs, it is safe to ignore the warning.
Import-PSSession $exchangeSession
<#
    You can now run Exchange Online cmdlets.  To test your connection, run this command:
    
    Get-AcceptedDomain
    
    You should get back information about your Exchange Online domain.
#>

<#
    ----------
    You can now manage all of Office 365 from this single PowerShell session.
    
    Important!  Once you are done, remember to close your remote sessions
    ----------
#>

#  Get a list or your remote PowerShell sessions
Get-PSSession

#  Close the sessions created in this script
Remove-PSSession $lyncSession
Remove-PSSession $exchangeSession
#  You could also close all sessions by running this script:  Get-PSSession | Remove-PSSession

#  Disconnect from SharePoint Online
Disconnect-SPOService

#  Close the PowerShell Window