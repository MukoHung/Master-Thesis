$scriptDirectory = (Split-Path -parent $MyInvocation.MyCommand.Definition)

# TODO: Execute all `*.ps1` scripts in $scriptDirectory\functions
. $scriptDirectory\functions\Show-Colors.ps1
. $scriptDirectory\functions\Export-Variable.ps1
. $scriptDirectory\functions\Make-Link.ps1
. $scriptDirectory\functions\New-Link.ps1
. $scriptDirectory\functions\Invoke-XLaunch.ps1
. $scriptDirectory\functions\Add-Path.ps1
. $scriptDirectory\functions\Remove-Path.ps1
. $scriptDirectory\functions\Delete-Item.ps1
. $scriptDirectory\functions\Where-Item.ps1
. $scriptDirectory\functions\Touch-File.ps1
. $scriptDirectory\functions\Remove-Directory.ps1
. $scriptDirectory\functions\Kill-Process.ps1
