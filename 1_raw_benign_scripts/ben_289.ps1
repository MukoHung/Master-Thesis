<#
.NOTES
    AUTHOR:	David Segura
#>
Start-Transcript
#======================================================================================
#   Start Script
#======================================================================================
Write-Host "$PSCommandPath" -ForegroundColor Green
Write-Host ""
#======================================================================================
#   Get OSDUpdate
#======================================================================================
$OSDUpdatePath = (get-item $PSScriptRoot ).FullName
Write-Host "OSDUpdate Path: $OSDUpdatePath" -ForegroundColor Cyan
#======================================================================================
#   Get OS Information
#======================================================================================
$OSCaption = $((Get-WmiObject -Class Win32_OperatingSystem).Caption).Trim()
$OSArchitecture = $((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture).Trim()
$OSVersion = $((Get-WmiObject -Class Win32_OperatingSystem).Version).Trim()
$OSBuildNumber = $((Get-WmiObject -Class Win32_OperatingSystem).BuildNumber).Trim()
Write-Host "Operating System: $OSCaption" -ForegroundColor Cyan
Write-Host "OS Architecture: $OSArchitecture" -ForegroundColor Cyan
Write-Host "OS Version: $OSVersion" -ForegroundColor Cyan
Write-Host "OS Build Number: $OSBuildNumber" -ForegroundColor Cyan
if ($OSCaption -Like "*Windows 10*") {
    $OSReleaseID = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId).ReleaseId
    Write-Host "OS Release ID: $OSReleaseID" -ForegroundColor Cyan
}
#======================================================================================
#   Validate Admin Rights
#======================================================================================
Write-Host ""
# Verify Running as Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If (!( $isAdmin )) {
    Write-Host "Checking User Account Control settings ..." -ForegroundColor Green
    if ((Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System).EnableLUA -eq 0) {
        #UAC Disabled
        Write-Host "User Account Control is Disabled ... " -ForegroundColor Green
        Write-Host "You will need to correct your UAC Settings ..." -ForegroundColor Green
        Write-Host "Try running this script in an Elevated PowerShell session ... Exiting" -ForegroundColor Green
        Start-Sleep -s 10
        Exit 0
    } else {
        #UAC Enabled
        Write-Host "UAC is Enabled" -ForegroundColor Green
        Start-Sleep -s 3
        if ($Silent) {
            Write-Host "-- Restarting as Administrator (Silent)" -ForegroundColor Cyan ; Start-Sleep -Seconds 1
            Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Silent" -Verb RunAs -Wait
        } elseif($Restart) {
            Write-Host "-- Restarting as Administrator (Restart)" -ForegroundColor Cyan ; Start-Sleep -Seconds 1
            Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Restart" -Verb RunAs -Wait
        } else {
            Write-Host "-- Restarting as Administrator" -ForegroundColor Cyan ; Start-Sleep -Seconds 1
            Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
        }
        Exit 0
    }
} else {
    Write-Host "-- Running with Elevated Permissions ..." -ForegroundColor Cyan ; Start-Sleep -Seconds 1
    Write-Host ""
}
#======================================================================================
#   Updates
#======================================================================================
$Updates = @()
$UpdateCatalogs = Get-ChildItem $PSScriptRoot "Windows*.xml" -Recurse
Try {
    foreach ($Catalog in $UpdateCatalogs) {
        $Updates += Import-Clixml -Path $Catalog.FullName
    }
}
Catch {}
#======================================================================================
#   Sessions
#======================================================================================
[xml]$SessionsXML = Get-Content -Path "$env:WinDir\Servicing\Sessions\Sessions.xml"

