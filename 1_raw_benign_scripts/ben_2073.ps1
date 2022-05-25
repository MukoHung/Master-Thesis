<#
     Invoke-WmiMonitorBrightness.ps1 - Backlight control for screen brightness (Note: Does not work with ALS enabled)
#>

function Invoke-WmiMonitorBrightness() {
    Set-StrictMode -Version Latest

    [scriptblock] $GetMonitorBrightness = {
        (Get-Ciminstance -Namespace ROOT/wmi -ClassName WmiMonitorBrightness).CurrentBrightness
    }
    [scriptblock] $ResetMonitorToPolicyBrightness = {
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            (Get-WmiObject -Namespace ROOT/wmi -Class WmiMonitorBrightnessMethods).WmiRevertToPolicyBrightness()
        }
        else {
            powershell -NoProfile `
                       -NonInteractive `
                       -Command "&{(Get-WmiObject -Namespace ROOT/wmi -Class WmiMonitorBrightnessMethods).WmiRevertToPolicyBrightness()}"
        }
    }
    [scriptblock] $SetMonitorBrightness = {
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            (Get-WmiObject -Namespace ROOT/wmi -Class WmiMonitorBrightnessMethods).wmisetbrightness($delay, $brightness)
        }
        else {
            powershell -NoProfile `
                       -NonInteractive `
                       -Command "&{(Get-WmiObject -Namespace ROOT/wmi -Class WmiMonitorBrightnessMethods).wmisetbrightness($delay, $brightness)}"
        }
    }

    switch ($args.Count) {
        "0" {
            Write-Output "Brightness: $(& $GetMonitorBrightness)"
        }
        "1" {
            if ($args[0] -like "-R*") {
                & $ResetMonitorToPolicyBrightness
                Write-Output 'WmiRevertToPolicyBrightness();'
            }
            elseif ($args[0] -is [int]) {
                $delay = 0
                $brightness = $args[0]
                & $SetMonitorBrightness
                Write-Output "$('wmisetBrightness' + '(' + "$delay" + ',' + "$brightness" + ');')"
            }
            else {
                Write-Error "Unrecognized option: $args"
                Write-Output "Brightness: $(& $GetMonitorBrightness)"
            }
        }
        "2" {
            $delay = $args[0]
            $brightness = $args[1]
            & $SetMonitorBrightness
            Write-Output "$('wmisetBrightness' + '(' + "$delay" + ',' + "$brightness" + ');')"
        }
        "Default" {
            Write-Output "Brightness: $(& $GetMonitorBrightness)"
        }
    }
}

# If script is run directly, invoke embedded function piping any input or args to it.
if ($MyInvocation.ExpectingInput) {
    $input | Invoke-WmiMonitorBrightness @args
}
elseif (!($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq '')) {
    Invoke-WmiMonitorBrightness @args
}
else {
    # Else we're being dot-sourced, do nothing.
    # Optionally, set a short alias: New-Alias 'backlight' 'Invoke-WmiMonitorBrightness' -ErrorAction:Ignore
}