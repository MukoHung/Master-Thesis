# -*-mode:powershell-*- vim:ft=powershell

# ~/.config/powershell/aliases.ps1
# =============================================================================
# PowerShell aliases sourced by `./profile.ps1`.
#
# On Windows, this file will be copied over to these locations after
# running `chezmoi apply` by the script `../../run_powershell.bat.tmpl`:
#     - %USERPROFILE%\Documents\PowerShell
#     - %USERPROFILE%\Documents\WindowsPowerShell
#
# Since PowerShell does not allow aliases to contain parameters, most of the
# logic is wrapped in `./functions.ps1`.

# Create missing $IsWindows if running Powershell 5 or below.
if (!(Test-Path variable:global:IsWindows)) {
    Set-Variable "IsWindows" -Scope "Global" -Value ([System.Environment]::OSVersion.Platform -eq "Win32NT")
}


# Easier navigation
# -----------------------------------------------------------------------------

Set-Alias -Name "~" -Value Set-LocationHome -Description "Goes to user home directory."

Set-Alias -Name "cd-" -Value Set-LocationLast -Description "Goes to last used directory."

Set-Alias -Name ".." -Value Set-LocationUp -Description "Goes up a directory."

Set-Alias -Name "..." -Value Set-LocationUp2 -Description "Goes up two directories."

Set-Alias -Name "...." -Value Set-LocationUp3 -Description "Goes up three directories."

Set-Alias -Name "....." -Value Set-LocationUp4 -Description "Goes up four directories."

Set-Alias -Name "......" -Value Set-LocationUp5 -Description "Goes up five directories."


# Directory browsing
# -----------------------------------------------------------------------------

if (!(Get-Command "ls" -ErrorAction "Ignore")) {
    Set-Alias -Name "ls" -Value Get-ChildItemSimple -Description "Lists visible files in wide format."
}

Set-Alias -Name "l" -Value Get-ChildItemVisible -Description "Lists visible files in long format."

Set-Alias -Name "ll" -Value Get-ChildItemAll -Description "Lists all files in long format."

Set-Alias -Name "lsd" -Value Get-ChildItemDirectory -Description "Lists only directories in long format."

Set-Alias -Name "lsh" -Value Get-ChildItemHidden -Description "Lists only hidden files in long format."

