#---------Query MetaData for SubscriptionID---------#
$response2 = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/instance?api-version=2018-02-01' -Method GET -Headers @{Metadata="true"} -UseBasicParsing
$subID = ($response2.Content | ConvertFrom-Json).compute.subscriptionId


#---------Get OAuth Token---------#
$response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' -Method GET -Headers @{Metadata="true"} -UseBasicParsing
$content = $response.Content | ConvertFrom-Json
$ArmToken = $content.access_token

#---------List Roles and Get Subscription Owner GUID---------#
$roleDefs = (Invoke-WebRequest -Uri (-join('https://management.azure.com/subscriptions/',$subID,'/providers/Microsoft.Authorization/roleDefinitions?api-version=2015-07-01')) -Method GET -Headers @{ Authorization ="Bearer $ArmToken"} -UseBasicParsing).Content | ConvertFrom-Json
$ownerGUID = ($roleDefs.value | ForEach-Object{ if ($_.properties.RoleName -eq 'Owner'){$_.name}})

#---------List current Subscription Owners---------#
$roleAssigns = (Invoke-WebRequest -Uri (-join('https://management.azure.com/subscriptions/',$subID,'/providers/Microsoft.Authorization/roleAssignments/?api-version=2015-07-01')) -Method GET -Headers @{ Authorization ="Bearer $ArmToken"} -UseBasicParsing).content | ConvertFrom-Json
$ownerList = ($roleAssigns.value.properties | where roleDefinitionId -like (-join('*',$ownerGUID,'*')) | select principalId)
Write-Host "Current 'Owner' Principal IDs ("($ownerList.Count)"):"
$ownerList | Out-Host


#---------Set JSON body for PUT request---------#
$JSONbody = @"
{
    "properties": {
        "roleDefinitionId": "/subscriptions/$subID/providers/Microsoft.Authorization/roleDefinitions/$ownerGUID", "principalId": "CHANGE-ME-TO-AN-ID"
    }
}
"@

#---------Add User as a Subscription Owner---------#
$fullResponse = (Invoke-WebRequest -Body $JSONbody -Uri (-join("https://management.azure.com/subscriptions/",$subID,"/providers/Microsoft.Authorization/roleAssignments/",$ownerGUID,"?api-version=2015-07-01")) -Method PUT -ContentType "application/json" -Headers @{ Authorization ="Bearer $ArmToken"} -UseBasicParsing).content | ConvertFrom-Json

#---------List updated Subscription Owners---------#
$roleAssigns = (Invoke-WebRequest -Uri (-join('https://management.azure.com/subscriptions/',$subID,'/providers/Microsoft.Authorization/roleAssignments/?api-version=2015-07-01')) -Method GET -Headers @{ Authorization ="Bearer $ArmToken"} -UseBasicParsing).content | ConvertFrom-Json
$ownerList = ($roleAssigns.value.properties | where roleDefinitionId -like (-join('*',$ownerGUID,'*')) | select principalId) 
Write-Host "Updated 'Owner' Principal IDs ("($ownerList.Count)"):"
$ownerList | Out-Host
