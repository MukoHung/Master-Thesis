# Login to Azure
Login-AzAccount

# Select subscription
Select-AzSubscription -Subscription "UK D&C Solutions"

# Create VNET resource group
    New-AzResourceGroup -Name eoe-uks-vnet-rg -Location "UK South"

# route table -- OK
    # TEST
    Test-AzResourceGroupDeployment -ResourceGroupName eoe-uks-vnet-rg  -TemplateFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\Microsoft.Network\routeTables\routeTables.azuredeploy.json" -TemplateParameterFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\EOE\eoe.routeTables.parameters.json" -Verbose
    # DEPLOY
    New-AzResourceGroupDeployment -Name ("VNET-RT-resources-" + [System.DateTime]::Now.ToString("dd-MM-yy-HH-mm-ss")) -ResourceGroupName eoe-uks-vnet-rg  -TemplateFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\Microsoft.Network\routeTables\routeTables.azuredeploy.json" -TemplateParameterFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\EOE\eoe.routeTables.parameters.json" -Verbose

# nsg -- OK
    # TEST
    Test-AzResourceGroupDeployment -ResourceGroupName eoe-uks-vnet-rg  -TemplateFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\Microsoft.Network\networkSecurityGroups\networkSecurityGroups.azuredeploy.json" -TemplateParameterFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\EOE-GRS\eoe.networkSecurityGroups.parameters.json" -Verbose
    # DEPLOY
    New-AzResourceGroupDeployment -Name ("VNET-NSG-resources-" + [System.DateTime]::Now.ToString("dd-MM-yy-HH-mm-ss")) -ResourceGroupName eoe-uks-vnet-rg  -TemplateFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\Microsoft.Network\networkSecurityGroups\networkSecurityGroups.azuredeploy.json" -TemplateParameterFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\EOE-GRS\eoe.networkSecurityGroups.parameters.json" -Verbose

# VNET
    # TEST
    Test-AzResourceGroupDeployment -ResourceGroupName eoe-uks-vnet-rg  -TemplateFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\Microsoft.Network\virtualNetworks\virtualNetworks.azuredeploy.json" -TemplateParameterFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\EOE-GRS\eoe.virtualNetworks.parameters.json" -Verbose
    # DEPLOY
    New-AzResourceGroupDeployment -Name ("VNET-VNET-resources-" + [System.DateTime]::Now.ToString("dd-MM-yy-HH-mm-ss")) -ResourceGroupName eoe-uks-vnet-rg  -TemplateFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\Microsoft.Network\virtualNetworks\virtualNetworks.azuredeploy.json" -TemplateParameterFile "C:\Users\digiorgiot\OneDrive - Version 1\Documents\Git-PowershellScripts\GRS-AzDevOps\GRS\EOE-GRS\eoe.virtualNetworks.parameters.json" -Verbose


# Create FIREWALL resource group
New-AzureRmResourceGroup -Name eoe-uks-vnet-rg -Location "UK South"
# fortigate
# jumpbox


# Create 




# Create resource group
New-AzureRmResourceGroup -Name eoe-uks-vnet-rg -Location "UK South"


# TEST VNET
Test-AzResourceGroupDeployment -ResourceGroupName robinsonn-sandbox-rg -TemplateFile "C:\code-grs\GRS\Microsoft.Network\virtualNetworks\virtualNetworks.azuredeploy.json" -TemplateParameterFile "C:\code-grs\GRS\EOE\eoe.virtualNetworks.parameters.json"

New-AzResourceGroupDeployment -Name ("main-resources-" + [System.DateTime]::Now.ToString("dd-MM-yy-HH-mm-ss")) -ResourceGroupName robinsonn-sandbox-rg -TemplateFile "C:\code-grs\GRS\Microsoft.Network\virtualNetworks\virtualNetworks.azuredeploy.json" -TemplateParameterFile "C:\code-grs\GRS\EOE\eoe.virtualNetworks.parameters.json" -Verbose





Get-AzMarketplaceTerms -Publisher fortinet -Product fortinet_fortigate-vm_v5 -name fortinet_fg-vm_payg | Set-AzMarketplaceTerms -Accept


Test-AzDeployment  -Location "uksouth" -TemplateFile ".\GRS\master-template.json" -Verbose 

New-AzDeployment  -Location "uksouth" -TemplateFile ".\GRS\master-template.json" -Verbose