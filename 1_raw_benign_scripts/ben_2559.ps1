#!/bin/bash -e
# A script to create an Azure KeyVault enabled for template deployment

#Change the values below before running the script
vaultName="myvault"               #Globally Unique Name of the KeyVault
vaultLocation="East US"           #Location of the KeyVault
resourceGroupName="vaults"        #Name of the resource group for the vault
resourceGroupLocation="East US"   #Location of the resource group if it needs to be created

#Login and Select the default subscription if needed
#azure login
#azure account set "subscription name"
azure config mode arm

azure group create "$resourceGroupName" "$resourceGroupLocation"

azure keyvault create --vault-name "$vaultName" --resource-group "$resourceGroupName" --location "$vaultLocation"

azure keyvault set-policy "$vaultName" --enabled-for-template-deployment true
