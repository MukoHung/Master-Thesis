<#
Bypass file for OEM OOBE Setup.
Called from within Audit Mode.
#>

param(
    [int]    $TargetDisk = 0,
    [string] $NewBootWim = "$PSScriptRoot\Generic_x64.wim",
    [string] $UserName = 'MDTServer\MDTNonInteractive',
    [string] $Password = 'UnSecurePassword1234',
    [string] $BootType = 'x64',
    [string] $Target = 'h:'
)

$ErrorActionPreference = 'stop'

#region Find the largest on-disk partition
###############################################################################

$TargetDrive = get-disk -Number $TargetDisk | 
    Get-partition |
    Sort -Descending -Property Size | 
    Select-Object -First 1 | 
    Get-Volume | 
    foreach-object { $_.DriveLetter + ':' }

# get a drive letter for the system partition
get-disk -Number $TargetDisk | 
    get-partition | 
    where-object { -not $_.DriveLetter } |
    Where-Object Type -eq System |
    Add-PartitionAccessPath -AccessPath $Target

#endregion

#region Connect to a network share if Source is over the network...
###############################################################################

if ( -not ( test-path $NewBootWim ) ) {

    if ( $newBootWim.StartsWith('\\') -and $UserName -and $Password ) {
        # COnnect to the network share.
        net use "$(split-path $NewBootWim)" /user:$UserName "$Password"
    }
}

#endregion

#region Copy the Boot WIM
###############################################################################

new-item -ItemType directory -path $TargetDrive\Sources -Force -ErrorAction SilentlyContinue | Out-Null
copy-item $NewBootWim $TargetDrive\Sources\Boot.wim

robocopy /e $PSScriptRoot\x64 $Target\ /xf bcd bcd.log
 
#endregion

#region  Create a BCD entry
###############################################################################

Bcdedit /create "{ramdiskoptions}" /d "Ramdisk options" 
Bcdedit /set "{ramdiskoptions}" ramdisksdidevice  boot
Bcdedit /set "{ramdiskoptions}" ramdisksdipath  \boot\boot.sdi

$Output = bcdedit -create /d "MYIT_OEMHack" /application OSLOADER 
$GUID = $output | %{ $_.split(' ')[2] }

bcdedit /set $Guid device "ramdisk=[$TargetDrive]\sources\boot.wim,{ramdiskoptions}" 
bcdedit /set $Guid osdevice "ramdisk=[$TargetDrive]\sources\boot.wim,{ramdiskoptions}" 
bcdedit /set $Guid path \windows\system32\boot\winload.efi
bcdedit /set $Guid systemroot \windows 
bcdedit /set $Guid detecthal yes 
bcdedit /set $Guid winpe yes 
bcdedit /set $Guid ems no
bcdedit /set $Guid isolatedcontext yes 

Bcdedit /displayorder $Guid -addfirst
Bcdedit /default $Guid
Bcdedit /timeout 10

#endregion

#region  Reboot
###############################################################################

write-host "DONE"
shutdown -r -f -t 0 

#endregion
