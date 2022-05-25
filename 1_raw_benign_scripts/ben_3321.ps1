###################
# Reset-AzOpsTenant #
###################
#Version: 02-08-2021
#Author: Liam F. O'Neill 
#Email:  lioneill@microsoft.com
#Contributor: Paul Grimley

<#
.SYNOPSIS
Fully resets an AAD tenant after deploying Enterprise Scale so it can be deployed again. BEWARE: THIS WILL DELETE ALL OF YOUR AZURE RESOURCES. USE WITH CAUTION.
.DESCRIPTION
Fully resets an AAD tenant after deploying Enterprise Scale so it can be deployed again. BEWARE: THIS WILL DELETE ALL OF YOUR AZURE RESOURCES. USE WITH CAUTION.
.EXAMPLE
.\reset-azopstenant.ps1 -topLevelGroupID "ESLZOrg" -enterpriseScaleAdRegistration = "Enterprise-Scale"
.NOTES
Learn More About Enterprise Scale Here:
https://github.com/azure/Enterprise-Scale
https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/
.LINK
https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/
Release notes 02-08-2021: 
This version has been enhanced to support recursive child groups from only the top level management group defined and supports Canary approach.
This release also fixes scenario where user has access to multiple tenants where previously this would error.
GroupName has been changes to GroupId as per warning message Upcoming breaking changes in the cmdlet 'Get-AzManagementGroup'as documented https://aka.ms/azps-changewarnings.
Warnings have been disabled
#>


[CmdletBinding()]
param (
    #Added this back into parameters as error occurs if multiple tenants are found when using Get-AzTenant
    [Parameter(Mandatory=$true,Position=1,HelpMessage="Please Insert Tenant ID (GUID) of your Azure AD tenant.")]
    [string]
    $tenantRootGroup="<Insert Tenant ID (GUID) of your Azure AD tenant>",

    [Parameter(Mandatory=$true,Position=2,HelpMessage="Please Enter the name of the highest level Enterprise-Scale Management Group.")]
    [string]
    $topLevelGroupID="myorg-1",

    [Parameter(Mandatory=$false,Position=3,HelpMessage="Please enter the display name of your enterprise scale app registration in Azure AD. If left blank, no app registration is deleted")]
    [string]
    $enterpriseScaleAdRegistration = ""
)

#Toggle to stop warnings with regards to DisplayName and DisplayId
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

$StopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$StopWatch.Start()

Write-Host "Moving all subscriptions under root management group"
$subscriptions = Get-AzSubscription

# TODO: Don't try and move subscriptions who are not already part of a management group. You will see an error for each of these subscriptions but doesn't affect functionality of the script
$subscriptions | ForEach-Object -Parallel {
    # The name 'Tenant Root Group' doesn't work. Instead, use the GUID of your Tenant Root Group
    if ($_.State -ne "Disabled"){
    New-AzManagementGroupSubscription -GroupId $using:tenantRootGroup -SubscriptionId $_.Id
    }    
}

Write-Host "Removing all Azure resources and resource groups"
ForEach ($subscription in $subscriptions) {
    Set-AzContext -Subscription $subscription.Id
    $resources = Get-AzResourceGroup
    $resources | ForEach-Object -Parallel {
        Write-Host "Deleting " $_.ResourceGroupName "..."
        Remove-AzResourceGroup -Name $_.ResourceGroupName -Force
    }
}

$tenantDeployments = Get-AzTenantDeployment

Write-Host "Removing all" $tenantDeployments.count "tenant level deployments"
$tenantDeployments | ForEach-Object -Parallel {
    Write-Host "Removing" $_.DeploymentName "..."
    Remove-AzTenantDeployment -Id $_.Id
}

if ($enterpriseScaleAdRegistration -ne "")
{
Write-Host "Removing your AD Application:" $enterpriseScaleAdRegistration
Remove-AzADApplication -DisplayName $enterpriseScaleAdRegistration -Force
}
else 
{
Write-Host "No AD application will be removed."
}

remove-recursively($topLevelGroupID)
#Added following function as per https://stackoverflow.com/questions/62809970/recursively-delete-azure-management-groups-nested-lists-inside-psobject Minor update to use GroupId. 
#This only deletes management groups under the specified top level and will not delete other top level management groups and their children e.g. in the case of canary
function remove-recursively($name)
{
#Enters the parent Level
Write-Host "Entering the scope with $name" -ForegroundColor Green
$parent = Get-AzManagementGroup -GroupId $name -Expand -Recurse

#Checks if there is any parent level.
if($null -ne $parent.Children)
{
Write-Host "Found the following Children :" -ForegroundColor White
Write-host ($parent.Children | Select-Object Name).Name -ForegroundColor Yellow
foreach($children in $parent.Children)
{
#tries to recurs to each child item
remove-recursively($children.Name)
}
}

#this below executes if all the child items are deleted or if doesn't have any child item
Write-Host "Removing the scope $name" -ForegroundColor Cyan
#Comment the below line if you just want to understand the flow
Remove-AzManagementGroup -InputObject $parent
}

$StopWatch.Stop()
$StopWatch.Elapsed