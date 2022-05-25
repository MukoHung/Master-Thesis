# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
# PowerShell parameter completion shim for the dotnet CLI 
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
     param($commandName, $wordToComplete, $cursorPosition)
         dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
         }
}

# Posh git
Import-Module posh-git
$GitPromptSettings.WorkingColor.ForegroundColor             = 0xFFA500
$GitPromptSettings.LocalWorkingStatusSymbol.ForegroundColor = 0xFFA500

# functions to switch layout
function layout-window($suffix, $prompt)
{
    if ($prompt -eq $null)
    {
        $prompt = '$(Get-PromptPath)'
    }
    $GitPromptSettings.DefaultPromptBeforeSuffix.Text = $suffix
    $GitPromptSettings.DefaultPromptPath              = $prompt
}
function layout-default   { layout-window '' }
function layout-multiline { layout-window '`n' }
function layout-clean     { layout-window '' '' }

# functions for fast switching
function goto-projects { cd c:/data/projects }
function goto-main     { cd c:/data/projects/main }