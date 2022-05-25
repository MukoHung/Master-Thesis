# Combine the functionality of Find-ChattyZwaveDevices and Get-ZwaveNodeSecureOrPlus
# Executing this script can take a few minutes debending on the speed of the network and the size of your OZW log.
# Path to your Home Assistant shared folder - mapped drive on your windows machine
$haPath = "I:"

# Get the content of the Open Z-Wave cache file
Write-Progress -Activity "Reading Configuration"
[xml]$ozwCfg = Get-Content "$haPath\zwcfg_*.xml"

# Get valid zwave IDs
$validIds = $ozwCfg.Driver.Node | %{ $_.id }

# Append Root node devices to the id list
$validIds += $validIds | %{ "node-$($_)"}

# Read entity registry
$entReg = Get-Content "$haPath\.storage\core.entity_registry" | ConvertFrom-Json

# Display entities to be deleted
$entReg.data.entities | 
    ? { $_.platform -eq "zwave" } | 
    ? { !$validIds.Contains(($_.unique_id -split "-")[0]) -and !$validIds.Contains($_.unique_id)} 