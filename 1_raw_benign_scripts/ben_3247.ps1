# Put this code in your PowerShell profile script
# This requires the MSTerminalSettings module which you can download with:
# Install-Module MSTerminalSettings -Scope CurrentUser -Repository PSGallery

Import-Module MSTerminalSettings
$msTermProfileName = 'pwsh' # Replace with whatever Terminal profile name you're using
$msTermProfile     = Get-MSTerminalProfile -Name $msTermProfileName
$script:bombThrown = $false
function prompt {
    if ($? -eq $false) {
        # RED ALERT!!!
        # Only do this if we're using Microsoft Terminal
        if ((Get-Process -Id $PID).Parent.Parent.ProcessName -eq 'WindowsTerminal') {
            Set-MSTerminalProfile -Name $msTermProfile.name -BackgroundImage 'https://media.giphy.com/media/HhTXt43pk1I1W/giphy.gif' -UseAcrylic:$false
            $script:bombThrown = $true
        }
    } else {
        # Reset to previous settings
        if ($script:bombThrown) {
            Set-MSTerminalProfile -Name $msTermProfile.name -BackgroundImage $msTermProfile.backgroundImage -UseAcrylic:$msTermProfile.useAcrylic
            $script:bombThrown = $false
        }
    }
}