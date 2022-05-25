[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,Position=0,HelpMessage="vCenter Server")]
    [string]$vCenter
    )
# Also Accepts "-Verbose" Flag

Write-Host "UNMAPping all volumes on: $vCenter"

Import-Module VMware.VimAutomation.Core | Out-Null
Disconnect-VIServer * -Confirm:$false -Force | Out-Null  #Disconnect all previously connected vcenter servers
Connect-VIServer -Server $vCenter -Protocol https -Force | Out-Null

$datastores = Get-Datastore | where{$_.Type -eq 'VMFS'}
Write-Verbose "VMFS Datastores: $datastores"

foreach ($ds in $datastores) {
    $esx = Get-VMHost -Datastore $ds | Get-Random -Count 1
    $esxcli = Get-EsxCli -VMHost $esx
    Write-Host "Using $esx to unmap $ds"
    $esxcli.storage.vmfs.unmap($null,$ds,$null) | Out-Null
}
