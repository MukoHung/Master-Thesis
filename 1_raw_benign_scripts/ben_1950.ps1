#requires -version 2
<#
.SYNOPSIS
Installs latest rclone
.INPUTS
-Location to install.
-exeonly If you only want to deal with the exe.
-Temp Location to use for temp.
-beta To download the latest beta
.OUTPUTS
Outputs rclone version for verification
.NOTES
Author:JustusIV
.EXAMPLE
install-rclone -location "$env:USERPROFILE\Desktop"
install-rclone -location "c:\rclone" -execonly $true -temp "c:\mytemp" -beta $true
#>

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Unzip{
param([string]$zipfile, [string]$outpath)
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Function Test-write{
param (
[Parameter(Mandatory=$True,Position=1)]
[string]$path)
$random = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 25 | % {[char]$_})
try{"TESTWRITE" | Out-File -FilePath $path\$random -ErrorAction SilentlyContinue}catch{}
$wrote = (Test-Path $path\$random -ErrorAction SilentlyContinue)
if ($wrote){Remove-Item $path\$random -ErrorAction SilentlyContinue;return $true}else{return $false}
}

Function install-rclone{
param ([Parameter(Position=1)]
[string]$location="c:\windows\system32",
[Parameter(Mandatory=$false)]
[boolean]$exeonly=$true,
[string]$temp=$env:TEMP,
[boolean]$beta=$true)

if (!(Test-write $location)){write-warning "Unable to write to location.";return}
if (!(Test-write $temp)){write-warning "Unable to write to temp location.";return}
if ([IntPtr]::Size -eq 8){$64 = $true}

if(($64) -and ($beta)){$url = "https://beta.rclone.org/rclone-beta-latest-windows-amd64.zip"}
elseif (($64) -and (!($beta))){$url = "https://downloads.rclone.org/rclone-current-windows-amd64.zip"}
elseif ((!($64)) -and (($beta))){$url = "https://beta.rclone.org/rclone-beta-latest-windows-386.zip"}
elseif ((!($64)) -and (!($beta))){$url = "https://downloads.rclone.org/rclone-current-windows-386.zip"}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile "$temp\rclone-windows.zip"

Unzip "$temp\rclone-windows.zip" "$temp\rclone-windows"

$items = (Get-ChildItem (Get-ChildItem "$temp\rclone-windows").FullName)

if ($exeonly){foreach ($item in $items | Where-Object {($_.name -eq "rclone.exe") -or ($_.name -eq "rclone")}){Move-Item $item.FullName -Destination $location -Force}}else{
foreach ($item in $items){Move-Item $item.FullName -Destination $location -Force}}

Remove-Item $temp\rclone-windows -Recurse
Remove-Item $temp\rclone-windows.zip

Move-Item $location\rclone $location\rclone.exe -Force -ErrorAction SilentlyContinue

& $location\rclone.exe --version -q
}