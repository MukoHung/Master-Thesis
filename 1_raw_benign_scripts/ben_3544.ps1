# Install Hyper-V Role
Install-WindowsFeature Hyper-V -IncludeManagementTools -Restart

& 'D:\Program Files\Microsoft Learning\20743\Drives\CreateVirtualSwitches.ps1'
& 'D:\Program Files\Microsoft Learning\20743\Drives\LON-HOST2_VM-Pre-Import-20743B.ps1'

# Activate Nested Virtualization on NVHosts
function Enabled-NestedVirtualization {
    param ( $VMName )

    Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true -Count 2
    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $false
    Get-VMNetworkAdapter -VMName $VMName | Set-VMNetworkAdapter -MacAddressSpoofing On

}


Set-VMProcessor -VMName 20743B-LON-NVHOST3 -ExposeVirtualizationExtensions $true -Count 2
Set-VMProcessor -VMName 20743B-LON-NVHOST4 -ExposeVirtualizationExtensions $true -Count 2

Set-VMMemory -VMName 20743B-LON-NVHOST3 -DynamicMemoryEnabled $false
Set-VMMemory -VMName 20743B-LON-NVHOST4 -DynamicMemoryEnabled $false

Get-VMNetworkAdapter -VMName 20743B-LON-NVHOST3 | Set-VMNetworkAdapter -MacAddressSpoofing On
Get-VMNetworkAdapter -VMName 20743B-LON-NVHOST4 | Set-VMNetworkAdapter -MacAddressSpoofing On

# Start All VMs
Get-VM | Start-VM

# Store Adatum\Administrator Credential Object
$cred = Get-Credential adatum\administrator

# Install Hyper-v in nested Hypervisors
Invoke-Command -VMName 20743B-LON-NVHOST3 -ScriptBlock {
    Install-WindowsFeature Hyper-V -IncludeManagementTools -Restart
} -Credential $cred

Invoke-Command -VMName 20743B-LON-NVHOST4 -ScriptBlock {
    Install-WindowsFeature Hyper-V -IncludeManagementTools -Restart
} -Credential $cred

# Invoke script file in direct connections
Invoke-Command -VMName 20743B-LON-NVHOST3 `
    -FilePath 'D:\Program Files\Microsoft Learning\20743\Drives\CreateVirtualSwitches.ps1' `
    -Credential $cred

Invoke-Command -VMName 20743B-LON-NVHOST4 `
    -FilePath 'D:\Program Files\Microsoft Learning\20743\Drives\CreateVirtualSwitches.ps1' `
    -Credential $cred

Invoke-Command -VMName 20743B-LON-NVHOST3 -ScriptBlock {
    Install-WindowsFeature Failover-CLustering -IncludeManagementTools -Restart
} -Credential $cred

Invoke-Command -VMName 20743B-LON-NVHOST4 -ScriptBlock {
    Install-WindowsFeature Failover-CLustering -IncludeManagementTools -Restart
} -Credential $cred