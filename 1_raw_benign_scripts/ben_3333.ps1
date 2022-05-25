<#
.SYNOPSIS
    A script used to startup a home lab
.DESCRIPTION
    A script used to startup a home lab
#>

param(
    [Parameter(mandatory=$true)]
    [string]$Labname = "DetectionLab"
)

$Base_Dir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Defining the Lab
New-LabDefinition -Name $Labname -DefaultVirtualizationEngine HyperV

# Configuring the domain and local user accounts
Add-LabDomainDefinition -Name lab.local -AdminUser Administrator -AdminPassword StickyPot6 
Set-LabInstallationCredential -Username Administrator -Password StickyPot6

# Configuring the lab network
Add-LabVirtualNetworkDefinition -Name $Labname
Add-LabVirtualNetworkDefinition -Name 'Internet' -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Ethernet' }

# Domain Controlled definition
$postInstallActivity_Servers = @()
$postInstallActivity_Servers += Get-LabPostInstallationActivity -ScriptFileName Configure-Server.ps1 -DependencyFolder $labSources\PostInstallationActivities\MyLab\
$postInstallActivity_Servers += Get-LabPostInstallationActivity -ScriptFileName Install-Choco-Apps-Server.ps1 -DependencyFolder $labSources\PostInstallationActivities\MyLab\
$postInstallActivity_Servers += Get-LabPostInstallationActivity -ScriptFileName Configure-RDP-User-GPO.ps1 -DependencyFolder $labSources\PostInstallationActivities\MyLab\
$postInstallActivity_Servers += Get-LabPostInstallationActivity -ScriptFileName Configure-Local-Admin.ps1 -DependencyFolder $labSources\PostInstallationActivities\MyLab\
#$postInstallActivity_Servers += Get-LabPostInstallationActivity -ScriptFileName Set_Audit_Pol_PS_v2_3_4_5.cmd -DependencyFolder $labSources\PostInstallationActivities\MyLab\
Add-LabMachineDefinition -Name DC1 -Memory 1GB -OperatingSystem 'Windows Server 2019 Standard Evaluation (Desktop Experience)' -Roles RootDC -Network $Labname -DomainName lab.local -IpAddress 192.168.11.1 -PostInstallationActivity  $postInstallActivity_Servers

# Server definition used as a routerh to the internet
$netAdapter = @()
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $Labname -Ipv4Address 192.168.11.254 
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch 'Internet' -UseDhcp
Add-LabMachineDefinition -Name Router1 -Memory 1GB -OperatingSystem 'Windows Server 2019 Standard Evaluation (Desktop Experience)' -Roles Routing -NetworkAdapter $netAdapter -DomainName lab.local 

# Client definitions
$postInstallActivity_Clients = @()
$postInstallActivity_Clients += Get-LabPostInstallationActivity -ScriptFileName Remove-OneDrive.ps1 -DependencyFolder $labSources\PostInstallationActivities\MyLab\
$postInstallActivity_Clients += Get-LabPostInstallationActivity -ScriptFileName Remove-Default-Apps.ps1 -DependencyFolder $labSources\PostInstallationActivities\MyLab\
$postInstallActivity_Clients += Get-LabPostInstallationActivity -ScriptFileName Remove-Default-Apps.ps1 -DependencyFolder $labSources\PostInstallationActivities\MyLab\
$postInstallActivity_Clients += Get-LabPostInstallationActivity -ScriptFileName Install-Choco-Apps.ps1 -DependencyFolder $labSources\PostInstallationActivities\MyLab\
$postInstallActivity_Clients += Get-LabPostInstallationActivity -ScriptFileName Set_Audit_Pol_PS_v2_3_4_5.cmd -DependencyFolder $labSources\PostInstallationActivities\MyLab\
Add-LabMachineDefinition -Name Client1 -Memory 2GB -Network $Labname -OperatingSystem 'Windows 10 Enterprise Evaluation' -Roles Office2013 -DomainName lab.local -IpAddress 192.168.11.101 -PostInstallationActivity $postInstallActivity_Clients

# Aditinal resources for the Client Inastallation
Add-LabIsoImageDefinition -Name Office2013 -Path  "$labSources\Software\Office 2013.iso"

# Installation of the Lab
Install-Lab

#Disabling of Lab Auto Logon
Disable-LabAutoLogon

# Install Splunk
Copy-LabFileItem -Path C:\Users\tom\HomeLab\Resources\Splunk\splunk-add-on-for-microsoft-windows_800.tgz -DestinationFolderPath C:\Windows\Temp -ComputerName Router1
Invoke-LabCommand -ActivityName Instal-Splunk-Forwarder -FilePath C:\Users\tom\HomeLab\Resources\PostInstallationActiveties\MyLab\Install-Splunk-Server.ps1 -ComputerName Router1
Restart-LabVm -ComputerName Router1
Invoke-LabCommand -ActivityName Instal-Splunk-Forwarder -FilePath C:\Users\tom\HomeLab\Resources\PostInstallationActiveties\MyLab\Install-Splunk-Forwarder.ps1 -ComputerName Client1

# Copying Powershell module to all computers to facilitate the common tasks
Copy-LabFileItem -Path "$Base_Dir\Modules\Lab-Tools\" -DestinationFolderPath "C:\Program Files\WindowsPowerShell\Modules\" -ComputerName (Get-LabVm).name -Recurse

# Taking a Snapshot of all computer
Stop-LabVm -All -Wait
Checkpoint-LabVM -SnapshotName Baseline -All
Start-LabVm -All -Wait

# Commands used to install an applicaion post install on all computers quitetly
#$packs = @()
#$packs += Get-LabSoftwarePackage -Path $labSources\Software\kolide-launcher.msi -CommandLine -quiet
#Install-LabSoftwarePackages -Machine Client1 -SoftwarePackage $packs

# Displaying Lab Deployment Summary
Show-LabDeploymentSummary -Detailed

