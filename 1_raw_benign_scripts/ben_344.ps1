#AuditFileshare
Param(
[object]$WebhookData
)

#defining global Variables
#items after $script: are the variable names
#Items after $RequesterHeader are the Names for theMS Flow items

$script:Listname = "AuditFileShare"
$script:SiteUrl = "https://vidlerit.sharepoint.com/sites/automation"
$script:listItemId=$WebhookData.RequestHeader.ItemID
$script:ServerPath=$WebhookData.RequestHeader.ServerPath
$script:AuditShare=$WebhookData.RequestHeader.AuditShare

#Connect to site and update "Results" to In-Progress
 Try
 {
 $date = get-date -Format MMMdd-HHmm
 $SPOUser="vidler-o365"
 $Creds=Get-AutomationPSCredential -Name $SPOUser

 $credsAD = Get-AutomationPSCredential -Name "vidler-ad"
  
 Connect-PnPOnline -Url $Global:SiteUrl -Credential $Creds
 #update list
 $updatedItem = Set-PnPListItem -List $Global:listname -Identity $Global:listItemId -Values @{"Status" = "Inprogress"}
 
 #Start of Script
 $strFileName = "c:\scripts\AuditFileShare.ps1" 
 
 #parameters about to be passed to remote script
 write-output "ServerPath = $ServerPath AuditShare = $AuditShare DateItem $date listitemid = $listitemID listname = $listname"

 $script = [scriptblock]::Create("$strFileName -ServerPath $ServerPath -AuditShare $AuditShare -OutPutFolder $date")
 Invoke-Command -ComputerName rv16aad -script $script -Credential $CredsAD -Authentication CredSSP -ErrorVariable script:errortext

 if ($errortext)
 {
 Write-Output "List item updating $($listItemId) Most likely invalid path due to following error $errortext"
 $updatedItem= Set-PnPListItem -List $Global:listname -Identity $Global:listItemId -Values @{"Status" = "Error"; "ErrorMessage" = "$errortext Please Check the Path and try again"}
 Exit
 }

 #File to Attach
 $item = Get-PnPListItem -List $Global:listname -Id $Global:listitemID
 
 $Uploadfile = "$Auditshare-$date"
 $filepath = "C:\sharepointfiles\$UploadFile.zip"
 $fileName = Split-Path $filePath -Leaf

 $ctx = Get-PnPContext

 $fileStream = New-Object IO.FileStream($filePath,[System.IO.FileMode]::Open)

 $attachInfo = New-Object -TypeName Microsoft.SharePoint.Client.AttachmentCreationInformation
 $attachInfo.FileName = $fileName
 $attachInfo.ContentStream = $fileStream

 $attFile = $item.attachmentFiles.add($attachInfo)
 
 write-output "about to attach file"
 $ctx.load($attFile)
 
 Write-Output "List item updating $($listItemId)"
 $updatedItem = Set-PnPListItem -List $Global:listname -Identity $Global:listItemId -Values @{"Status" = "Completed"}
     
 }
 Catch
 {
 
 Write-Output "Error Occured $($_.Exception.Message)"
 Write-Output "List item updating Error Message and Status for ListItem# $($listItemId)"
 $updatedItem= Set-PnPListItem -List $Global:listname -Identity $Global:listItemId -Values @{"Status" = "Error"; "ErrorMessage" = $_.Exception.Message}
 }    
 Finally
 {
 Write-Output "Disconnecting" 
 Disconnect-PnPOnline
 }