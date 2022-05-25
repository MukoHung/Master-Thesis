function Start-Demo {
    [CmdletBinding()]
    param(
        # A history file with a command on each line (or using ` as a line-continuation character)
        [Parameter(Mandatory)]
        [Alias("PSPath")]
        [string]$Path
    )
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()

    foreach($command in (Get-Content $Path -Raw) -split '(?<!`)\r\n' -replace '`\r\n',"`r`n") {
        [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($command)
    }

    Write-Host "Press Ctrl+Home to go to the start of the demo, and Ctrl+Enter to run each line" -Foreground Yellow

    Set-PSReadLineKeyHandler Ctrl+Home BeginningOfHistory
    Set-PSReadLineKeyHandler Ctrl+Enter AcceptAndGetNext
}