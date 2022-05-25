##
## This script leverages Microsoft Graph scripts in order to import the JSON files which deploy the baseline policies
## Before running the script, ensure all scripts and JSON files are present in the same working directory
## 
## Enter your admin username (e.g. intuneadmin@itpromentor.com); if the variable is not specified the script will prompt
## E.g. .\Setup-Intune.ps1 -User intuneadmin@itpromentor.com
##
## NOTE: No assignments will be made (policies will be imported but not deployed)
## To deploy the polices simply assign them to groups
##

Param (
    $User   
)
if($null -eq $User -or $User -eq ""){

    $User = Read-Host -Prompt "Please specify your user principal name for Intune administration"
    Write-Host
}


## Import enrollment restrictions - currently this just blocks Windows mobile platform
#.\Import-EnrollmentRestrictions.ps1 -User $User

## Import the iOS MDM policies
.\Import-Compliance.ps1 -ImportPath .\Compliance-iOS.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Config-iOS.json -User $User

## Import the Android MDM policies
.\Import-Compliance.ps1 -ImportPath .\Compliance-Android.json -User $User
#.\Import-DeviceConfig.ps1 -ImportPath .\Config-Android.json -User $User

## Import the macOS MDM policies
.\Import-Compliance.ps1 -ImportPath .\Compliance-macOS.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Config-macOS.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Endpoint-macOS.json -User $User

## Import the Windows 10 MDM policies
.\Import-Compliance.ps1 -ImportPath .\Compliance-Win10.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Windows10-Baseline-Defender-AV.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Windows10-Baseline-Firewall.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Windows10-Baseline-Security.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Windows10-BitLocker.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Windows10-DisableUSB.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Windows10-Delivery-Opt.json -User $User

#Import ADMX Policies
#.\

## Import the Windows 10 Update policies
.\Import-DeviceConfig.ps1 -ImportPath .\Windows10-Update-Ring-1.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Windows10-Update-Ring-2.json -User $User
.\Import-DeviceConfig.ps1 -ImportPath .\Windows10-Update-Ring-3.json -User $User

## Import the Office 365 application deployment policies
.\Import-Applications.ps1 -ImportPath .\Apps64-SAC.json -User $User
.\Import-Applications.ps1 -ImportPath .\Apps64-Monthly.json -User $User
.\Import-Applications.ps1 -ImportPath .\Apps32-SAC.json -User $User
.\Import-Applications.ps1 -ImportPath .\Apps32-Monthly.json -User $User

## Import the MAM policies for iOS and Android
.\Import-MAMPolicy.ps1 -ImportPath .\Android-MAM-withPIN.json -User $User
.\Import-MAMPolicy.ps1 -ImportPath .\iOS-MAM-withPIN.json -User $User
