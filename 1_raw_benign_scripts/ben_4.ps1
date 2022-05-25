# Powershell

# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Autocompleteion for Arrow keys
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -PredictionSource History

# Set the color for Prediction (auto-suggestion)
Set-PSReadLineOption -Colors @{ InlinePrediction = '#6b7a9b'}

# modules
Import-Module z


# starship
Invoke-Expression (&starship init powershell)


# keybindings and aliases
Set-PSReadlineKeyHandler -Key "ctrl+a" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::BeginningOfLine() }
Set-PSReadlineKeyHandler -Key "ctrl+e" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine() }
Set-PSReadlineKeyHandler -Key "ctrl+b" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::BackwardChar() }
Set-PSReadlineKeyHandler -Key "alt+b" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::BackwardWord() }
Set-PSReadlineKeyHandler -Key "ctrl+f" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar() }
Set-PSReadlineKeyHandler -Key "alt+f" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::ForwardWord() }
Set-PSReadlineKeyHandler -Key "ctrl+d" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::DeleteChar() }
Set-PSReadlineKeyHandler -Key "ctrl+w" -ScriptBlock {
	[Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
	[Microsoft.PowerShell.PSConsoleReadLine]::BackwardKillWord()
}
Set-PSReadlineKeyHandler -Key "ctrl+k" -ScriptBlock {
	[Microsoft.PowerShell.PSConsoleReadLine]::ForwardDeleteLine()
	[Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
}
Set-PSReadlineKeyHandler -Key "alt+d" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::KillWord() }
Set-PSReadlineKeyHandler -Key "alt+w" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::BackwardKillWord() }
Set-PSReadlineKeyHandler -Key "ctrl+y" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::Yank() }
Set-PSReadlineKeyHandler -Key "ctrl+_" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::Undo() }
Set-PSReadlineKeyHandler -Key "ctrl+u" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::BackwardKillLine() }
Set-PSReadlineKeyHandler -Key "ctrl+n" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchForward() }
Set-PSReadlineKeyHandler -Key "ctrl+p" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchBackward() }
Set-PSReadlineKeyHandler -Key "alt+backspace" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::BackwardKillWord() }

Set-Alias lvim "C:\Users\adrian\.local\bin\lvim.ps1"
Set-Alias vim "C:\Users\adrian\.local\bin\lvim.ps1"

# remvoe rm alias
Remove-Alias -Name rm

# rm -rf -> rm -r -f 
Function rm {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$false, Position=0, ValueFromRemainingArguments=$true,
                HelpMessage="Specifies a path of the items being removed. Wildcard characters are permitted.")] 
    [string[]]$paths,
    [Alias("f")]
    [Parameter(Mandatory=$false,
                HelpMessage="ignore nonexistent files and arguments, never prompt")] 
    [switch]$force,
    [Alias("r")]
    [Parameter(Mandatory=$false,
                HelpMessage="remove directories and their contents recursively")]
    [switch]$recursive,
    [Alias("fr")]
    [Parameter(Mandatory=$false,
                HelpMessage="combines r and f")]
    [switch]$rf
  )

  # if user does not specify path print error msg.
  # not interested in mandatory
  If ($paths -eq $null){
    Write-Host "rm: missing operand (path)"
    return
  }

  $cmdPrev = "Remove-Item -Force"

  $f_args = "-ErrorAction SilentlyContinue"
  $r_args = "-Recurse"

  If ($rf){
    $force = $true
    $recursive = $true
  }

  If ($force){
    $cmdPrev = "$cmdPrev $f_args"
  }
  If ($recursive){
    $cmdPrev = "$cmdPrev $r_args"
  }

  foreach ($p in $paths) {
    $commandExec = "$cmdPrev -Path $p" 
    Invoke-Expression "$commandExec"
  }
}


# custom functions

function dotfiles { git --git-dir="$HOME\.dotfiles" --work-tree="$HOME" @Args }
