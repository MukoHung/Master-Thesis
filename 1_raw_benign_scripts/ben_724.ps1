add-pssnapin VMware.VimAutomation.Core
add-pssnapin VMware.DeployAutomation
add-pssnapin VMware.ImageBuilder

<#
Define Variables - Change the below information to fit your environment.
#>

$vcenter = Read-Host "Enter address of vCenter server"
$vcenter_password = Read-Host -assecurestring "Enter VCenter Password"
$cluster_name = Read-Host "Enter NTNX Cluster Name"
$vm_Number = 1
$Starting_Ip = 93
$vaai = $true
$wait_for_ips = $false

Connect-VIServer $vcenter -User administrator@vsphere.local -Password $vcenter_password

Write-Host "`n===== Gathering Information =====" -fore "yellow"
Write-Host "What VM are you cloning?" -fore "green"
$base_clone = Read-Host
Write-Host "`nHow many clones do you need?" -fore "green"
$clone_count = Read-Host

Write-Host "`nDo you want to join VM to a Domain? [default = n]" -fore "green"
$joinDomainq = Read-Host
if ($joindomainq -eq 'y') {
  $domainName = Read-Host "Enter domain name"
  $domainAdmin = Read-Host "Enter domain admin username"
  $domainPassword = Read-Host -assecurestring "Enter domain password"
}

Clear-Host
Write-Host "`n"
Write-Host '**************** SUMMARY *************' -fore "yellow"
Write-Host '*                                    *' -fore "yellow"
Write-Host '**************************************' -fore "yellow"
Write-Host " Base Clone     -    $base_clone        " -fore "green"
Write-Host "**************************************" -fore "yellow"
Write-Host " Clone Count    -    $clone_count       " -fore "green"
Write-Host "**************************************" -fore "yellow"
if ($joindomainq -eq 'y'){
Write-Host " Domain         -    $domainName        " -fore "green"
Write-Host "**************************************" -fore "yellow"
}
Write-Host " Starting Name  -    FMRDS0$vm_Number  " -fore "green"
Write-Host "**************************************" -fore "yellow"
Write-Host " Starting IP    -    10.0.21.$Starting_Ip  " -fore "green"
Write-Host "**************************************" -fore "yellow"
Write-Host " Cluster        -    $cluster_name      " -fore "green"
Write-Host "**************************************" -fore "yellow"

Write-Host ""

Write-Host "`nIs everything OK? (y/n) [default = y]" -fore "red"
$sumAns = Read-Host

if (($sumAns -ne 'y') -and ($sumAns -ne 'Y') -and ($sumAns -ne 'yes') -and ($sumAns -ne '')){
  Write-Host "*** Exiting without changes ***" -fore "red"
  exit
}

$cluster = Get-Cluster | where {$_.name -match $cluster_name}
$hosts = Get-VMHost -Location $cluster
$source_vm = Get-VM -Location $cluster | where {$_.name -like $base_clone } | Get-View
$clone_folder = $source_vm.parent


