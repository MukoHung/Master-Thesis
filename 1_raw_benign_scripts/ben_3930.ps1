#Requires -Version 4.0

Param(
    [string] [parameter(Mandatory=$true)] $SubscriptionId,
    [string] [parameter(Mandatory=$true)] $TenantId,
    [string] [Parameter(Mandatory=$true)] $ClientId,
    [string] [Parameter(Mandatory=$true)] $Password,
    [string] [Parameter(Mandatory=$true)] $SourceStorageAccountName,
    [string] [Parameter(Mandatory=$true)] $SourceStorageAccountKey,
    [string] [Parameter(Mandatory=$true)] $SourceContainerName
    [string] [Parameter(Mandatory=$true)] $DestinationStorageAccountName,
    [string] [Parameter(Mandatory=$true)] $DestinationStorageAccountKey,
    [string] [Parameter(Mandatory=$true)] $DestinationContainerName
)

try {
    $ErrorActionPreference = "Stop"
    #TODO need to use the credentials here
    Add-AzureAccount
    Select-AzureSubscription -SubscriptionId $SubscriptionId
  
    $sourceStorageContext = New-AzureStorageContext - StorageAccountName $SourceStorageAccountName -StorageAccountKey $SourceStorageAccountKey
    $sourceContainer = Get-AzureStorageContainer -Name $SourceContainerName -Context $sourceStorageContext

    # copy all blobs
    $destinationPath = Join-Path $PSSCriptRoot Guid
    New-Item -Path $destinationPath -ItemType Directory -Force
    $blobs = Get-AzureStorageBlob -Container $SourceContainerName -Context $sourceStorageContext
    $blobs | Get-AzureStorageBlobContent -Destination $destinationPath -Context $sourceStorageContext

    # compress folder
    Add-Type -assembly "System.IO.Compression.FileSystem"
    $zippedSourceFileName = Join-Path $PSScriptRoot "Documents_$(Get-Date -format yyyyMMddhhnnss)"
    [IO.Compression.ZipFile]::CreateFromDirectory($destinationPath, $zippedSourceFileName)

    # upload zip file to destination container
    $destinationStorageContext = New-AzureStorageContext - StorageAccountName $DestinationStorageAccountName -StorageAccountKey $DestinationStorageAccountKey
    Set-AzureStorageBlobContent $zippedSourceFileName -Container $DestinationContainerName -BlobType Block -Context $destinationStorageContext
  
    #now clean up  
    Remove-Item $destinationPath -Force
} 
catch 
{
    $Host.UI.WriteErrorLine($_)
    exit 1
}