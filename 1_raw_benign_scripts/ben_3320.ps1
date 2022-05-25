<#
.SYNOPSIS
    Resets all the default PowerShell 5 aliases.
.NOTES
    This script must be run by dot-sourcing if you want it to clear the defaul aliases.

    It can take quite a while when it's validating all of the commands (a minute and a half, on my system), so it is by far fastest to run it in -Force
.EXAMPLE
    Reset-Alias.ps1 -Force -Quiet

    Running the script with -Force will set all aliases, regardless of the availability of the commands.
    Adding the -Quiet parameter hides the progress output and makes the command run as fast as possible.
.EXAMPLE
    . Reset-Alias.ps1

    Running the script with no parameters will remove and re-create all aliases, warning about commands that are missing and about aliases that obscure existing commands
.EXAMPLE
    . Reset-Alias.ps1 -IgnoreMissing

    Cleans and resets all aliases, warning only about native commands that are hidden by aliases
.EXAMPLE
    . Reset-Alias.ps1 -NoSquash -IgnoreMissing

    Cleans and resets all aliases, avoiding aliases that will obscure commands, and warning about native commands that are hidden by aliases
#>
[CmdletBinding()]
param(
    # Ignore missing commands: doesn't set the alias, doesn't warn the user
    [switch]$IgnoreMissing,

    # Don't squash existing commands, skip setting aliases if they would hinder easy access to a command
    [switch]$NoSquash,

    # Total silence: no warnings, no progress output
    [switch]$Quiet,

    # Force setting all aliases, skipping tests, to run faster
    [switch]$Force
)
if($MyInvocation.InvocationName -eq ".") {
    (Get-Alias).ForEach( { Remove-Item "Alias:$($_.Name)" -Force -ErrorAction SilentlyContinue} )
    if ( (Get-Alias -Scope global).Count -gt 0 ) {
        Write-Warning "Aliases not cleaned. To remove existing aliases you must dot-source this script in the global scope (i.e. your profile)."
    }
} else {
    Write-Warning "Aliases not cleaned. To remove existing aliases you must dot-source this script in the global scope (i.e. your profile)."
}

<# # Generated from this, in Windows PowerShell 5.1:
    Get-Alias |
        Where-Object {!$_.Source} |
        ForEach-Object {
            $cmd = Get-Command $_.Definition
            [PSCustomObject]@{
                Name       = $_.Name
                Definition = "$($cmd.Source)\$($_.Definition)"
                Module     = $cmd.Source
                Command    = $_.Definition
            }
        } |
        Sort-Object Module, Command, Name |
        ForEach-Object {
            "`t`"$($_.Name)`" = `"$($_.Definition)`""
        } | clip
