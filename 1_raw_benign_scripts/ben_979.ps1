$cloudservice= 'rdc-sb-test-auto7'

Get-AzureAccount -debug

#Change: added -debug to the cmdlet
$existingcloudservice= Get-AzureService -ServiceName $cloudservice -ErrorActionSilentlyContinue -debug 

if ($existingcloudservice) {
  Write-Host "Cloud Service named $cloudservice already exists, no need to provision it."
} 

else {
  Write-Host "Creating new Cloud Service named $cloudservice in "North Central US"..."

  New-AzureService -ServiceName "$cloudservice" -Label "$cloudservice" -Location "North Central US" -debug
}