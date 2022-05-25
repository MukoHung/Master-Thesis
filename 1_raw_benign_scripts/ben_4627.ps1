
<#
.SYNOPSIS

Install Windows from a passed ISO.
.DESCRIPTION

This command takes a path to a .iso file, mounts it, and starts setup.exe to begin windows installation.
This should only be run on Windows PE instances.
.PARAMETER ISOPath

This is the path to the .iso file that will be mounted, and used for the installation media.
.EXAMPLE

InstallWindows -ISOPath "Z:\Windows\en_windows_10_enterprise_version_1607_updated_jul_2016_x64_dvd_9054264.iso"
#>
function InstallWindows
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$ISOPath
    )

    $img = Mount-DiskImage -imagepath $ISOPath -PassThru
    Start-Process -FilePath "$(($img | Get-Volume).DriveLetter):\Setup.exe"
}

<#
.SYNOPSIS

Get information about versions of windows that are supported on an ISO.
.DESCRIPTION

This command mounts a passed .iso file, and returns the output from the Get-WindowsImage function for \Sources\install.wim on said image.
.PARAMETER ISOPath

This is the path to the .iso file that information will be retrieved from. Please ensure it is valid Windows installation media.
.EXAMPLE

GetWindowsISOInfo -ISOPath "Z:\Windows\en_windows_10_enterprise_version_1607_updated_jul_2016_x64_dvd_9054264.iso" | Format-Table -Property ImageName, ImageSize
#>
function GetWindowsISOInfo
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$ISOPath
    )

    $img = Mount-DiskImage -imagepath $ISOPath -PassThru
    Get-WindowsImage -ImagePath "$(($img | Get-Volume).DriveLetter):\sources\install.wim"
    $img | Dismount-DiskImage
}

<#
.SYNOPSIS

A helper method to mount network shares, with optional credentials.
.DESCRIPTION

This command is designed to mount network shares to the Z: drive letter.
It will automatically unmount any drives that are mounted at that location.
If credentials are not passed, it will assume 'guest' for both the username and password.
.PARAMETER NetworkPath

This is the network path that should be mounted, including volumes if need be.
.PARAMETER NetworkUser

The username that should be used to connect to the network share.
.PARAMETER NetworkPass

The password that should be used to connect to the network share.
.EXAMPLE

MountNetShare -NetworkPath "\\Fileserver\Share"
.EXAMPLE

MountNetShare -NetworkPath "\\Fileserver\Share\Folder\Subfolder"
.EXAMPLE

MountNetShare -NetworkPath "\\Fileserver\SecureShare" -NetworkUser $username -NetworkPass $password
#>
function MountNetShare
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$NetworkPath,
        [string]$NetworkUser = "guest",
        [string]$NetworkPass = "guest"
    )

    if(Test-Path Z:) {Remove-PSDrive -Name "Z"}
    $credentials = New-Object System.Management.Automation.PSCredential ($NetworkUser, (ConvertTo-SecureString $NetworkPass -AsPlainText -Force))
    New-PSDrive -Name "Z" -PSProvider FileSystem -Root $NetworkPath -Credential $credentials -Persist -Scope Global
}