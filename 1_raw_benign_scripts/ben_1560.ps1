# ------------------------------------------------------------
# Create Hyper-V virtual machine via PowerShell
# ------------------------------------------------------------

Param(
    [string]$VMName,
    [string]$Size="small",
    [int32]$VLANID=900,
    [string]$NetworkSwitch="Server Network"
)

Function New-RHEL7VMFromTemplate {
    Param(
        [string]$VMName,
        [string]$Size = "small",
        [int32]$VLANID = 900,
        [string]$NetworkSwitch = "Network",
        [string]$StoragePath = "C:\ClusterStorage\CSV1\$VMName",
        [string]$TemplateVersion = "0001"
    )

    $vmsmall = @{ram = 4GB; cpu = "2"}
    $vmmedium = @{ram = 6GB; cpu = "4"}

    $vmsizes = @{}
    $vmsizes.Add("small", $vmsmall)
    $vmsizes.Add("medium", $vmmedium)

    # Define variables for use throughout function
    $ROOT_TPL_VERSION = $TemplateVersion
    $ROOT_ROOT_VHD_TPL = "C:\ClusterStorage\CSV1\template\$ROOT_TPL_VERSION\template\Virtual Hard Disks\template.vhdx"
    $ROOT_DATA_VHD_TPL = "C:\ClusterStorage\CSV1\template\$ROOT_TPL_VERSION\template\Virtual Hard Disks\template_data.vhdx"
    $ROOT_SWAP_VHD_TPL = "C:\ClusterStorage\CSV1\template\$ROOT_TPL_VERSION\template\Virtual Hard Disks\template_swap.vhdx"
    $VM_ROOT_VHD = "${StoragePath}\${VMName}.vhdx"
    $VM_DATA_VHD = "${StoragePath}\${VMName}_data.vhdx"
    $VM_SWAP_VHD = "${StoragePath}\${VMName}_swap.vhdx"
    $VM_DATA_VHD_SIZE = 80GB

    # Create a new VM
    $VM = New-VM -Name $VMName -Path $StoragePath -MemoryStartupBytes $vmsizes.Item($Size).Item("ram") -Generation 2 

    # Disable "secure boot" - ideal for EFI
    Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

    # Mkdir our final path for the virtual disks
    MD $StoragePath -ErrorAction SilentlyContinue

    # Convert/copy the template disks and add them to the VM
    Convert-VHD -Path $ROOT_ROOT_VHD_TPL -DestinationPath $VM_ROOT_VHD
    Add-VMHardDiskDrive -VM $VM -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0 -Path $VM_ROOT_VHD
    Convert-VHD -Path $ROOT_DATA_VHD_TPL -DestinationPath $VM_DATA_VHD
    Add-VMHardDiskDrive -VM $VM -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 1 -Path $VM_DATA_VHD
    Convert-VHD -Path $ROOT_SWAP_VHD_TPL -DestinationPath $VM_SWAP_VHD
    Add-VMHardDiskDrive -VM $VM -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 3 -Path $VM_SWAP_VHD

    # Configure CPU/RAM
    Set-VMProcessor -VM $VM -Count $vmsizes.Item($Size).Item("cpu") -CompatibilityForMigrationEnabled $true
    Set-VMMemory -VM $VM -StartupBytes $vmsizes.Item($Size).Item("ram") -DynamicMemoryEnabled $false

    # Configure networking
    Remove-VMNetworkAdapter -VM $VM
    Add-VMNetworkAdapter -VM $VM -Name "Ethernet 0" -SwitchName $NetworkSwitch -DynamicMacAddress
    $ADAPTER = Get-VMNetworkAdapter -VM $VM
    Set-VMNetworkAdapterVlan -VMNetworkAdapter $ADAPTER -Access -VlanId $VLANID

    #Add-ClusterVirtualMachineRole -VMName $VMName -Cluster $VM_CLUSTER

    # Disable "Time Synchornization" integration
    Disable-VMIntegrationService -VMName $VMName -Name "Time Synchronization"

    # Fire up the VM
    Start-VM $VMName
}

New-RHEL7VMFromTemplate -VMName $VMName -Size $Size -VLANID $VLANID -NetworkSwitch "Server Network"
