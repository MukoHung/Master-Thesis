[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true, Position=0)]
  [string]$Path,
  [string]$Cache="",
  [string]$Libs="D:/Projects/Factorio",
  [switch]$Deploy,
  [switch]$NoAudio
)

function Compress-Mod () {
  Write-Verbose "Compressing mod for production-like testing"
  Write-Verbose "Target commit (HEAD):"
  & git log HEAD -1 | Write-Verbose
  $zip = Join-Path $PSScriptRoot "$modName.zip"
  & git archive HEAD --prefix=$modname/ -o $zip
  Write-Verbose "Compressed git HEAD into $zip"
  return $zip
}

# Initiate variables
$cacheDir = Join-Path $Path ".cache"
$modInfo = Get-Content -Path $Path\info.json | ConvertFrom-Json 
$modId = $modInfo.name
$modName = $modId + "_" + $modInfo.version
Write-Verbose "Cache: $cacheDir"
Write-Verbose $modInfo

# 1 - Factorio Instance
## TODO wget the zip and extract it


$factorio = Join-Path $Libs "Factorio"
Push-Location $factorio
& git checkout $($modInfo.factorio_version)
Pop-Location

$factorioInfo = Get-Content $factorio\data\base\info.json | ConvertFrom-Json 
Write-Verbose "Loaded $factorio (version $($factorioInfo.version))"

# 2 - Mod-specific Cache Folder
## Detect what .cache subfolder to use
if ($Cache -eq "") {
  $Cache = $cacheDir
} else {
  $Cache = $cacheDir + "-" + $Cache
}
Write-Verbose "Session-specific cache: $Cache"

## Ready the .cache subfolder
New-Item -Path $Cache, $Cache\config, $Cache\mods -ItemType Directory -Force | Out-Null
Get-ChildItem -Path (Join-Path $Cache\mods $modId*) | Remove-Item -Force -Recurse
Write-Verbose "Cache re-instantiated, adding mod..."

if ($Deploy) {
  Compress-Mod | Copy-Item -Destination $Cache\mods
} else {
  Write-Verbose "Creating Junction for $Path in $Cache\mods"
  $junction = Join-Path $Cache\mods $modName
  New-Item $junction -ItemType Junction -Value $Path | Out-Null
}

# 3 - Run Factorio
$config = Join-Path $Cache \config\config.ini
if(!(Test-Path $config)){
  Write-Verbose "Config not found, generating fresh one"

$configTemplate = @"
; version=2
[path]
read-data=__PATH__executable__\..\..\data
write-data=$Cache
"@
  [System.IO.File]::WriteAllLines($config, $configTemplate) # Still the UTF8 BOM issue
}

$arguments = "--mod-directory $(Join-Path $Cache "\mods")", "--config $config", "--check-unused-prototype-data"
if($Verbose){
  $arguments = $arguments += "--verbose"
}
if($NoAudio){
  $arguments = $arguments += "--disable-audio"
}

Write-Host "Starting Factorio $($factorioInfo.version) for $modId v$($modInfo.version)" -ForegroundColor Cyan
Start-Process -FilePath $factorio\bin\x64\factorio.exe -Wait -ArgumentList $arguments
Write-Verbose "Finished testing"