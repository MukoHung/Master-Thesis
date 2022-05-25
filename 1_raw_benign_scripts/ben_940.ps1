$pathToOU = 'OU=SP Accounts,DC=fahq,DC=local'
$password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force

New-ADUser -SamAccountName "sp_wf" -Name "sp_wf" -DisplayName "sp_wf" -Path $pathToOU -Enabled $true -AccountPassword $password -ChangePasswordAtLogon $false -PasswordNeverExpires $true