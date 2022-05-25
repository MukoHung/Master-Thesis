$Installed = Get-WmiObject -Class Win32Reg_AddRemovePrograms | Where-Object { $_.DisplayName -eq "Sentinel Agent" }

If ( -Not $Installed ) {
    # Sentinel Agent not installed/missing.
    Return $false
} Else {
    $Version = $Installed.Version
    $SentinelCtl = "C:\Program Files\SentinelOne\Sentinel Agent $Version\SentinelCtl.exe"
    $Status = & $SentinelCtl "status"

    $Compliant = $true

    If ( $Status -contains "SentinelAgent is not loaded" ) {
        $Compliant = $false
    } 

    If ( $Status -contains "SentinelCtl.exe was run from an old") {
        # Indicates mismatch between installed version and running version. Could be corrupted install.
        $Compliant = $false
    }

    If ( $Status -contains "SentinelMonitor is not loaded" ) {
        $Compliant = $false
    }

    <# Disabled, unsure how common this is disabled on healthy clients but common on systems with Agent unloaded.
    If ( $Status -contains "Self-Protection status: Off" ) {
        $Compliant = $false
    }
    #>

    Return $Compliant
}