Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

Login-AzureRmAccount | Out-Null
$subscription = "Visual Studio Enterprise"

Write-Information "selecting subscription: $subscription ..."
Select-AzureRmSubscription -SubscriptionName $subscription | Out-Null

Write-Information "obtaining access token ..."
$context = Get-AzureRmContext
$profile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($profile)
$accessToken = $profileClient.AcquireAccessToken($context.Subscription.TenantId).AccessToken

$vm = (Get-AzureRmVm)[0]
$osType = $vm.StorageProfile.OsDisk.OsType
$resourceId = $vm.Id

$commandLookup =
@{
    Linux = "RunShellScript"
    Windows = "RunPowerShellScript"
}

$parameters =
@{
    commandId = $commandLookup[$osType.ToString()]
    script =
    @(
        "ls /"
    )
    parameters =
    @(
        #@{
        #    name = ""
        #    value = ""
        #}
    )
}

$apiCall =
@{
    Method = "POST"
    Uri = "https://management.azure.com/$resourceId/runCommand?api-version=2017-03-30"
    ContentType = "application/json"
    Headers = @{ authorization = "bearer $accessToken" }
    Body = $parameters | ConvertTo-Json -Compress
}

$response = Invoke-WebRequest @apiCall -UseBasicParsing
$response.Headers["Azure-AsyncOperation"]