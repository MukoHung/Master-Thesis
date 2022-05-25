# login as Global Admin Account

$User = "global_admin_account@domain.com"
$PWord = ConvertTo-SecureString -String "global_admin_password" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

$teamsurl = "https://link_to_event" # Link to event
# $cred = Get-Credential
Connect-AzureAD -Credential $cred
Connect-MsolService -Credential $cred
Connect-MicrosoftTeams -Credential $cred
$exosession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $exosession

# Get User from Recyclebin
Get-MsolUser -ReturnDeletedUsers
Get-MsolUser -ReturnDeletedUsers -All | Where-Object { $_.UserPrincipalName -like "*sn*"} 
Get-MsolUser -ReturnDeletedUsers -All | Where-Object { $_.UserPrincipalName -like "*sn*"} | Remove-MsolUser -RemoveFromRecycleBin
Get-MsolUser -ReturnDeletedUsers | Remove-MsolUser -RemoveFromRecycleBin

# Example:
# Send Link Invite
New-AzureADMSInvitation -InvitedUserEmailAddress email@domain.com -InviteRedirectURL $teamsurl -SendInvitationMessage $true

# Bulk invites
$invitations = import-csv .\file.csv
foreach ($email in $invitations) {$email.email}
foreach ($email in $invitations) {New-AzureADMSInvitation -InvitedUserEmailAddress $email.InvitedUserEmailAddress -InvitedUserDisplayName $email.Name -InviteRedirectUrl $teamsurl -InvitedUserMessageInfo $messageInfo -SendInvitationMessage $true}

# Add user to Microsoft 365 Group
Add-UnifiedGroupLinks -Identity "Microsoft 365 Group" -LinkType Members -Links "email@domain.com"

# Bulk Add to Microsoft 365 Group
$invitations = import-csv .\file.csv
foreach ($email in $invitations) {$email.email}
foreach ($email in $invitations) {Add-UnifiedGroupLinks -Identity "Microsoft 365 Group" -LinkType Members -Links $email.email}

# CSV example
# email
# mail1@email.com
# mail2@email.com
# mail3@email.com