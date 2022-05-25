Set-ExecutionPolicy Unrestricted;
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression;
choco install vim
choco update vim

$command = (Get-itemProperty -LiteralPath "HKLM:\SOFTWARE\Classes\`*\shell\Vim\Command").'(default)';

if ($command -match "`"([^`"]+)`".*") {
    $expression = "Set-Alias -Name 'vim' -Value '$($Matches[1])';"

    if (-Not (Test-Path "$PROFILE")) {
        "$expression`r`n" | Out-File -FilePath "$PROFILE" -Encoding UTF8;
    } elseif (Get-Content "$PROFILE" | Where-Object { $_ -eq "$expression" } ) { 
        Add-Content '$PROFILE' "`r`n$expression`r`n";
    }
}
