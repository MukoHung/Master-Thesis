<#
  .SYNOPSIS
    A simple example of Write-Host
#>

# Displays the message
Write-Host -Object 'Hello'

# Try to silence directly
Write-Host "Still shown :-(" -InformationAction SilentlyContinue

# Try to silence with global variable
$global:InformationPreference = 'SilentlyContinue'
Write-Host "Ignores global :-(" -InformationAction SilentlyContinue

