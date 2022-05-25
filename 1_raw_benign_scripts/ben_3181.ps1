function Get-OperatingSystem {
    [CmdletBinding()]
    param ()

    [version]$psVersion = (Get-Host).version

    if ( $psVersion.Major -ge 7 ) {
        # powershell 7+, we can use built in variable
        Write-Verbose "$functionName - Found Powershell version 7+."
        $OS = if ( $IsLinux ) {
            "Linux"
        } elseif ( $IsMacOS ) {
            "MacOS"
        } elseif ( $IsWindows ) {
            "Windows"
        } else {
            "Unknown"
        }
        Write-Verbose "$functionName - Determined OS is $OS."
    } elseif ( $psVersion.Major -eq 6 ) {
        # powershell version 6
        Write-Verbose "$functionName - Found Powershell version 6x."
        $OS = if ( $PSVersionTable.OS -like "*Linux*" ) {
            "Linux"
        } elseif ( $PSVersionTable.OS -like "*Darwin*"  ) {
            "MacOS"
        } elseif ( $PSVersionTable.OS -like "*windows*"  ) {
            "Windows"
        } else {
            "Unknown"
        }
        Write-Verbose "$functionName - Determined OS is $OS."
    } elseif ( $psVersion.Major -le 5 ) {
        # powershell version 5, can only be Windows
        Write-Verbose "$functionName - Found Powershell version 5."
        $OS = "Windows"
        Write-Verbose "$functionName - Determined OS is $OS (only available OS for this Powershell version)."
    }

    $OS
}