Connect-AzureAD
$graph = Get-AzureADServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
$groupReadPermission = $graph.AppRoles `
    | where {($_.Value -Like "Group.Read.All") -or ($_.Value -Like "Group.Create") -or ($_.Value -Like "Group.ReadWrite.All") -or ($_.Value -Like "Directory.ReadWrite.All") }
# Use the Object Id as shown in the image above
$msi = Get-AzureADServicePrincipal -ObjectId "<Service Principal ID of function>"
foreach($permissions in $groupReadPermission){
New-AzureADServiceAppRoleAssignment `
    -Id $permissions.Id `
    -ObjectId $msi.ObjectId `
    -PrincipalId $msi.ObjectId `
    -ResourceId $graph.ObjectId
}