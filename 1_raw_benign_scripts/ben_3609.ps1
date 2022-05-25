$smtpServer = "smtp.gmail.com"
$mail = new-object Net.Mail.MailMessage
$mail.From = ""
$mail.To.Add("")
$mail.Subject = "Subject"
$mail.Body = "Body"
$smtp = new-object Net.Mail.SmtpClient($smtpServer, 465)
$smtp.EnableSs1 = $true
$SMTP.Credentials = New-Object System.Net.NetworkCredential(MAIL, PASSWORD)
$smtp.Send($mail)