# Clone Customizations
$clone_spec = new-object Vmware.Vim.VirtualMachineCloneSpec
$clone_spec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec
$clone_spec.Location.Transform = [Vmware.Vim.VirtualMachineRelocateTransformation]::flat
$clone_spec.customization = new-object Vmware.Vim.CustomizationSpec
$clone_spec.customization.options = New-Object VMware.Vim.CustomizationWinOptions
$clone_spec.customization.options.changeSID = $true
$clone_spec.customization.identity = New-Object VMware.Vim.CustomizationSysprep
$clone_spec.customization.identity.guiUnattended = New-Object VMware.Vim.CustomizationGuiUnattended
$clone_spec.customization.identity.guiUnattended.password = New-Object VMware.Vim.CustomizationPassword
$clone_spec.customization.identity.guiUnattended.password.value = "CHANGE_ME"
$clone_spec.customization.identity.guiUnattended.password.plainText = $true
$clone_spec.customization.identity.guiUnattended.timeZone = 260
$clone_spec.customization.identity.userData = New-Object VMware.Vim.CustomizationUserData
$clone_spec.customization.Identity.userData.productId = "CHANGE_ME"
$clone_spec.customization.identity.userData.fullName = "Administrator"
$clone_spec.customization.identity.userData.orgName = "CHANGE_ME"
$clone_spec.customization.identity.userData.computerName = New-Object VMware.Vim.CustomizationVirtualMachineName
$clone_spec.customization.identity.identification = New-Object VMware.Vim.CustomizationIdentification
$clone_spec.customization.identity.identification.domainAdmin = $domainAdmin
$clone_spec.customization.identity.identification.domainAdminPassword = New-Object VMware.Vim.CustomizationPassword
$clone_spec.customization.identity.identification.domainAdminPassword.plaintext = $true
$clone_spec.customization.identity.identification.domainAdminPassword.value = $domainPassword
$clone_spec.customization.identity.identification.JoinDomain = $domainName
$clone_spec.customization.globalIPSettings = New-Object VMware.Vim.CustomizationGlobalIPSettings
$clone_spec.customization.globalIPSettings.dnsServerList = "CHANGE_ME","CHANGE_ME"
$clone_spec.Customization.nicSettingMap = @(New-Object VMware.Vim.CustomizationAdapterMapping)
$clone_spec.customization.nicSettingMap[0].adapter = New-Object VMware.Vim.CustomizationIPSettings
$clone_spec.customization.nicSettingMap[0].adapter.dnsDomain = $domain
$clone_spec.customization.nicSettingMap[0].adapter.dnsServerList = "CHANGE_ME", "CHANGE_ME"
$clone_spec.customization.nicSettingMap[0].adapter.gateway = "CHANGE_ME"
$clone_spec.customization.nicSettingMap[0].adapter.ip = New-Object VMWare.Vim.CustomizationFixedIp
$clone_spec.customization.nicSettingMap[0].adapter.subnetMask = "255.255.255.0"

if ($vaai) {
  Write-Host "Cloning VM $base_clone using VAAI."
  $clone_spec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::moveAllDiskBackingsAndAllowSharing
  }else {
  Write-Host "Cloning VM $base_clone without VAAI."
  $clone_spec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::createNewChildDiskBacking
  $clone_spec.Snapshot = $source_vm.Snapshot.CurrentSnapshot
  }

Write-Host "Creating $clone_count VMs from VM: $base_clone"

# Create VMs.
$global:creation_start_time = Get-Date
for($i=1; $i -le $clone_count; $i++){
  $clone_name = "FMRDS0$vm_Number"
  $clone_spec.Location.host = $hosts[$i % $hosts.count].Id
  $clone_spec.customization.nicSettingMap[0].adapter.ip.IpAddress = "10.0.21.$Starting_Ip"
  $source_vm.CloneVM_Task( $clone_folder, $clone_name, $clone_spec ) | Out-Null
  $Starting_Ip++
  $vm_Number++
  }

# Wait for all VMs to finish being cloned.
$VMs = Get-VM -Location $cluster -Name "FMRDS0*"
while($VMs.count -lt $clone_count){
  $count = $VMs.count
  Write-Host "Waiting for VMs to finish creation. Only $count have been created so far..."
  $VMs = Get-VM -Location $cluster -Name "FMRDS0*"
  }

Write-Host "Powering on VMs"
# Power on newly created VMs.
$global:power_on_start_time = Get-Date
Start-VM -RunAsync "FMRDS0*" | Out-Null

$booted_clones = New-Object System.Collections.ArrayList
#$waiting_clones = New-Object System.Collections.ArrayList
while($booted_clones.count -lt $clone_count){
  # Wait until all VMs are booted.
  $clones = Get-VM -Location $cluster -Name "FMRDS0*"
  foreach ($clone in $clones){
    if((-not $booted_clones.contains($clone.Name)) -and ($clone.PowerState -eq "PoweredOn")){
      if($wait_for_ips){
        $ip = $clone.Guest.IPAddress[0]
        if ($ip){
	      Write-Host "$clone.Name started with ip: $ip"
          $booted_clones.add($clone.Name)
          }
        }
      else{
		$booted_clones.add($clone.Name)
	    }
      }
	}
  }

$global:total_runtime = $(Get-Date) - $global:creation_start_time
$global:power_on_runtime = $(Get-Date) - $global:power_on_start_time

Write-Host "Total time elapsed to boot $clone_count VMs: $global:power_on_runtime"
Write-Host "Total time elapsed to clone and boot $clone_count VMs: $global:total_runtime"
