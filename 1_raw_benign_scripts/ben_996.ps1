Split-Path $MyInvocation.MyCommand.Path

Within a function

Split-Path $Script:MyInvocation.MyCommand.Path

$PSScriptRoot

if (!$PSScriptRoot) {$PSScriptRoot = Split-Path $Script:MyInvocation.MyCommand.Path}
