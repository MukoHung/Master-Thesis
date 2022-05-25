param([switch]$cleanup, [switch]$keysonly, [switch]$keep_settings, [string]$soft_type)

if (!$soft_type) {
    echo @"

#####################
# UNINSTALL UTILITY #
#####################

SYNOPSIS:
    uninstall_WPA_series.ps1 -soft_type <type>  [ -cleanup ] [ -keep_settings ] [ -keysonly ]

OPTIONS:

    -soft_type <type>
            Software to be uninstalled

    -cleanup
            Deleted everything, including registry keys and user settings

    -keep_settings
            Keep user settings (even if -cleanup was specified)

    -keysonly
            Only registry keys should be deleted

"@

    exit
}

$soft = $soft_type -replace "(-View)", ""
echo @"

#####################
# UNINSTALL UTILITY #
#####################

 Soft Type: $soft_type
 Global name (settings): $soft

 Options:
"@


if ($cleanup) {
    echo "     -cleanup: All related files and registry keys will be deleted (unless -keep_settings is specified)"
}
if ($keep_settings) {
    echo "     -keep_settings: Settings files will be kept intact"
}
if ($keysonly) {
    echo "     -keyonly: Only registry keys will be removed (unless -cleanup is specified, in this case keys are also ripped out)"
}

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
$result = $Host.UI.PromptForChoice(" < Confirmation > ", "Really uninstall software as summarized above?", $choices, 0)

# If confirmed
if ($result -eq 0) {    
    echo @"

######################
# UNINSTALL SOFTWARE #
######################

"@
    if ($cleanup) {
        $keysonly = $false;
    }

    # Remove/create registry keys
    echo "Remove/Create registry keys..."
    Push-Location HKLM:\SOFTWARE
    if (test-path $soft_type) {
	rm -recurse $soft_type
    }
    if (test-path AIC) {
	rm AIC
    }
    if (!$cleanup -and !$keysonly) {
        if (! (test-path UIC)) {
	    New-Item UIC
        }
    } elseif (test-path UIC) {
        Remove-Item UIC
    }
    Pop-Location

    # Remove software files
    echo "Remove software actual files..."
    if (!$keysonly) {
        if (test-path "$env:programfiles\$soft_type") {
	    Remove-Item -r "$env:programfiles\$soft_type" -force
        }
    }

    # Remove settings
    echo "Remove settings files..."
    if ($cleanup -and !$keep_settings) {
        if (test-path "$env:userprofile\AppData\Roaming\$soft") {
            Remove-Item -r "$env:userprofile\AppData\Roaming\$soft" -force
        }
    }

}