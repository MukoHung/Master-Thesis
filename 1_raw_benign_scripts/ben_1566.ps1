Import-Module ActiveDirectory
 
Function Get-ADGroupMemberFix {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string[]]
        $Identity
    )
    process {
        foreach ($GroupIdentity in $Identity) {
            $Group = $null
            $Group = Get-ADGroup -Identity $GroupIdentity -Properties Member
            if (-not $Group) {
                continue
            }
            Foreach ($Member in $Group.Member) {
                Get-ADObject $Member 
            }
        }
    }
}

#Get-ADGroupMemberFix 'GroupName' | Select-Object -Property Name | Export-CSV -NoTypeInformation -Path "./GroupName.csv"
#Get-ADGroupMemberFix 'GroupName' | Select-Object -Property Name | Write-Host