#>
$GlobalAliases = [ordered]@{
    "clear"   = "Clear-Host"
    "cls"     = "Clear-Host"
    "man"     = "help"
    "md"      = "mkdir"

    "ise"     = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe"

    "asnp"    = "Microsoft.PowerShell.Core\Add-PSSnapIn"
    "clhy"    = "Microsoft.PowerShell.Core\Clear-History"
    "cnsn"    = "Microsoft.PowerShell.Core\Connect-PSSession"
    "dnsn"    = "Microsoft.PowerShell.Core\Disconnect-PSSession"
    "etsn"    = "Microsoft.PowerShell.Core\Enter-PSSession"
    "exsn"    = "Microsoft.PowerShell.Core\Exit-PSSession"
    "%"       = "Microsoft.PowerShell.Core\ForEach-Object"
    "foreach" = "Microsoft.PowerShell.Core\ForEach-Object"
    "gcm"     = "Microsoft.PowerShell.Core\Get-Command"
    "ghy"     = "Microsoft.PowerShell.Core\Get-History"
    "h"       = "Microsoft.PowerShell.Core\Get-History"
    "history" = "Microsoft.PowerShell.Core\Get-History"
    "gjb"     = "Microsoft.PowerShell.Core\Get-Job"
    "gmo"     = "Microsoft.PowerShell.Core\Get-Module"
    "gsn"     = "Microsoft.PowerShell.Core\Get-PSSession"
    "gsnp"    = "Microsoft.PowerShell.Core\Get-PSSnapIn"
    "ipmo"    = "Microsoft.PowerShell.Core\Import-Module"
    "icm"     = "Microsoft.PowerShell.Core\Invoke-Command"
    "ihy"     = "Microsoft.PowerShell.Core\Invoke-History"
    "r"       = "Microsoft.PowerShell.Core\Invoke-History"
    "nmo"     = "Microsoft.PowerShell.Core\New-Module"
    "nsn"     = "Microsoft.PowerShell.Core\New-PSSession"
    "npssc"   = "Microsoft.PowerShell.Core\New-PSSessionConfigurationFile"
    "oh"      = "Microsoft.PowerShell.Core\Out-Host"
    "rcjb"    = "Microsoft.PowerShell.Core\Receive-Job"
    "rcsn"    = "Microsoft.PowerShell.Core\Receive-PSSession"
    "rjb"     = "Microsoft.PowerShell.Core\Remove-Job"
    "rmo"     = "Microsoft.PowerShell.Core\Remove-Module"
    "rsn"     = "Microsoft.PowerShell.Core\Remove-PSSession"
    "rsnp"    = "Microsoft.PowerShell.Core\Remove-PSSnapin"
    "rujb"    = "Microsoft.PowerShell.Core\Resume-Job"
    "sajb"    = "Microsoft.PowerShell.Core\Start-Job"
    "spjb"    = "Microsoft.PowerShell.Core\Stop-Job"
    "sujb"    = "Microsoft.PowerShell.Core\Suspend-Job"
    "wjb"     = "Microsoft.PowerShell.Core\Wait-Job"
    "?"       = "Microsoft.PowerShell.Core\Where-Object"
    "where"   = "Microsoft.PowerShell.Core\Where-Object"
    "ac"      = "Microsoft.PowerShell.Management\Add-Content"
    "clc"     = "Microsoft.PowerShell.Management\Clear-Content"
    "cli"     = "Microsoft.PowerShell.Management\Clear-Item"
    "clp"     = "Microsoft.PowerShell.Management\Clear-ItemProperty"
    "cvpa"    = "Microsoft.PowerShell.Management\Convert-Path"
    "copy"    = "Microsoft.PowerShell.Management\Copy-Item"
    "cp"      = "Microsoft.PowerShell.Management\Copy-Item"
    "cpi"     = "Microsoft.PowerShell.Management\Copy-Item"
    "cpp"     = "Microsoft.PowerShell.Management\Copy-ItemProperty"
    "dir"     = "Microsoft.PowerShell.Management\Get-ChildItem"
    "gci"     = "Microsoft.PowerShell.Management\Get-ChildItem"
    "ls"      = "Microsoft.PowerShell.Management\Get-ChildItem"
    "cat"     = "Microsoft.PowerShell.Management\Get-Content"
    "gc"      = "Microsoft.PowerShell.Management\Get-Content"
    "type"    = "Microsoft.PowerShell.Management\Get-Content"
    "gi"      = "Microsoft.PowerShell.Management\Get-Item"
    "gp"      = "Microsoft.PowerShell.Management\Get-ItemProperty"
    "gpv"     = "Microsoft.PowerShell.Management\Get-ItemPropertyValue"
    "gl"      = "Microsoft.PowerShell.Management\Get-Location"
    "pwd"     = "Microsoft.PowerShell.Management\Get-Location"
    "gps"     = "Microsoft.PowerShell.Management\Get-Process"
    "ps"      = "Microsoft.PowerShell.Management\Get-Process"
    "gdr"     = "Microsoft.PowerShell.Management\Get-PSDrive"
    "gsv"     = "Microsoft.PowerShell.Management\Get-Service"
    "gwmi"    = "Microsoft.PowerShell.Management\Get-WmiObject"
    "ii"      = "Microsoft.PowerShell.Management\Invoke-Item"
    "iwmi"    = "Microsoft.PowerShell.Management\Invoke-WMIMethod"
    "mi"      = "Microsoft.PowerShell.Management\Move-Item"
    "move"    = "Microsoft.PowerShell.Management\Move-Item"
    "mv"      = "Microsoft.PowerShell.Management\Move-Item"
    "mp"      = "Microsoft.PowerShell.Management\Move-ItemProperty"
    "ni"      = "Microsoft.PowerShell.Management\New-Item"
    "mount"   = "Microsoft.PowerShell.Management\New-PSDrive"
    "ndr"     = "Microsoft.PowerShell.Management\New-PSDrive"
    "popd"    = "Microsoft.PowerShell.Management\Pop-Location"
    "pushd"   = "Microsoft.PowerShell.Management\Push-Location"
    "del"     = "Microsoft.PowerShell.Management\Remove-Item"
    "erase"   = "Microsoft.PowerShell.Management\Remove-Item"
    "rd"      = "Microsoft.PowerShell.Management\Remove-Item"
    "ri"      = "Microsoft.PowerShell.Management\Remove-Item"
    "rm"      = "Microsoft.PowerShell.Management\Remove-Item"
    "rmdir"   = "Microsoft.PowerShell.Management\Remove-Item"
    "rp"      = "Microsoft.PowerShell.Management\Remove-ItemProperty"
    "rdr"     = "Microsoft.PowerShell.Management\Remove-PSDrive"
    "rwmi"    = "Microsoft.PowerShell.Management\Remove-WMIObject"
    "ren"     = "Microsoft.PowerShell.Management\Rename-Item"
    "rni"     = "Microsoft.PowerShell.Management\Rename-Item"
    "rnp"     = "Microsoft.PowerShell.Management\Rename-ItemProperty"
    "rvpa"    = "Microsoft.PowerShell.Management\Resolve-Path"
    "sc"      = "Microsoft.PowerShell.Management\Set-Content"
    "si"      = "Microsoft.PowerShell.Management\Set-Item"
    "sp"      = "Microsoft.PowerShell.Management\Set-ItemProperty"
    "cd"      = "Microsoft.PowerShell.Management\Set-Location"
    "chdir"   = "Microsoft.PowerShell.Management\Set-Location"
    "sl"      = "Microsoft.PowerShell.Management\Set-Location"
    "swmi"    = "Microsoft.PowerShell.Management\Set-WMIInstance"
    "saps"    = "Microsoft.PowerShell.Management\Start-Process"
    "start"   = "Microsoft.PowerShell.Management\Start-Process"
    "sasv"    = "Microsoft.PowerShell.Management\Start-Service"
    "kill"    = "Microsoft.PowerShell.Management\Stop-Process"
    "spps"    = "Microsoft.PowerShell.Management\Stop-Process"
    "spsv"    = "Microsoft.PowerShell.Management\Stop-Service"
    "clv"     = "Microsoft.PowerShell.Utility\Clear-Variable"
    "compare" = "Microsoft.PowerShell.Utility\Compare-Object"
    "diff"    = "Microsoft.PowerShell.Utility\Compare-Object"
    "dbp"     = "Microsoft.PowerShell.Utility\Disable-PSBreakpoint"
    "ebp"     = "Microsoft.PowerShell.Utility\Enable-PSBreakpoint"
    "epal"    = "Microsoft.PowerShell.Utility\Export-Alias"
    "epcsv"   = "Microsoft.PowerShell.Utility\Export-Csv"
    "epsn"    = "Microsoft.PowerShell.Utility\Export-PSSession"
    "fc"      = "Microsoft.PowerShell.Utility\Format-Custom"
    "fl"      = "Microsoft.PowerShell.Utility\Format-List"
    "ft"      = "Microsoft.PowerShell.Utility\Format-Table"
    "fw"      = "Microsoft.PowerShell.Utility\Format-Wide"
    "gal"     = "Microsoft.PowerShell.Utility\Get-Alias"
    "gm"      = "Microsoft.PowerShell.Utility\Get-Member"
    "gbp"     = "Microsoft.PowerShell.Utility\Get-PSBreakpoint"
    "gcs"     = "Microsoft.PowerShell.Utility\Get-PSCallStack"
    "gu"      = "Microsoft.PowerShell.Utility\Get-Unique"
    "gv"      = "Microsoft.PowerShell.Utility\Get-Variable"
    "group"   = "Microsoft.PowerShell.Utility\Group-Object"
    "ipal"    = "Microsoft.PowerShell.Utility\Import-Alias"
    "ipcsv"   = "Microsoft.PowerShell.Utility\Import-Csv"
    "ipsn"    = "Microsoft.PowerShell.Utility\Import-PSSession"
    "iex"     = "Microsoft.PowerShell.Utility\Invoke-Expression"
    "irm"     = "Microsoft.PowerShell.Utility\Invoke-RestMethod"
    "curl"    = "Microsoft.PowerShell.Utility\Invoke-WebRequest"
    "iwr"     = "Microsoft.PowerShell.Utility\Invoke-WebRequest"
    "wget"    = "Microsoft.PowerShell.Utility\Invoke-WebRequest"
    "measure" = "Microsoft.PowerShell.Utility\Measure-Object"
    "nal"     = "Microsoft.PowerShell.Utility\New-Alias"
    "nv"      = "Microsoft.PowerShell.Utility\New-Variable"
    "ogv"     = "Microsoft.PowerShell.Utility\Out-GridView"
    "lp"      = "Microsoft.PowerShell.Utility\Out-Printer"
    "rbp"     = "Microsoft.PowerShell.Utility\Remove-PSBreakpoint"
    "rv"      = "Microsoft.PowerShell.Utility\Remove-Variable"
    "select"  = "Microsoft.PowerShell.Utility\Select-Object"
    "sls"     = "Microsoft.PowerShell.Utility\Select-String"
    "sal"     = "Microsoft.PowerShell.Utility\Set-Alias"
    "sbp"     = "Microsoft.PowerShell.Utility\Set-PSBreakpoint"
    "set"     = "Microsoft.PowerShell.Utility\Set-Variable"
    "sv"      = "Microsoft.PowerShell.Utility\Set-Variable"
    "shcm"    = "Microsoft.PowerShell.Utility\Show-Command"
    "sort"    = "Microsoft.PowerShell.Utility\Sort-Object"
    "sleep"   = "Microsoft.PowerShell.Utility\Start-Sleep"
    "tee"     = "Microsoft.PowerShell.Utility\Tee-Object"
    "trcm"    = "Microsoft.PowerShell.Utility\Trace-Command"
    "echo"    = "Microsoft.PowerShell.Utility\Write-Output"
    "write"   = "Microsoft.PowerShell.Utility\Write-Output"
}

