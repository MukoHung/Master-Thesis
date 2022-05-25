# Author: Sunny Chakraborty (@sunnyc7)

# Note: No one has written Exchange Web Services Scripts EVER without thanking Glenn Scales and Mike Pfeiffer :).
# Hence..thanks Glenn and Mike.

# Glenn Scales Blog > http://gsexdev.blogspot.com/
# Mike Pfeiffer blog > http://www.mikepfeiffer.net/

#region Helper Functions
Function Delete-MessageItem {
[CmdletBinding()]
    param(
    [Parameter(Position=1, Mandatory=$true)]
    $service,
    [Parameter(Position=2, Mandatory=$true)]
    $MailboxName 
    )

    Process {
        $count = 1000
        $view = New-Object -TypeName Microsoft.Exchange.WebServices.Data.ItemView -ArgumentList $count
        $propertyset = New-Object Microsoft.Exchange.WebServices.Data.PropertySet ([Microsoft.Exchange.WebServices.Data.BasePropertySet]::IdOnly)
        
        #Deleting All Items from Inbox
        #List of Well Known Folders http://msdn.microsoft.com/en-us/library/office/dn535505(v=exchg.150).aspx
        $items = $service.FindItems("Inbox",$view)

        #Define Property Set  
        $propertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties) 
        $i = 1
        foreach ($item in $items) {
            "$MailboxName :: Deleting $i / $($items.TotalCount)"
            $message = [Microsoft.Exchange.WebServices.Data.Item]::Bind($service, $item.Id,$propertyset)
            $message.Delete('MoveToDeletedItems')
            # Types of Deletes - HardDelete,MoveToDeletedItems,SoftDelete
            # http://msdn.microsoft.com/en-us/library/exchangewebservices.disposaltype%28EXCHG.80%29.aspx
            $i++
            }
        }
} #End of Function Delete-MessageItem
#endregion

#region SETUP: Service Instantiation, Credentials, AutoDiscover 
$EwsLocalPath = "C:\Program Files\Microsoft\Exchange\Web Services\1.0"
Add-Type -Path $EwsLocalPath\Microsoft.Exchange.WebServices.dll

$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService -ArgumentList Exchange2010_SP1

# Credential should have ORG wide Impersonation rights.
# This account is used to login to each mailbox in the list (CSV), and delete every email from Inbox. 
$Credential = Get-Credential

# Impersonation Rights are granted by the following ROLE-ASSIGNMENT
# New-ManagementRoleAssignment –Name:EWSImpersonationTEST –Role:ApplicationImpersonation –User:"domain\svcImpersonationID"

# Remove Role Assignment
# Get-ManagementRoleAssignment -RoleAssigneeType User | Where {$_.Role -eq "ApplicationImpersonation" } | select -First 1 | Remove-ManagementRoleAssignment

#Binding Credential to the service to Authenticate
$service.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials -ArgumentList $Credential.UserName, $Credential.GetNetworkCredential().Password

# Find Email Address from UserName. This will be used as AutoDiscover parameter.
# Assuming this is executed from a Domain Joined Machine, so that root\Directory\LDAP WMI namespace is not blank.
$tmpUsername = ($Credential.UserName).Split("\")[1]
$query = "SELECT * FROM ds_user where ds_sAMAccountName='$tmpUsername'"
$user = Get-WmiObject -Query $query -Namespace "root\Directory\LDAP"

#Use Credentials to determine the EWS endpoint using autodiscover
$service.AutodiscoverUrl($user.DS_mail)
#endregion 


#Import List of mailboxes
$csv= Import-Csv C:\scripts\AllEmailAddresses.csv 
foreach ($entry in $csv) {
    $service.ImpersonatedUserId = new-object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress, $($entry.Email)) 
    Delete-MessageItem -service $service -MailboxName $($entry.Email)
}