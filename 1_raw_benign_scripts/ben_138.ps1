Write-Host "Writing AD Groups and Members to $env:working_directory\AD-Role-Members.csv"
Install-Module -Name AzureAD -Confirm:$false -Force

$username = $env:username
$password = ConvertTo-SecureString -String $env:password -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)

Connect-AzureAD -TenantID $env:tenant -Credential $psCred

$roleUsers = @() 
$roles=Get-AzureADDirectoryRole
 
ForEach($role in $roles) {
  $users=Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId
  ForEach($user in $users) {
    write-host $role.DisplayName,$user.DisplayName
    $obj = New-Object PSCustomObject
    $obj | Add-Member -type NoteProperty -name RoleName -value ""
    $obj | Add-Member -type NoteProperty -name UserDisplayName -value ""
    $obj | Add-Member -type NoteProperty -name IsAdSynced -value false
    $obj.RoleName=$role.DisplayName
    $obj.UserDisplayName=$user.DisplayName
    $obj.IsAdSynced=$user.DirSyncEnabled -eq $true
    $roleUsers+=$obj
  }
}
$roleUsers | Export-Csv -Encoding UTF8 -Delimiter ";" -Path "$env:working_directory\AD-Role-Members.csv" -NoTypeInformation