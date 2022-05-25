#requires -Version 5
#requires -RunAsAdministrator

<#

.SYNOPSIS
Update Windows ADK

.DESCRIPTION
Will auto update/patch the Windows 10 Version 1703 ADK if installed.

.NOTES
Copyright Keith Garner (KeithGa@DeploymentLive.com), All Rights Reserved.
Apache License 2.0

.LINK
https://blogs.technet.microsoft.com/configurationmgr/2017/04/14/known-issue-with-the-windows-adk-for-windows-10-version-1703/

.LINK
https://chocolatey.org/packages/Windows-ADK-deploy

.PARAMETER Force
Will force the installation of the Windows 10 Version 1703 ADK if not installed. 

.EXAMPLE
If you already have the Windows 10 Version 1703 ADK installed:

    .\Patch-MyADK.ps1 

.EXAMPLE
If you already have the Windows 10 Version 1703 ADK installed, 
    and would like to see what's going on behind the scenes:

    .\Patch-MyADK.ps1 -verbose

.EXAMPLE
TO install the ADK:

    Install-Package -ProviderName Chocolatey -Name Windows-ADK-deploy -Force -ForceBootstrap

#>

[cmdletbinding()]
param(
    [string] $ADKVersion = '10.0.15063.0',
    [string] $Package = 'https://download.microsoft.com/download/3/E/0/3E03B03F-B9B9-43D1-873C-5F5C63301F7F/Windows%20build%2015063%20ADK%20Driver%20Update.zip',
    [string[]] $AffectedFiles = @("WimMount.sys","WofADK.sys"),
    [switch] $Force

)

$ErrorActionPreference = 'stop'

#region Locate ADK files:

$ADKPath = Get-ItemProperty HKLM:\System\CurrentControlSet\Services\WimMount | 
    ForEach-Object { $_.ImagePath.Replace('\??\','') } | 
    Split-Path | Split-Path | Split-Path

if ( -not $ADKPath ) {
    throw "ADK not installed, download and install First."
}

#endregion

#region Version Verification

$ADKInstalledVersion = Get-ChildItem -recurse -path $ADKPath -include $AffectedFiles |
    Select-Object -First 1 |
    ForEach-Object { $_.VersionInfo.ProductVersion }
if ( $ADKInstalledVersion -ne $ADKVersion ) {
    throw "ADK Version $ADKVersion is not installed, ADK Version $ADKInstalledVersion currently installed."
}

write-verbose 'Current Signature Version (Should be "CN=Microsoft Windows")'
Get-ChildItem -recurse -path $ADKPath -include $AffectedFiles |
    get-authenticodesignature |
    ForEach-Object { $_.SignerCertificate.Subject } |
    Out-String | Write-Verbose

#endregion

#region Download ADK Fix and extract

Add-Type -AssemblyName System.Web
$LocalZip = split-path -Leaf -Path $package | ForEach-Object { join-path $env:temp ([System.Web.HttpUtility]::UrlDecode($_)) }
$ZipDir = "$env:temp\ADK $ADKVersion Cert Fix"

Invoke-WebRequest -Uri $Package -OutFile $LocalZip
Expand-Archive -Path $LocalZip -Force -DestinationPath $ZipDir
remove-item $LocalZip -ErrorAction SilentlyContinue

#endregion

#region Patch ADK files

foreach ( $arch in (Get-ChildItem $ZipDir -Directory | Get-ChildItem -Directory) ) {

    get-childitem -Recurse -path "$ADKPath\$($Arch.Name)\Dism" -include $AffectedFiles |
        Get-AuthenticodeSignature |
        Where-Object { $_.SignerCertificate.Subject -notmatch 'CN=Microsoft Windows,' } |
        foreach-object { 
            copy-item -force -path "$($Arch.FullName)\$( $_.Path | Split-Path -leaf )" -Destination $_.Path 
        }
}

#endregion

#region Cleanup...

write-verbose 'Current Signature Version (Should be "CN=Microsoft Windows")'
Get-ChildItem -recurse -path $ADKPath -include $AffectedFiles |
    get-authenticodesignature |
    ForEach-Object { $_.SignerCertificate.Subject } |
    Out-String | Write-Verbose

remove-item -Recurse -Path $ZipDir -ErrorAction SilentlyContinue

#endregion
