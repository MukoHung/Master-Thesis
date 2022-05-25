# Move.ps1
# Written by Jessie C
# The purpose of this script is to move the new computer to the OU of the 
# original computer or another computer on the network.

[CmdletBinding()]
param(
    [parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    $FromComputer,
    [parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    $ToComputer
)

process
{
    Import-Module activedirectory
    $ToClient = Get-AdComputer -Identity $ToComputer
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($root)
    $searcher.Filter = "(&(objectClass=computer)(name=$FromComputer))"
    [System.DirectoryServices.SearchResult]$result = $searcher.FindOne()
    if (!$?)
    {
        return
    }
    $dn = $result.Properties["distinguishedName"]
    $ouResult = $dn.Substring($FromComputer.Length + 4)
    if ($ValueOnly)
    {
        $ouResult
    } else {
        # New-Object PSObject -Property @{"Name" = $FromComputer; "OU" = $ouResult}
        Get-ADComputer $ToClient | 
        Move-ADObject -TargetPath $ouResult 
        Write-Host ""
        Write-Host "Moving Computer to " $ouResult
    }
}