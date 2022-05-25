<#
This license governs use of the accompanying software. If you use the software, you
 accept this license. If you do not accept the license, do not use the software.

1. Definitions
 The terms "reproduce," "reproduction," "derivative works," and "distribution" have the
 same meaning here as under U.S. copyright law.
 A "contribution" is the original software, or any additions or changes to the software.
 A "contributor" is any person that distributes its contribution under this license.
 "Licensed patents" are a contributor's patent claims that read directly on its contribution.

2. Grant of Rights
 (A) Copyright Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free copyright license to reproduce its contribution, prepare derivative works of its contribution, and distribute its contribution or any derivative works that you create.
 (B) Patent Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free license under its licensed patents to make, have made, use, sell, offer for sale, import, and/or otherwise dispose of its contribution in the software or derivative works of the contribution in the software.

3. Conditions and Limitations
 (A) No Trademark License- This license does not grant you rights to use any contributors' name, logo, or trademarks.
 (B) If you bring a patent claim against any contributor over patents that you claim are infringed by the software, your patent license from such contributor to the software ends automatically.
 (C) If you distribute any portion of the software, you must retain all copyright, patent, trademark, and attribution notices that are present in the software.
 (D) If you distribute any portion of the software in source code form, you may do so only under this license by including a complete copy of this license with your distribution. If you distribute any portion of the software in compiled or object code form, you may only do so under a license that complies with this license.
 (E) The software is licensed "as-is." You bear the risk of using it. The contributors give no express warranties, guarantees or conditions. You may have additional consumer rights under your local laws which this license cannot change. To the extent permitted under your local laws, the contributors exclude the implied warranties of merchantability, fitness for a particular purpose and non-infringement.
#>

#Requires -Version 3.0

[CmdletBinding()]
param
(
    [Parameter(Position=0, Mandatory=$true)]
    [string] $Path,

    [Parameter()]
    [ValidateRange(0, 2TB)]
    [long] $Size = 1TB
)

# Require elevated privileges (Tip: PSv4 supports '#Requires -RunAsAdministrator').
$Principal = New-Object System.Security.Principal.WindowsPrincipal ([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Error 'Elevated privileges are required to move the package cache.' -Category PermissionDenied
    return
}

# Make sure modules are loaded (Tip: PSv3 supports '#Requires -Modules <String[]>').
Import-Module 'Dism', 'Storage', 'ScheduledTasks'

$VhdPath = Join-Path $Path 'Cache.vhd'
$CachePath = Join-Path $env:ProgramData 'Package Cache'

# Make sure the necessary Windows features are enabled.
$Features = 'Microsoft-Hyper-V-All', 'Microsoft-Hyper-V-Tools-All', 'Microsoft-Hyper-V-Management-PowerShell' | ForEach-Object {
    Get-WindowsOptionalFeature -Online -FeatureName $_ -Verbose:$false
} | Where-Object { $_.State -ne 'Enabled' } | Select-Object -expand FeatureName
if ($Features)
{
    Write-Verbose "Installing required Windows feature(s): $($Features -split ', ')"
    Enable-WindowsOptionalFeature -Online -FeatureName $Features -NoRestart -Verbose:$false
    if (-not $?)
    {
        return
    }
}

# Create, partition, and format the cache VHD.
if (-not (Test-Path $Path -PathType Container))
{
    Write-Verbose "Creating directory for virtual disk: $Path"
    $null = New-Item $Path -Type 'Directory'
}
elseif (Test-Path "$VhdPath" -PathType Leaf)
{
    Write-Error "A virtual disk already exists at `"$VhdPath`"." -Category ResourceExists
    return
}

Write-Verbose "Creating virtual disk: $VhdPath"
$Disk = New-VHD "$VhdPath" -SizeBytes $Size -Dynamic | Mount-VHD -NoDriveLetter -Passthru
if (-not $?)
{
    return
}

$Acl = New-Object System.Security.AccessControl.FileSecurity
$Acl.SetSecurityDescriptorSddlForm('O:BAG:DUD:P(A;;FA;;;BA)(A;;FA;;;SY)(A;;FRFX;;;BU)(A;;FRFX;;;WD)', 'All')
$Acl | Set-Acl $Disk.Path

$Partition = Initialize-Disk $Disk.Number -PassThru | New-Partition -UseMaximumSize
$null = $Partition | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Package Cache' -Confirm:$false
$Volume = $Partition | Add-PartitionAccessPath -AssignDriveLetter -PassThru | Get-Volume

$Drive = "$($Volume.DriveLetter):"
$Acl = New-Object System.Security.AccessControl.DirectorySecurity
$Acl.SetSecurityDescriptorSddlForm('O:BAG:DUD:PAI(A;OICIID;FA;;;BA)(A;OICIID;FA;;;SY)(A;OICIID;FRFX;;;BU)(A;OICIID;FRFX;;;WD)', 'All')
Set-Acl "$Drive\" -AclObject $Acl
Write-Verbose "Created and formatted drive: $Drive, label: Package Cache"

# Copy the existing package cache (if any).
if (Test-Path "$CachePath" -PathType Container)
{
    Write-Verbose "Copying contents from: $CachePath; to: $Drive"
    Copy-Item "$CachePath\*" "$Drive\" -Recurse
    if (-not $?)
    {
        return
    }

    Write-Verbose "Deleting directory: $CachePath"
    Remove-Item "$CachePath" -Force -Recurse
    if (-not $?)
    {
        return
    }
}

# Create the empty directory and mount the VHD into it.
Write-Verbose "Creating empty directory: $CachePath"
New-Item "$CachePath" -Type 'Directory' -Force | Set-Acl -AclObject $Acl
if (-not $?)
{
    return
}

Write-Verbose "Mounting virtual disk into directory: $CachePath"
$Partition | Add-PartitionAccessPath -AccessPath "$CachePath" -PassThru | Remove-PartitionAccessPath -AccessPath "$Drive"
Write-Verbose "Removed drive letter: $Drive"

# Schedule a task to make sure the VHD is always mounted on boot.
Write-Verbose "Creating script to mount VHD: $VhdPath, path: $ScriptPath"
$ScriptPath = [System.IO.Path]::ChangeExtension($VhdPath, '.txt')
@"
select vdisk file=$VhdPath
attach vdisk
"@ | Set-Content $ScriptPath -Force
Get-Acl $VhdPath | Set-Acl $ScriptPath

Write-Verbose "Scheduling task to mount VHD: $VhdPath"
$trigger = New-ScheduledTaskTrigger -AtStartup
$action = New-ScheduledTaskAction -Execute (get-command diskpart.exe).Path -Argument "/s `"$ScriptPath`""
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$user = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest -LogonType ServiceAccount
$null = Register-ScheduledTask -TaskName 'Attach Package Cache' -Trigger $trigger -Action $action -Settings $settings -Principal $user -Force

<#
.Synopsis
Move the Burn package cache to another drive or directory.

.Description
Actually moving the Burn package cache to another drive or directory is currently not supported.
Instead this script creates a expandable virtual disk (VHD) in whatever directory you want - even on another drive.
Any existing payload is copied and the expandable virtual disk is mounted into the now empty package cache.

.Parameter Path
The directory in which the package cache is moved.

.Parameter Size
The maximum size of the expandable virtual disk to create. The default is 1TB.

.Notes
You need administrator privileges to run this script.

.Link
http://aka.ms/mvcache
#>
