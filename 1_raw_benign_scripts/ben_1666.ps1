$machineAccountQuotaComputers = Get-ADComputer -filter {ms-DS-CreatorSID -ne "$null"} -Properties ms-DS-CreatorSID,Created

foreach ($machine in $machineAccountQuotaComputers) {
    $creator = $null
    try {
        $creator = [System.Security.Principal.SecurityIdentifier]::new($machine.'ms-DS-CreatorSID').Translate([System.Security.Principal.NTAccount]).Value
    }
    catch {
        $creator = $machine.'ms-DS-CreatorSID'
    }

    New-Object psobject -Property @{
        Name = $machine.Name
        DistinguishedName = $machine.DistinguishedName
        Creator = $creator
        Created = $machine.Created
    } | Select-Object Name,DistinguishedName,Creator,Created | Sort-Object -Property Created
}