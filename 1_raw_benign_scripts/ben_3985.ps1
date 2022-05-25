$UserData = Get-ADUser -Filter * -SearchBase "dc=ausholdings,dc=local"
#$UserData = Get-ADUser -Filter * -SearchBase "OU=!Disabled,OU=Users,OU=Osborne Park,OU=Offices,OU=AUS Holdings,DC=ausholdings,DC=local"
#$UserData = Get-ADUser cmtg.test

$O365Cred = Get-Credential
$O365Session = New-PSSession –ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $O365Cred -Authentication Basic -AllowRedirection
Import-PSSession $O365Session -Prefix O365


foreach ($User in $UserData) {

    Write-Host -ForegroundColor Cyan "Processing AD User: $($User.UserPrincipalName)"
    $ADUser = Get-ADUser -Identity $User.SamAccountName -Properties mailNickname -ErrorVariable ADUserError
    if (!$ADUserError) {
        Write-Host -ForegroundColor Cyan "Locating o365 User..."
        $O365User = Get-O365Mailbox $User.UserPrincipalName -ErrorAction SilentlyContinue
        if ($O365User -eq $null) {
            Write-Host -ForegroundColor Red "Unable to find user ($User.userprincipalname), aborting..."
            Continue
        } else {
        if (![string]::IsNullOrEmpty($ADUser.mailNickname)) {
            Write-Host -ForegroundColor Yellow "Local User already Remote Mailbox Enabled, moving on to next..."
            Continue
        }

        Write-Host -ForegroundColor White "Found matching user ($User.userprincipalname), continuing..."

        # get proxyAddress list from 365 user
        [System.Collections.ArrayList]$o365emailAddresses = $O365User.EmailAddresses | Where {$_ -match "smtp"}
        Write-Host -ForegroundColor White "Building email address list to update On-Prem Exchange..."

        # remove domain from o365 primary mail and store in var
        $o365alias = ($O365User.PrimarySmtpAddress).Split("@")[0]
           
        # run enable-remotemailbox White alias, primarysmtp and target address parameters (values from step 4, step 3, step 6)
        Write-Host -ForegroundColor Cyan "Enabling On-Prem Remote Mailbox"
        Enable-RemoteMailbox -Identity $ADUser.UserPrincipalName -RemoteRoutingAddress ($o365alias + "@ausholdingsptyltd.mail.onmicrosoft.com") -Alias $o365alias -PrimarySmtpAddress $O365User.PrimarySmtpAddress

        # get ExchangeGUID from o365 and populate on-prem msExchMailboxGuid
        Write-Host -ForegroundColor White "Linking Office365 MailboxGUID with On-Prem Account"
        Set-Remotemailbox -Identity $ADUser.UserPrincipalName -ExchangeGuid $O365User.ExchangeGUID.GUID

        # loop all o365 mail and add to on-prem proxyAddress
        # add @ausholdingsptylt.mail address to on-prem ProxyAddresses
        Write-Host -ForegroundColor White "Add On-Prem Office365 Routing email to proxyAddress"
        $o365emailAddresses.add("smtp:" + $o365alias + "@ausholdingsptyltd.mail.onmicrosoft.com")
        Set-RemoteMailbox -Identity $ADUser.UserPrincipalName -EmailAddresses @{Add=$($o365emailAddresses)}

        # profit

        }
    }
}