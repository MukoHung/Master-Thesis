# Echo the commands as they're run
Set-PSDebug -Trace 1

# Dump Windows version
Get-ComputerInfo | Format-Table WindowsVersion, OsVersion

# Create a UEFI VM, secure boot enabled, use the secure boot settings for the 
$vm = New-VM -Generation 2 -Name "Fedora 34 beta" -Path .
$vm | Set-VMFirmware -EnableSecureBoot On -SecureBootTemplate "MicrosoftUEFICertificateAuthority"


# Disable the automatic checkpoints on each reboot. It's better to use snapper+btrfs :)
$vm | Set-VM -AutomaticCheckpointsEnabled $false

# Processor, memory settings
$vm | Set-VMProcessor -Count 2
$vm | Set-VMMemory -DynamicMemoryEnabled $false -StartupBytes 2Gb

# Add DVD drive, attach ISO, HDD, and set boot order
$dvd = $vm | Add-VMDvdDrive -Path ./Fedora-Workstation-Live-x86_64-34_Beta-1.3.iso -Passthru
$vhd = New-VHD -SizeBytes 20Gb -Dynamic boot.vhdx
$hdd = $vm | Add-VMHardDiskDrive -Path $vhd.Path -Passthru
$vm | Set-VMFirmware -BootOrder $dvd, $hdd

# Connect the network adapter - run Get-VMSwitch if you're not sure which name to use.
#    There is a "Default switch" if you want a local NAT, but I prefer using a direct connection
$vm | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName "External"