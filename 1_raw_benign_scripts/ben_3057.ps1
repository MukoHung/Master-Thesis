function PNValidate {
    $Results = [PSCustomObject]@{
        Spooler                                    = $null
        PatchInstalled                             = $false
        RestrictDriverInstallationToAdministrators = $null
        NoWarningNoElevationOnInstall              = $null
        UpdatePromptSettings                       = $null
        Exploitable                                = $true
        Explanation                                = $null
    }

    # Check spooler status
    $Spooler = (Get-Service Spooler -ErrorAction SilentlyContinue).Status
    if (($null -eq $Spooler) -or ($Spooler -ne "Running")) {
        $Results.Spooler = "Secure"
    }
    else {
        $Results.Spooler = "Insecure"
    }
    
    # Check patch installation status
    $Patches = @("KB5004954", "KB5004958", "KB5004956", "KB5004960", "KB5004953", "KB5004951", "KB5004955", "KB5004959", "KB5004948", `
                "KB5004950", "KB5004945", "KB5004946", "KB5004947", "KB5004249", "KB5004238", "KB5004244", "KB5004245", "KB5004237", `
                "KB5004289", "KB5004307", "KB5004298", "KB5004285", "KB5004305", "KB5004299", "KB5004294", "KB5004302")
    $InstalledPatches = (Get-HotFix).HotFixID
    $Patches | % { if ($InstalledPatches -contains $_) { $Results.PatchInstalled = $true } }

    # Check registry keys
    # RestrictDriverInstallationToAdministrators
    $RestrictDriverInstallationToAdministrators = (Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -ErrorAction SilentlyContinue).RestrictDriverInstallationToAdministrators
    if (($RestrictDriverInstallationToAdministrators -eq $null) -or ($RestrictDriverInstallationToAdministrators -ne 1)) {
        $Results.RestrictDriverInstallationToAdministrators = "Insecure"
    }
    else {
        $Results.RestrictDriverInstallationToAdministrators = "Secure"
    }

    # NoWarningNoElevationOnInstall
    $NoWarningNoElevationOnInstall = (Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -ErrorAction SilentlyContinue).NoWarningNoElevationOnInstall
    if (($NoWarningNoElevationOnInstall -eq $null) -or ($NoWarningNoElevationOnInstall -eq 0)) {
        $Results.NoWarningNoElevationOnInstall = "Secure"
    }
    else {
        $Results.NoWarningNoElevationOnInstall = "Insecure"
    }
    
    # UpdatePromptSettings
    $UpdatePromptSettings = (Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -ErrorAction SilentlyContinue).UpdatePromptSettings
    if (($UpdatePromptSettings -eq $null) -or ($UpdatePromptSettings -eq 0)) {
        $Results.UpdatePromptSettings = "Secure"
    }
    else {
        $Results.UpdatePromptSettings = "Insecure"
    }

    # Validate results
    if ($Results.Spooler -eq "Secure") {
        $Results.Exploitable = $false
        $Results.Explanation = "Not exploitable as spooler service is not running"
    }
    elseif (($Results.PatchInstalled -eq $true) -and ($Results.RestrictDriverInstallationToAdministrators -eq "Secure")) {
        $Results.Exploitable = $false
        $Results.Explanation = "Not exploitable as patch is installed and RestrictDriverInstallationToAdministrators is set to secure value"
    }
    else {
        if ($Results.PatchInstalled -eq $true) {
            if ($Results.NoWarningNoElevationOnInstall -eq "Insecure") {
                $Results.Explanation = "Exploitable as NoWarningNoElevationOnInstall is set to insecure value"
            }
            elseif (($Results.NoWarningNoElevationOnInstall -eq "Secure") -and ($Results.UpdatePromptSettings -eq "Secure")) {
                $Results.Exploitable = $false
                $Results.Explanation = "Not exploitable as patch is installed and the registry settings NoWarningNoElevationOnInstall and UpdatePromptSettings are both set to secure values"
            }
            elseif (($Results.NoWarningNoElevationOnInstall -eq "Secure") -and ($Results.UpdatePromptSettings -eq "Insecure")) {
                $Results.Explanation = "Exploitable as UpdatePromptSettings is set to insecure value"
            }
        }
        else {
            $Results.Explanation = "Exploitable as patch is not installed"
        }
    }
    $Results
}