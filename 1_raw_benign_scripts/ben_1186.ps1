#$PSScriptRoot gets current file directory
$sendmailScript = $PSScriptRoot + "\sendEmail.ps1"          
$backupScript = $PSScriptRoot + "\backup.ps1"                              
$uploadScript = $PSScriptRoot + "\uploadTogDrive.ps1"
$config = $PSScriptRoot + "\config.ps1"
$credential = $PSScriptRoot + "\credentials.ps1"
$getFolderId = $PSScriptRoot + "\getFolderId.ps1"
$log = $PSScriptRoot + "\log.ps1"
#calling scripts
. $log
try{
. $config
Log "config script executed"
. $credential
Log "credemtial script executed"
. $sendmailScript
Log "sendmailScript script executed"
. $getFolderId
Log "getFolderId script executed"
. $backupScript
Log "backupScript script executed"
. $uploadScript 
Log "uploadScript  script executed"
}catch{
    Log $_
}
#calling functions
Backup
Log "--------"
UploadTODrive -zipFilePath $zipFilePath 

