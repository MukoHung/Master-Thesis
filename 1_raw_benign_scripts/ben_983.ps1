param (
    [string]$vmName = (Read-Host "Provide VM Name"),
    [string]$vmFlavour = (Read-Host "What flavour of server do you want? Web/Gravis/Vanilla"),
    [string]$vmSize = (Read-Host "Instance Size? Small/Medium/Large")
)

# Import Configuration
. (Join-Path -Path (Split-Path -parent $MyInvocation.MyCommand.Definition) -ChildPath "configuration.ps1")
# Load VMware Module
if ((Get-PSSnapin | Where-Object { $_.Name -eq "VMware.VimAutomation.Core" }) -eq $null) { Add-PSSnapin VMware.VimAutomation.Core }
# Connect to vCenter
Connect-VMHost

### Variables ###
$domainName = "tron.justfen.co.uk"
$fqdn = "$vmName.$domainName"
$OSCustom = "Windows"
# Highest amount of disk space required for VM 
$RequiredDisk = 80000
$Pool = Get-ResourcePool "TRON"
# Will calculate Datastore with most free space, useful until Storage DRS setup
$DataStore = Get-Datastore | Where { $_.FreespaceMB -gt $RequiredDisk } | Sort-Object FreeSpaceMB -Descending | Select -First 1
if (!$Datastore) { throw "No Datastore could be found with $RequiredDisk MB free space." }
# Will chose ESX host with least CPU utilization, maybe RAM would be a better choice
$ESXHost = Get-VMHost | Sort $_.CPuUsageMhz | Select -First 1

### Functions ###

function emailconfirm {
    $smtp = "mail.london.justfen.co.uk"
    $from = "vmware@tron.justfen.co.uk"
    $to = "ITSupport@justfen.co.uk"
    $subject = "Created VM $fqdn is Online!"
    $body = "$fqdn is online, Way to go champ!"
    Send-Mailmessage -SmtpServer $smtp -From $from -To $to -Subject $subject -Body $body
}

function MakeVM {
    New-VM -vmhost $ESXHost `
    -Name $vmName `
    -Template $Template `
    -ResourcePool $Pool `
    -Datastore $DataStore `
    -OSCustomizationSpec $OSCustom
    Start-VM -VM $vmName
}

function AddToGravisSec {
    $SecGroups = "Gravis Servers"
    # Create a PSDrive to manipulate AD
    New-PSDrive -PSProvider ActiveDirectory -Name TRON -Root "" -Server "$domainName" 
    chdir TRON:
    # Check if machine is part of security group
    if ((Get-ADGroupMember $SecGroups | Where-Object { $_.Name -eq "$vmName" }) -eq $null){ 
        # Find the PC, grab GUID and feed into AD
        $target = Get-ADComputer -Filter {name -eq $vmName} | Select -Expand ObjectGUID
        Add-ADPrincipalGroupMembership -Identity $target -MemberOf "$SecGroups"
        Write-Host -ForegroundColor Green "Added $fqdn to the $SecGroups security group"
    }
    else {
        Write-Host -ForegroundColor Green "$fqdn is already part of $SecGroups, moving on!"
    }
    # Have to hop out of PSDrive to remove it :(
    chdir C:
    Remove-PSDrive -Name TRON
}

function AddToWebSec {
    $SecGroups = "Web Servers"
    # Create a PSDrive to manipulate AD
    New-PSDrive -PSProvider ActiveDirectory -Name TRON -Root "" -Server "$domainName" 
    chdir TRON:
    # Check if machine is part of security group
    if ((Get-ADGroupMember $SecGroups | Where-Object { $_.Name -eq "$vmName" }) -eq $null){ 
        # Find the PC, grab GUID and feed into AD
        $target = Get-ADComputer -Filter {name -eq $vmName} | Select -Expand ObjectGUID
        Add-ADPrincipalGroupMembership -Identity $target -MemberOf "$SecGroups"
        Write-Host -ForegroundColor Green "Added $fqdn to the $SecGroups security group"
    }
    else {
        Write-Host -ForegroundColor Green "$fqdn is already part of $SecGroups, moving on!"
    }
    # Have to hop out of PSDrive to remove it :(
    chdir C:
    Remove-PSDrive -Name TRON
}

# Need to select the right template

if {$vmName }
switch ($vmSize) {
    small {$Template = "windows40"}
    medium {$Template = "windows60"}
    large {$Template = "windows80"}
    default {Write-Host -ForegroundColor Green "Invalid instance size, Small, Medium or Large only"}
}
# Logic for security groups and checking if VM exists
if ((Get-VM | Where-Object { $_.Name -eq "$vmName" }) -eq $null) {
    switch ($vmFlavour) {
    Web {MakeVM
        Write-Host -ForegroundColor Green "Waiting for $vmName to join $domainName"
        Start-Sleep -Second 360
        AddToWebSec
        emailconfirm }
    Gravis {MakeVM
        Write-Host -ForegroundColor Green "Waiting for $vmName to join $domainName"
        Start-Sleep -Second 360
        AddToGravisSec
        emailconfirm }
    Vanilla {MakeVM
        emailconfirm }
    default {Write-Host -ForegroundColor Green "I guess you don't want a VM :'("}
    }
else {
    Write-Host -ForegroundColor Green "VM Already Exists, choose another name"
    Get-VM
    }
}
