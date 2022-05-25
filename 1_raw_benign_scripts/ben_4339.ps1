param([string]$Env="NA")

function Load-NewAcounts($prodCS)
{
	Write-Host "NewAcounts updated"
}

$ErrorActionPreference="stop"

# Where am I?
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent

$Config = & $PSScriptRoot\Get-Config.ps1 -Env $Env

Load-NewAcounts $Config.ProductEFConnectionString
