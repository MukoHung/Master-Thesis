[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $storageAccountKey,
    $containerName,
    $destinationFolder,
    $blobName
)
$storageAccount = New-AzStorageContext -StorageAccountName stimportsdndprod -StorageAccountKey $storageAccountKey
$blobs = Get-AzStorageBlob -Container $containerName -Context $storageAccount
if(Test-Path -Path $destinationFolder)
{
    Write-Host "Destination Folder $destinationFolder already exists;"
}
else {
    Write-Host "Creating folder $destinationFolder"
    New-Item  -Path $destinationFolder -ItemType "directory" 
}
foreach ($blob in $blobs)
{
    if($blob.Name -like $blobName )
    {
        Get-AzStorageBlobContent -Container $containerName -Blob $blob.Name -Destination $destinationFolder -Context $storageAccount 
    }
};