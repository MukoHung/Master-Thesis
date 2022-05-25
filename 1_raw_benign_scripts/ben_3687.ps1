[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $RiderHome
)

function Update-WindowsDefenderForRider {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $RiderHome
    )

    $directories = @()
    $directories += Get-ChildItem -Directory -Recurse $RiderHome\bin
    $directories += "$($RiderHome)\bin"
    $directories += Get-ChildItem -Directory -Recurse $RiderHome\lib\ReSharperHost
    $directories += "$($RiderHome)\lib\ReSharperHost"
    $directories += Get-ChildItem -Directory -Recurse $RiderHome\tools

    $directories | ForEach-Object {
        Add-MpPreference -ExclusionProcess "$($_)\*.dll"
        Add-MpPreference -ExclusionProcess "$($_)\*.exe"
    }
}

Update-WindowsDefenderForRider -RiderHome $RiderHome