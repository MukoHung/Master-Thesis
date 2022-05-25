# Optional: Connect to Azure
# Connect-AzAccount

# Optional: Install MySQL module
# Install-Module -Name Az.MySql -AllowPrerelease

Clear-Host

#Variables
$PrimaryServerName      =   "primaryserverMAU015"
$SecondaryServerName    =   "secondaryserverMAU015"

$RgName                 =   "rg-MySQL"
$Sku                    =   "GP_Gen5_2"
$Location               =   "eastus"
$locationreplica        =   "westus"
$Username               =   "zaragozam"
$Password               =   "PA$$w0rd-01-or-02"

#Convert password to secure string
$Secure_String_Pwd = ConvertTo-SecureString $Password -AsPlainText -Force

# Build primary server
Write-Host "Creating server [$PrimaryServerName]" -ForegroundColor Yellow
New-AzMySqlServer -Name $PrimaryServerName -ResourceGroupName $RgName -Sku $Sku -GeoRedundantBackup Enabled -Location $Location -AdministratorUsername $Username -AdministratorLoginPassword $Secure_String_Pwd
Write-Host "Server [$PrimaryServerName] was created" -ForegroundColor Yellow

# Restarting primary server
Write-Host "Restarting server [$PrimaryServerName] to ensure it can be replicated" -ForegroundColor Cyan
Restart-AzMySqlServer -Name $PrimaryServerName -ResourceGroupName $rgName
Write-Host "[$PrimaryServerName] was restarted"  -ForegroundColor Cyan

# Create replica server
Write-Host "Creating replica server [$SecondaryServerName]" -ForegroundColor Green
$PrimaryServer= Get-AzMySqlServer -ResourceGroupName $RgName -ServerName $PrimaryServerName
New-AzMySqlReplica -master $PrimaryServer -Replica $SecondaryServerName -ResourceGroupName $RgName -Location $locationreplica
write-host "Replica [$SecondaryServerName] was created" -ForegroundColor Green


#$PrimaryReplica = Get-AzMySqlReplica -ResourceGroupName $RgName -ServerName $PrimaryServerName
#$primaryserver | Select-Object -property *