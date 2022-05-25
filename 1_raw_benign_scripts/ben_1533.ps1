Add-PSSnapin VeeamPSSnapin
Connect-VBRServer -Server "YOUR BACKUP SERVER"

$restorepointNC = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-NC01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointACS = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-ACS01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointWAS = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-WAS01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointWASP = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-WASP01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointSRN = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-SRNG01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointGW = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-Gwy01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointSQL = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-Sql01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointERC = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-ERCS01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointXRP = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-Xrp01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointSLB = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-SLB01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointADFS = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-ADFS01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointCA = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-CA01" | Sort-Object $_.creationtime -Descending | Select -First 1
$restorepointDC = Get-VBRBackup -Name "Azurestack Infrastructure" | Get-VBRRestorePoint -Name "AzS-DC01" | Sort-Object $_.creationtime -Descending | Select -First 1

$accountCloud = Get-VBRAzureAccount -Type ResourceManager -Name "YOURNAME@YOURDOMAIN.com"
$subscription = Get-VBRAzureSubscription -Account $accountCloud -Name "YOUR AZURE SUBSCRIPTION"
$storageaccount = Get-VBRAzureStorageAccount -Subscription $subscription -Name "southafrica01"
$location = Get-VBRAzureLocation -Subscription $subscription -Name "southafricanorth"
$vmsizeSMALL = Get-VBRAzureVMSize -Subscription $subscription -Location $location -Name Standard_A2_v2
$vmsizeMEDIUM = Get-VBRAzureVMSize -Subscription $subscription -Location $location -Name Standard_A4_v2
$vmsizeLARGE = Get-VBRAzureVMSize -Subscription $subscription -Location $location -Name Standard_A8_v2
$network = Get-VBRAzureVirtualNetwork -Subscription $subscription -Name "SouthAfrica-Vlan"
$subnet = Get-VBRAzureVirtualNetworkSubnet -Network $network -Name "default"
$resourcegroup = Get-VBRAzureResourceGroup -Subscription $subscription -Name "SouthAfrica-Demo"

Start-VBRVMRestoreToAzure -RestorePoint $restorepointNC -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeSMALL -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-NC01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointACS -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeSMALL -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-ACS01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointWAS -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeMEDIUM -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-WAS01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointWASP -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeMEDIUM -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-WAP01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointSRN -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeSMALL -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-SRN01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointGW  -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeSMALL -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-GW01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointSQL -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeLARGE -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-SQL01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointERC -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeLARGE -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-ERC01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointXRP -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeSMALL -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-XRP01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointSLB  -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeSMALL -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-SLB01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointADFS -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeMEDIUM -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-ADF01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointCA -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeMEDIUM -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-CA01-Azure -Reason "TESTING MY NEW SCRIPT"
Start-VBRVMRestoreToAzure -RestorePoint $restorepointDC -Subscription $subscription -StorageAccount $storageaccount -VmSize $vmsizeSMALL -VirtualNetwork $network -VirtualSubnet $subnet -ResourceGroup $resourcegroup -VmName Azs-ACS01-Azure -Reason "TESTING MY NEW SCRIPT"