$Sessions = $SessionsXML.SelectNodes('Sessions/Session') | ForEach-Object {
    New-Object -Type PSObject -Property @{
        Id = $_.Tasks.Phase.package.id
        KBNumber = $_.Tasks.Phase.package.name
        TargetState = $_.Tasks.Phase.package.targetState
        Client = $_.Client
        Complete = $_.Complete
        Status = $_.Status
    }
}
$Sessions = $Sessions | Where-Object {$_.Id -like "Package*"}
$Sessions = $Sessions | Select-Object -Property Id, KBNumber, TargetState, Client, Status, Complete | Sort-Object Complete -Descending
#======================================================================================
#   Architecture
#======================================================================================
if ($OSArchitecture -like "*64*") {$Updates = $Updates | Where-Object {$_.UpdateArch -eq 'x64'}}
else {$Updates = $Updates | Where-Object {$_.UpdateArch -eq 'x86'}}
#======================================================================================
#   Operating System
#======================================================================================
if ($OSCaption -like "*Windows 7*") {$Updates = $Updates | Where-Object {$_.UpdateOS -eq 'Windows 7'}}
if ($OSCaption -like "*Windows 10*") {
    $Updates = $Updates | Where-Object {$_.UpdateOS -eq 'Windows 10'}
    $Updates = $Updates | Where-Object {$_.UpdateBuild -eq $OSReleaseID}
}
#======================================================================================
#   Get-Hotfix
#======================================================================================
$InstalledUpdates = Get-HotFix
#======================================================================================
#   Windows Updates
#======================================================================================
Write-Host '========================================================================================' -ForegroundColor DarkGray
Write-Host "Updating Windows" -ForegroundColor Green
foreach ($Update in $Updates) {
    $UpdatePath = "$PSScriptRoot\$($Update.UpdateOS)\$($Update.Title)\$($Update.FileName)"

    if (Test-Path "$UpdatePath") {
        Write-Host "$UpdatePath" -ForegroundColor DarkGray
        if ($InstalledUpdates | Where-Object HotFixID -like "*$($Update.KBNumber)") {
            Write-Host "KB$($Update.KBNumber) is already installed" -ForegroundColor Cyan
        } else {
            Write-Host "Installing $($Update.Title) ..." -ForegroundColor Cyan
            Try {Add-WindowsPackage -Online -PackagePath "$UpdatePath" -NoRestart | Out-Null}
            Catch {Dism /Online /Add-Package /PackagePath:"$UpdatePath" /NoRestart}
        }
    } else {
        Write-Warning "Not Found: $UpdatePath"
    }
}
#======================================================================================
#   Update Office 2010
#======================================================================================
Write-Host '========================================================================================' -ForegroundColor DarkGray
Write-Host "Updating Office 2010" -ForegroundColor Green

$Script = "$OSDUpdatePath\Office 2010 32-Bit\Install-OSDUpdateOffice.ps1"
if (Test-Path $Script) {& "$Script"}

$Script = "$OSDUpdatePath\Office 2010 64-Bit\Install-OSDUpdateOffice.ps1"
if (Test-Path $Script) {& "$Script"}
#======================================================================================
#   Update Office 2013
#======================================================================================
Write-Host '========================================================================================' -ForegroundColor DarkGray
Write-Host "Updating Office 2013" -ForegroundColor Green

$Script = "$OSDUpdatePath\Office 2013 32-Bit\Install-OSDUpdateOffice.ps1"
if (Test-Path $Script) {& "$Script"}

$Script = "$OSDUpdatePath\Office 2013 64-Bit\Install-OSDUpdateOffice.ps1"
if (Test-Path $Script) {& "$Script"}
#======================================================================================
#   Update Office 2016
#======================================================================================
Write-Host '========================================================================================' -ForegroundColor DarkGray
Write-Host "Updating Office 2016" -ForegroundColor Green

$Script = "$OSDUpdatePath\Office 2016 32-Bit\Install-OSDUpdateOffice.ps1"
if (Test-Path $Script) {& "$Script"}

$Script = "$OSDUpdatePath\Office 2016 64-Bit\Install-OSDUpdateOffice.ps1"
if (Test-Path $Script) {& "$Script"}
#======================================================================================
#   Complete
#======================================================================================
Write-Host ""
Write-Host (Join-Path $PSScriptRoot $MyInvocation.MyCommand.Name) " Complete" -ForegroundColor Green
Stop-Transcript
Start-Sleep 5
#[void](Read-Host 'Press Enter to Continue')