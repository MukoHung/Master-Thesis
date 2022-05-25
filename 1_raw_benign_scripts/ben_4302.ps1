#Requires -Version 6.0

<#
The MIT License (MIT)

Copyright (c) 2019 Jari Turkia (jatu@hqcodeshop.fi)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>


<#
.SYNOPSIS
Script to trigger HTTPS-certificate update used by a Azure CDN custom domain

.DESCRIPTION
Script to trigger update of X.509 certificate from Azure Key Vault to be used
as HTTPS-certificate in Azure CDN custom domain.

For this command to work, a logged in Azure user is needed.
Also Key Vault will be accessed with that logged in user's credentials.

.EXAMPLE
./trigger-Azure-CDN-certificate-update.ps1 -cdnProfileName Static-web-CDN -keyVaultName Sample-KV -cdnEndpointName my-static-cdn -cdnCustomDomainName www-example-com -certificateName Wildcard-Example-com

.LINK
https://blog.hqcodeshop.fi/archives/445-Trigger-Azure-CDN-to-update-certificate-to-custom-domain-from-Key-Vault.html

.PARAMETER cdnProfileName
Azure CDN profile name

.PARAMETER cdnEndpointName
Endpoint in given Azure CDN profile

.PARAMETER cdnCustomDomainName
Custom domain name in given given Azure CDN profile and endpoint

.PARAMETER keyVaultName
Azure Key Vault name containing the certificate to be updated

.PARAMETER certificateName
Certificate name in given Key Vault. Latest version of certificate will be used.
#>
param(
    [Parameter(Mandatory=$True)]
    [string]
    $cdnProfileName,

    [Parameter(Mandatory=$True)]
    [string]
    $cdnEndpointName,

    [Parameter(Mandatory=$True)]
    [string]
    $cdnCustomDomainName,

    [Parameter(Mandatory=$True)]
    [string]
    $keyVaultName,

    [Parameter(Mandatory=$True)]
    [string]
    $certificateName
)



# https://gallery.technet.microsoft.com/scriptcenter/Easily-obtain-AccessToken-3ba6e593
if (-not (Get-Module Az.Accounts)) {
    Import-Module Az.Accounts
}

# See:
# https://stackoverflow.com/a/17330952/1548275

$keyVault = Get-AzKeyVault -VaultName $keyVaultName;
$certificate = Get-AzKeyVaultSecret -VaultName $keyVault.VaultName `
    -Name $certificateName;
$secretName = $certificate.Name;
$secretVersion = $certificate.Version;
$keyVaultResourceGroupName = $keyVault.ResourceGroupName;

$cdnProfile = Get-AzCdnProfile -ProfileName $cdnProfileName;
$resourceGroup = Get-AzResourceGroup -Name $cdnProfile.ResourceGroupName;
$resourceGroupName = $resourceGroup.ResourceGroupName;
$cdnEndpoint = Get-AzCdnEndpoint -ResourceGroupName $resourceGroup.ResourceGroupName `
    -ProfileName $cdnProfile.Name `
    -EndpointName $cdnEndpointName;
$cdnCustomDomain = Get-AzCdnCustomDomain -ResourceGroupName $resourceGroup.ResourceGroupName `
    -ProfileName $cdnProfile.Name `
    -EndpointName $cdnEndpointName `
    -CustomDomainName $cdnCustomDomainName;

# Authentication
$context = Get-AzContext;
$subscriptionId = $context.Subscription.Id;
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile;
if (-not $azProfile.Accounts.Count) {
    Write-Error "Naah. Ensure you have logged in before calling this."
    Exit 1
}
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile);
$token = $profileClient.AcquireAccessToken($context.Subscription.TenantId) ;
$accessToken = $token.AccessToken;
if (-not $accessToken) {
    Write-Error "Naah. Auth failed!";
    Exit 1
}

# Go update the cert!
# API docs: https://docs.microsoft.com/en-us/rest/api/cdn/customdomains/enablecustomhttps
$apiVersion = '2019-04-15';
$url = "https://management.azure.com" +
    "/subscriptions/$subscriptionId" +
    "/resourceGroups/$resourceGroupName" +
    "/providers/Microsoft.Cdn" +
    "/profiles/$cdnProfileName" +
    "/endpoints/$cdnEndpointName" +
    "/customDomains/$cdnCustomDomainName" +
    "/enableCustomHttps?api-version=$apiVersion"

# See API-docs for UserManagedHttpsParameters
$postParams = @{
    "certificateSource" = "AzureKeyVault"
    "certificateSourceParameters" = @{
        "@odata.type" = "#Microsoft.Azure.Cdn.Models.KeyVaultCertificateSourceParameters"
        "deleteRule" = "NoAction"
        "updateRule" = "NoAction"
        "subscriptionId" = $subscriptionId
        "resourceGroupName" = $keyVaultResourceGroupName
        "vaultName" = $keyVaultName
        "secretName" = $secretName
        "secretVersion" = $secretVersion
    }
    "protocolType" = "ServerNameIndication"
};
$params = @{
    ContentType = 'application/json'
    Headers = @{
        'accept' = 'application/json'
        'Authorization' = "Bearer " + $accessToken
    }
    Method = 'Post'
    URI = $url
};
$bodyJson = ($postParams | ConvertTo-Json);
Write-Debug "Body:\n$bodyJson"
Invoke-RestMethod @params -Body $bodyJson;
