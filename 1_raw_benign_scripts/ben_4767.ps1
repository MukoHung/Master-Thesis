# PowerShell scripts that provide a number of tools to make your Active Directory life easier.
# Date 14/11/2020
# Author : Remco van der Meer

# Clear screen
cls

# Menu
Write-Host "`nActive Directory tools | Version : 1.0 | By Remco van der Meer" -ForegroundColor DarkYellow
Write-Host "
  ____  ___        ______   ___    ___   _     _____
 /    ||   \      |      | /   \  /   \ | |   / ___/
|  o  ||    \     |      ||     ||     || |  (   \_ 
|     ||  D  |    |_|  |_||  O  ||  O  || |___\__  |
|  _  ||     |      |  |  |     ||     ||     /  \ |
|  |  ||     |      |  |  |     ||     ||     \    |
|__|__||_____|      |__|   \___/  \___/ |_____|\___|
                                                    

=================== Bulk tools =====================

    1. Bulk users
    2. Bulk groups
    3. Bulk computers

==================== List Tools ====================

    4. List AD users, groups or computers
    5. List Domain Controllers

==================== Help Menu =====================

    Type 'help' to open the help menu

==============================================
"

function SelectTool() {
    # Promt user for Tool to use
    $tool = Read-Host -Prompt "Select tool"

    if ($tool -eq 1) {
        ."$PSScriptRoot\Tools\Bulk_users.ps1"
    } elseif ($tool -eq 2) {
        ."$PSScriptRoot\Tools\Bulk_groups.ps1"
    } elseif ($tool -eq 3) {
        ."$PSScriptRoot\Tools\Bulk_computers.ps1"
    } elseif ($tool -eq 4) {
        ."$PSScriptRoot\Tools\ListAD.ps1"
    } elseif ($tool -eq 5) {
        ."$PSScriptRoot\Tools\ForestTools.ps1"
    } elseif ($tool -eq "help") {
        ."$PSScriptRoot\Help_menu\HelpMenu.ps1"
    } else {
        Write-Host "`nThat is not a valid option.."
        SelectTool
    }
}

# Call SelectTool function
SelectTool

# Ask user if they want to continue or quit
$Return = Read-Host -Prompt "Do you want to start another tool? Y / N"

if ($Return -eq "Y") {
    ."$PSScriptRoot\AD_tools.ps1"
} else {
  exit 
 }