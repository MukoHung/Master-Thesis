# Replace these values with your own
$resourceGroupName = "RG-test-123456"
$vmName = "WS2012-123456"

# Get the VM into an object
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName 

# Store credentials you want to change
$credential = Get-Credential -Message "Enter your NEW USERNAME and/or PASSWORD for $vmName"

# Store parameters in a hashtable for splatting
# Have a look at https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7
$extensionParams = @{
    'VMName' = $vmName
    'Credential' = $credential
    'ResourceGroupName' = $resourceGroupName
    'Name' = 'AdminPasswordReset'
    'Location' = $vm.Location
}

# Pass splatted parameters and update password
Set-AzVMAccessExtension @extensionParams

# Restart VM
# Don't need to pass any switches since they are inferred ByPropertyName
# Have a look at https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7
$vm | Restart-AzVM