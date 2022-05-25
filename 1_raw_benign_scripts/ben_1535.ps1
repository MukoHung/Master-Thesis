Following the directions here (http://ss64.com/ps/syntax-run.html) in an administrator powershell execute:
Set-ExecutionPolicy RemoteSigned

Create a Scheduled task:
Program/script box enter "PowerShell
Add arguments (optional) box enter the value ".\FullDBBackup.ps1 | Out-File <PATH TO LOG>log.txt -Append" 
Start in (optional) box, add the location of the folder that contains your PowerShell script