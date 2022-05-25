$smtp = New-Object System.Net.Mail.SmtpClient  
$smtp.Host = "127.0.0.1"
$smtp.Port = 587

$creds = New-Object System.Net.NetworkCredential
# $currentCreds = Get-Credential 

$creds.Domain = "" 
$creds.UserName = "my_user"  # $currentCreds.UserName
$creds.Password = "my_pass"  # $currentCreds.GetNetworkCredential()

$smtp.Credentials = $creds
$smtp.Send("sender@domain.com", "receipient@domain.com", "My Subject", "My Message")