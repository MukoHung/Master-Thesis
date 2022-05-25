$vaultName = "<keyvaultnamehere>"

$secrets = Get-AzureKeyVaultSecret -VaultName $vaultName

$secrets | ForEach-Object {
    $name = $_.Name
    $value = (Get-AzureKeyVaultSecret -VaultName $vaultName -Name $name).SecretValueText
    Write-Host $name ":" $value
}