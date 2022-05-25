#region Step #1 (optional): Salvaging of drivers

 # I had to manually install a disk and network driver the last time I installed Nano Server.
 # I saved my previous WIM file and exported the installed drivers using the Dism cmdlets.

# These paths are specific to my system.
# This was my old Nano Server TP5 image.
$NanoTP5ImagePath =  'C:\Users\Matt\Desktop\Temp\NanoTP5Setup\NanoServerBin\NanoServer.wim'
$WimTempMountDir =   'C:\Users\Matt\Desktop\TempMountDir'
$ExportedDriverDir = 'C:\Users\Matt\Desktop\ExportedDrivers'

mkdir $WimTempMountDir
mkdir $ExportedDriverDir

$MountedImage = Mount-WindowsImage -ImagePath $NanoTP5ImagePath -Index 1 -Path $WimTempMountDir
Get-WindowsDriver -Path $WimTempMountDir | Export-WindowsDriver -Destination $ExportedDriverDir

$MountedImage | Dismount-WindowsImage -Discard
#endregion

#region Step #2: Nano Server WIM creation

# Place the Windows Server 2016 ISO in the same directory as your setup folder
$Server2016ISOFileName = 'en_windows_server_2016_x64_dvd_9327751.iso'
# Change this to whatever dir you want to house everything in.
$NanoServerSetupRootDir = 'C:\NanoServerSetup'
$SourceMediaCopyPath = Join-Path -Path $NanoServerSetupRootDir -ChildPath 'Server2016Media'
$NanoServerWimPath =   Join-Path -Path $NanoServerSetupRootDir -ChildPath 'NanoServer.wim'
$NanoServerInstallFiles = Join-Path -Path $NanoServerSetupRootDir -ChildPath 'NanoServer'
# The default password I'll use for this image.
# I only have this in here for PoC/reproducability purposes.
# You should never store default credentials in plaintext.
$DefaultPassword = 'ChangeMe1234'
$ComputerName =    'NanoServer'

# Obviously, you could just mount with a GUI. Why not do it in PowerShell though. ;)
$IsoMountDrive = Mount-DiskImage -ImagePath "$NanoServerSetupRootDir\$Server2016ISOFileName" -PassThru
$MountedDriveLetter = ($IsoMountDrive | Get-CimAssociatedInstance -ResultClassName MSFT_Volume).DriveLetter

# Copy Nano Server installation files from the mounted ISO
Copy-Item -Path "$($MountedDriveLetter):\NanoServer" -Destination $NanoServerInstallFiles -Recurse

# Create a directory to house temporary source media files
New-Item -Path $SourceMediaCopyPath -ItemType Directory

# We need the New-NanoServerImage function
Import-Module -Name $NanoServerSetupRootDir\NanoServer\NanoServerImageGenerator\NanoServerImageGenerator.psd1

$DefaultCredential = ConvertTo-SecureString -String $DefaultPassword -AsPlainText -Force

$Arguments = @{
    DeploymentType = 'Host'                # I'm installing on bare metal
    Edition = 'Datacenter'                 # Up to you which edition you need
    MediaPath = "$($MountedDriveLetter):\" # The root path of the mounted ISO
    BasePath = $SourceMediaCopyPath        # Scratch dir where media files are copied
    TargetPath = $NanoServerWimPath        # Where the generated Windows image (wim) will be saved
    ComputerName = $ComputerName
    AdministratorPassword = $DefaultCredential
    EnableRemoteManagementPort = $True     # Of course I want to manage with WinRM!
    Compute = $True                        # I'm building a Hyper-V server.
    OEMDrivers = $True                     # Needed when installing on bare metal
    Defender = $True                       # Why would I not want Defender?
}

New-NanoServerImage @Arguments

# Dismount the ISO image
$IsoMountDrive | Dismount-DiskImage

# Optionally, clean up the scratch directories
Remove-Item -Path $SourceMediaCopyPath -Recurse -Force
Remove-Item -Path $NanoServerInstallFiles -Recurse -Force
#endregion

#region Step #3 (optional): Apply recovered driver from step #1
# After creating the bootable WinPE media with Nano Server Image Generator,
# my network card wasn't recognized. So I'm going to apply the driver that
# I exported from my older image.
$TempMountDir = Join-Path -Path $NanoServerSetupRootDir -ChildPath 'Temp'
New-Item -Path $TempMountDir -ItemType Directory

$MountedImage = Mount-WindowsImage -ImagePath $NanoServerWimPath -Index 1 -Path $TempMountDir
$MountedImage | Add-WindowsDriver -Driver "$ExportedDriverDir\e1d64x64.inf_amd64_06707bf120a03f79\e1d64x64.inf"
$MountedImage | Dismount-WindowsImage -Save

Remove-Item -Path $TempMountDir
#endregion

<#
With the WIM built, I used the "Create bootable USB media" step with
 Nano Server Image Generator (http://aka.ms/NanoServerImageBuilder) to
 create a bootable WinPE image from which to apply the WIM to my Intel NUC.

Note! Booting from the WinPE image will automatically start applying the image
 without prompting you and wipe whatever existing partitions you had. This applies
 to v1.0.78 of Nano Server Image Generator.
#>

#region Step #4: Update the system
 # Again, I only have this in here for PoC/reproducability purposes.
$DefaultCredential = ConvertTo-SecureString -String 'ChangeMe1234' -AsPlainText -Force
$Credential = New-Object -TypeName Management.Automation.PSCredential -ArgumentList @('Administrator', $DefaultCredential)
$CimSession = New-CimSession -ComputerName 'NanoServer' -Credential $Credential

# Optionally, add a new, NTFS-formatted partition.
# By default, the Nano Server OS partition is set to 12GB.
# Run Get-Disk and first identify what disk number you want to add a partition to.
$Partition = Get-Disk -Number 0 -CimSession $CimSession | New-Partition -UseMaximumSize -AssignDriveLetter
$Partition | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Files'

$WindowsUpdateSession = New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession -CimSession $CimSession
$Result = $WindowsUpdateSession | Invoke-CimMethod -MethodName ScanForUpdates -Arguments @{ SearchCriteria = 'IsInstalled=0'; OnlineScan = $True}
$Result.Updates

$WindowsUpdateSession | Invoke-CimMethod -MethodName ApplyApplicableUpdates

# Optional: Restart the OS using the existing CIM session
# You could also call Restart-Computer from a PS Remoting session
$OS = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $CimSession
$OS | Invoke-CimMethod -MethodName Reboot

$CimSession | Remove-CimSession
#endregion
