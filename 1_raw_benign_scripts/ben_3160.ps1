<# Dokumentation PowerShell Profile
https://docs.microsoft.com/de-de/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-5.1
#>
<# Dokumentation prompt 
https://docs.microsoft.com/de-de/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-5.1
#>
function Color-Console 
{
    $Host.ui.RawUI.BackgroundColor = "White"
    $Host.ui.RawUI.ForegroundColor = "Black"

    $hosttime = Get-Date
    $hostversion = $PSVersionTable.PSVersion.Major
    $Host.UI.RawUI.WindowTitle = "PowerShell $hostversion | ($hosttime)"

    #If Windows 10 806 or lower or Windows Server 2016 or lower
    if((Get-Command -Name Set-PSReadlineOption).Version.Major -lt 2)
    {
        Set-PSReadlineOption -TokenKind Command -ForegroundColor DarkBlue
        Set-PSReadlineOption -TokenKind Parameter -ForegroundColor Blue
        Set-PSReadlineOption -TokenKind Number -ForegroundColor DarkRed
        Set-PSReadlineOption -TokenKind String -ForegroundColor DarkGreen
        Set-PSReadlineOption -TokenKind Comment -ForegroundColor Green
        Set-PSReadlineOption -TokenKind Variable -ForegroundColor DarkCyan
        Set-PSReadlineOption -TokenKind Keyword -ForegroundColor Magenta
        Set-PSReadlineOption -TokenKind Member -ForegroundColor Cyan
    }
    else
    {
        Set-PSReadlineOption -Colors @{
                                       "Parameter" = [ConsoleColor]::Blue
                                       "Command" = [ConsoleColor]::DarkBlue
                                       "Number"  = [ConsoleColor]::DarkRed
                                       "String" = [ConsoleColor]::DarkGreen
                                       "Comment" = [ConsoleColor]::Green
                                       "Variable" = [ConsoleColor]::DarkCyan
                                      }
    }

    Clear-Host
}

Color-Console

function prompt
{
    $prompttext
    $UserStatus = Get-ElevatedStatus
    if($UserStatus)
    {
       $prompttext = "[A]"
    }
    else
    {
        $prompttext ="[U]"
    }
    
    $splitpath = (Get-Location).Path.Split("\")
    $prompttext += "DIR: $($splitpath[$splitpath.Count -1])|"

    Write-Host -Object $prompttext -NoNewline
}

function Get-ElevatedStatus
{
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

    $principal.IsInRole($adminRole)
}