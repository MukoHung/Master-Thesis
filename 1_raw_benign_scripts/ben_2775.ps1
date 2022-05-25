$domainServer = 'ad.mydomain.com'

$username = Read-Host -Prompt 'Username: '

$newPassword = Read-Host -AsSecureString -Prompt 'Password: '

Set-ADAccountPassword -Identity $username -Reset -NewPassword $newPassword