$op = @{ Option = "ReadOnly"; Scope = "Global"}
[double]$Total = $GlobalAliases.Count
[double]$Counter = 1.0

foreach ($alias in $GlobalAliases.Keys) {
    if ($Force -or (Get-Command "$($GlobalAliases[$alias])" -ErrorAction SilentlyContinue)) {
        if (!$Force -and ($alias -ne '?')) {
            if ($cmd = Get-Command $alias -ErrorAction SilentlyContinue -CommandType Function, Filter, Cmdlet, ExternalScript, Application, Script, Workflow, Configuration) {
                if($cmd.CommandType -eq "Application") {
                    $cmd = $cmd.Source
                }
                if (!$Quiet -and !$NoSquash) {
                    Write-Warning "Alias '$alias' obscures the native command '$cmd'"
                }
            }
        }
        if (!$Quiet) {
            Write-Progress -Activity "Resetting aliases" -Status "Aliasing $($GlobalAliases[$alias])" -CurrentOperation "Set-Alias $alias" -PercentComplete (($Counter++ / $Total) * 100.0)
        }
        if (!$NoSquash -or !$cmd) {
            Set-Alias -Option ReadOnly, AllScope -Scope Global -Name $alias -Value ($GlobalAliases[$alias]) -Force
        }
    } else {
        if (!$Quiet -and !$IgnoreMissing) {
            Write-Warning "Alias not set: '$alias' (it's command is missing: '$($GlobalAliases[$alias])')"
        }
    }
}
