Param (
  [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
  [ValidateSet('Backup', 'Restore')]
  [string]
  $Action
)


$ScriptFilePath = $PSScriptRoot


if ($Action -eq 'Backup') {
  Copy-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk" -Destination "$ScriptFilePath\"
} elseif ($Action -eq 'Restore') {
  Copy-Item -Path "$ScriptFilePath\Windows PowerShell.lnk" -Destination "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\"
}
