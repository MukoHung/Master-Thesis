$VC = Read-Host "Enter the vcenter name or address"
$password = Read-Host "Please enter the root password"
$DNSSearch = Read-Host "Please enter the DNS Search Path comma seperated"
$FQDN = Read-Host "Please enter the FQDN of this machine"
$IPAddress = Read-Host "Please enter the IP Address"
$Netmask = Read-Host "Please enter the Network Mask"
$Gateway = Read-Host "Please enter the Default Gateway"
$DNSServers = Read-Host "Please enter the DNS Servers comma seperated"
$TimeZone = Read-Host "Please enter the Timezone (Etc/UTC)"
$DeploymentOption = Read-Host "Please enter the deployment option"
$PortGroup = Read-Host "Please enter the PortGroup Name"
$FolderName = Read-Host "Please enter the VM Folder Name"
connect-viserver $VC

#datastore to place OVF on
#consider just looking for most free space outside of specific needs
#  $ds = $vmhost | Get-datastore | Sort FreeSpaceGB -Descending 
$ds =  read-host "Enter the name of your Datastore"

#Path to SHA1 version of ova
$ovfPath = "c:\temp\vRealize-Operations-Manager-Appliance-8.0.0.14857692_OVF10-sha1.ova"
#find least used host
$vmhost = Get-VMHost | where {$_.ConnectionState -ne "Maintenance" } | Sort MemoryUsageGB | Select -first 1

#build the hashtable
$ovfconfig = get-OvfConfiguration $ovfPath
$ovfconfig.ToHashtable()

#00
#find least used host
$vmhost = Get-VMHost | where {$_.ConnectionState -ne "Maintenance" } | Sort MemoryUsageGB | Select -first 1
$ovfconfig = @{
#DNS Search Domain
"vami.searchpath.vRealize_Operations_Manager_Appliance" = $DNSSearch;
#FQDN
"vami.domain.vRealize_Operations_Manager_Appliance" = $FQDN;
# IP Address
"vami.ip0.vRealize_Operations_Manager_Appliance" = $IPAddress;
# Netmask
"vami.netmask0.vRealize_Operations_Manager_Appliance" = $Netmask;
# Gateway
"vami.gateway.vRealize_Operations_Manager_Appliance" = $Gateway;
# DNS Servers
"vami.DNS.vRealize_Operations_Manager_Appliance" = $DNSServers;
#Force Enable IPv6
"forceIpv6" = $false;
#Time Zone
"vamitimezone" = $TimeZone;
# xsmall,small,medium,large,smallrc,largerc
"DeploymentOption" = $DeploymentOption;
# vSphere Portgroup Network Mapping
"NetworkMapping.Network 1" = $PortGroup;
# IP Protocol
"IpAssignment.IpProtocol" = "IPv4";
}
 
Import-VApp -Source $ovfPath -Datastore $ds -DiskStorageFormat Thin -Name $FQDN -OvfConfiguration $ovfconfig -VMHost $vmhost -InventoryLocation $FolderName

get-vm -name $FQDN | Start-VM