# "       __|__"
# "--------(_)--------"
# "  O  O       O  O"

# See $PROFILE file
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7

set HOME="$HOMEDRIVE$HOMEPATH"
Set-Location $HOME

# Shortcuts
$dotfiles = "$HOMEDRIVE/myconf/dotfiles"
$desktop = "$HOME/Desktop"
$dev = "$HOME/Desktop/git_tracking"

$file_terminal_settings = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json"

# ========== Aliases ==========
Set-Alias -Name g -Value git
Set-Alias -Name ll -Value ls
Set-Alias -Name l -Value ls

Function OpenFileBrowserHere {explorer .}
Set-Alias -Name t -Value OpenFileBrowserHere

# ----- Source the settings file -----
Function SourceSettings {. $PROFILE}
Set-Alias -Name source -Value SourceSettings

# ----- Git -----
Function GitAddAndUpdate {git add -u .; git commit -m "Update"}
Set-Alias -Name gup -Value GitAddAndUpdate

# ----- Vim -----
Set-Alias -Name vim -Value nvim

# ----- Python -----
Set-Alias -Name p -Value python3
Set-Alias -Name py -Value python3
Set-Alias -Name pip -Value pip3

# ----- cd -----
Function ChangeDirDevelopment {cd $dev}
Set-Alias -Name dev -Value ChangeDirDevelopment

Function ChangeDirDotfiles {cd $dotfiles}
Set-Alias -Name dotfiles -Value ChangeDirDotfiles

# ----- choco/system update -----
Function ChocoUpgradeAll {choco upgrade all -y}
Set-Alias -Name sysupd -Value ChocoUpgradeAll

# ----- PowerShell -----
Function UpdatePowerShellSettings {
    vim $dotfiles/_windows/powershell_settings.ps1
    Write-Host "Updating powershell settings..."
    cp $dotfiles/_windows/powershell_settings.ps1 $PROFILE
}
Set-Alias -Name psedit -Value UpdatePowerShellSettings

# ----- Windows Terminal -----
Function UpdateWindowsTerminalSettings {
    vim $dotfiles/_windows/windows_terminal_settings.json
    Write-Host "Updating windows terminal settings..."
    cp $dotfiles/_windows/windows_terminal_settings.json $file_terminal_settings
}
Set-Alias -Name termedit -Value UpdateWindowsTerminalSettings

# ===== Prompt =====
function prompt {
        $lastResult = Invoke-Expression '$?'
        if (!$lastResult) {
                Write-Host "Last command exited with error status." -ForegroundColor Red
        }
        Write-Output "${msg}$(
                # Show time as 12:05PM
                Get-Date -UFormat "%I:%M%p"
                # Show current directory
        ) $(Get-Location)> "
}

# ===== Run during init =====
cd $HOME
clear
