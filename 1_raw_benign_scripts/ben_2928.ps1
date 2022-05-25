<#
.SYNOPSIS

 This script leverages Microsoft Graph scripts in order to import the JSON files which deploy the baseline policies
 Before running the script, ensure all scripts and JSON files are present in the same working directory
 
 Enter your admin username (e.g. intuneadmin@valto.com); if the variable is not specified the script will prompt
 E.g. .\SETUP-ENDPOINT.ps1 -User intuneadmin@valto.com

NOTE: No assignments will be made (policies will be imported but not deployed)
To deploy the polices simply assign them to groups
##
#>

<#
    .NOTES

    WARNING: Check these policies do not clash with the Valto Intune Baseline settings.
    NOTE: Always deploy to a test group when assinging these profiles
#>

Param (
    $User   
)
if($null -eq $User -or $User -eq ""){

    $User = Read-Host -Prompt "Please specify your user principal name for Intune administration"
    Write-Host
}


## Import MacOS - Defender AntiVirus
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-MacOS-Defender-AV.json -User $User

## Import MacOS - Defender Firewall
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-MacOS-Firewall.json -User $User



## Import Windows - Account Protection (Disable Win Hello)
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-Win10-Account-Protection.json -User $User

## Import Windows - Attack Surface Reduction 
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-Win10-ASR-AppBrowser-Isolation.json -User $User
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-Win10-ASR-ApplicationControl.json -User $User
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-Win10-ASR-DeviceControl.json -User $User
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-Win10-ASR-Rules.json -User $User

## Import Windows - Defender AntiVirus 
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-Win10-Defender-AV.json -User $User
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-Win10-Defender-AV-Exclusions.json -User $User

## Import Windows - Defender Firewall 
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-Win10-Firewall-Rules.json -User $User
.\Import-EndpointPolicy.ps1 -ImportPath .\EndPoint-Win10-Firewall-Settings.json -User $User

## Import Windows - Security Experience
.\Import-EndpointPolicy.ps1 -ImportPath .\Valto-EndPoint-Deployment.json -User $User


## Import Windows - Compliance for Threat Level
.\Import-Compliance.ps1 -ImportPath .\EndPoint-Win10-Compliance.json -User $User

