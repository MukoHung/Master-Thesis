# This is a PowerShell companion script for Outlook
# macro processing PowerShell commands from email

# Delete any previous transcripts and start a new one
Remove-Item "c:\Scripts\email_transcript.txt" -ErrorAction SilentlyContinue
Start-Transcript "c:\Scripts\email_transcript_temp.txt"

# wait till Outlook saves the script email
#while ( -not (Test-Path "c:\Scripts\outlook.ps1")) {
 #   Start-Sleep -Seconds 1
#}

# Read the script, skip the header lines, execute the rest
#Get-Content "c:\Scripts\outlook.ps1" | Where { $i++ -gt 4 } > "c:\Scripts\justscript.ps1"
#. "c:\Scripts\justscript.ps1"

# Remove the old script
#Remove-Item "c:\Scripts\outlook.ps1" -ErrorAction SilentlyContinue
#Remove-Item "c:\Scripts\justscript.ps1" -ErrorAction SilentlyContinue

# Stop transcript and make it available for Outlook to send back

$UserName = "admin"
$ComputerName = "[insert computer name]"
$Password = Get-Content c:\scripts\encrypted_password.txt | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($UserName, $Password)

Restart-Computer -ComputerName $ComputerName -Credential $Credential -Force

Stop-Transcript
Rename-Item "c:\Scripts\email_transcript_temp.txt" -NewName "email_transcript.txt"
