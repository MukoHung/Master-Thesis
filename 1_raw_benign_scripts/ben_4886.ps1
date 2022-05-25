<#
.
.Synopsis
   Exports drivers in a Windows 10 driver store on the local system.
.DESCRIPTION
   Exports only active (DEFAULT) or ALL drivers in a Windows 10 driver store on the local system.
.EXAMPLE
   Export-Drivers.ps1 -OutputDir C:\DRIVERS -Verbose

   Exports only drivers for devices in use into the specified output directory.
.EXAMPLE
    Export-Drivers.ps1 -OutputDir C:\DRIVERS -IgnoreDock -Verbose

    Exports only drivers for devices in use except docking station drivers defined by the default $DockHardwareIDs parameter into the specified output directory.
.EXAMPLE
    Export-Drivers.ps1 -OutputDir C:\DRIVERS -DockOnly -Verbose

    Exports only docking station drivers defined by the default $DockHardwareIDs parameter into the specified output directory.
.EXAMPLE
   Export-Drivers.ps1 -OutputDir C:\TEMP -ExportDriverSet CompleteWindowsDriverStore -Verbose

   Exports drivers for all drivers in the Windows driver store
.EXAMPLE
   Export-Drivers.ps1 -OutputDir c:\ -CompareWithOldRefDriverPackageFolderPath 'C:\W10.HP.ZB15uG5.x64.v2018-08-29-1353 OSD Plus HPIA Intel driver added' -CopyOldRefDrivers -Verbose

   Exports only drivers for devices in use, compares the output with a previous driver package, sorts the differences between 'NEW,SAME,OLD' subfolders in the output directory, copies the old drivers into the new output directory.
.NOTES
   Author: Brandon McGowan, Brandon.Lee.McGowan@live.com, @brandonliveuh
   Please give credit where credit is due and do not take credit for my work.
   Updated: 2018-11-14
        - BLM: Added -IgnoreDock and -DockOnly switches. Please be sure to compare your output to previous production packages.
        - BLM: Added -DockHardwareIDs parameter and prepopulated with default value of HardwareIDs for HP Elite Thunderbolt 3 G2 Cube Dock, HP Elite Thunderbolt 3 G1 Dock, HP Elite USB-C G3 Dock, HP Elite USB-C G1 Dock
        - BLM: Added -IgnoreHardwareID parameter with no default values. Copy the Hardware ID from the Device manager entry for a given device.
   Updated: 2018-10-18
        - BLM: Added switch -CopyToCMDriverSource. include it to copy to default directory "C:\TEMP" or provide a different value for parameter -CMDriverSourceDir
   Updated: 2018-08-29
        - BLM: Added option to compare output to previous driver package with option "CompareWithOldRefDriverPackageFolderPath" and optionally copy old drivers from the old package using switch "CopyOldRefDrivers"
   Updated: 2018-08-21
        - BLM: Removed Pause from INSTALL.cmd PNPUtil based driver import batch file
   Updated: 2018-08-20
        - BLM: Fixed a typo in the CM Package import section
   Updated: 2018-08-14
        - Changed driver output to a flat structure
        - Auto genrates PNPUtil based Windows drive store import batch file that can be run by right clicking and "Run As Admin" to add drivers to Windows driver store on a system.
        - ExCluced "HID Global Corporation" vendor (ActivID virtual smartcard reader driver)
        - disable CMDriverPackageExport script by default in favor of standard CM package
   Updated: 2017-12-22
        - Added BIOS settings and information export. Useful for getting SKU Serial number and determining if devices where enabled at the point of driver export.
        - Renamed current Device manager output file name to include Manufacturer and model info
        - Corrected Driver Export CSV info. Often was blank or did not reflect drivers in the actual output driver files.
   Updated: 2017-12-21
        - Importing each driver via a for loop. The -Importfolder switch would cause import to fail if any drivers did not validate
   Updated: 2017-12-20
        - Corrected driver organization, excluded more files.
   Updated: 2017-11-25
        - Removed some unneeded driver organization
   Updated: 2017-10-24
        - Corrected Update-CMDistributionPoint usage to work with older Configuration Manager Cmdlet versions
   Updated: 2017-09-26
        - Reintegrated the auto generation of 'IMPORT-CMDriverPackage.PS1' into this script as a default option
        - Generates MDTImportScript as a default option
        - Added option to export the complete Windows Driver store or drivers for only active devices
        - Added more verbose messages to identify why when drivers are not being included in the export
#>

[CmdletBinding()]
[Alias()]
[OutputType([int])]
Param
(
    # Specify whether or not to export ALL drives in the Windows driver store. Will result in extra drivers not currently in use.
    [ValidateSet("ActiveDriversOnly", "CompleteWindowsDriverStore")]
    $ExportDriverSet = "ActiveDriversOnly",
    # Cleanup previous exports and retain the last three
    [switch]$Cleanup,
    [array]
    $KeepDriverNames = @(
        'heci.inf' #This is the 'Intel(R) Management Engine Interface'. Intel does not include the driver version or any other important info in the driver to match against. So if you don't add it here it will get deleted.
    ),
    # Specify driver classes to ignore. Use those specified in the driver CSV export
    [array]
    $IgnoreClasses = @(
        'Printer',
        'XB1UsbClass'
    ),
    # Specify driver Vendors to ignore. Use those specified in the driver CSV export
    [array]
    $IgnoreVendor = @(
        'ASIX', #My personal USB network adapter
        'Citrix Systems Inc.', #Cisco Anyconnect virtual VPN network adapter, should never export this
        'Cisco Systems', #Cisco Anyconnect virtual VPN network adapter, should never export this
        'HID Global Corporation', #Can't remember what this one is
        'Aladdin Knowledge Systems Ltd.' # ActiveID virtual device driver. Will install via app instead.
    ),
    $IgnoreDriver = @(
        'cisstrt.inf_amd64_d02df93755a482a1', # This is a known bad Conexant Audio driver provided  by sp76079. Added incase the download appears in the HPSDM download again. Use alternative updated driver from windows update.
        'szccid.inf_amd64_e0e1129f474bb78a' # Known bad Alcore smart card reader driver, never loads. Shows a error in device manager. Better to use native Windows Smart card class driver
    ),
    $IgnoreHardwareID = @(
        'Example, General Description for an entry goes here. Include the Model of computer and device name maybe',
        'HardwareID copied from Device Manager goes here'
    ),
    [switch]$IgnoreDock,
    [switch]$DockOnly,
    $DockHardwareIDs = @(
        'NOTE:Make two entries for each Hardware ID. One for the Device name or description that will Never match anything so it is safe to include it.',
        'And one for the actual HardwareID Copied directly from the device in Device Manager that will actually provide the matching.',
        'ETB3G2CubeDock:MEDIA_Realtek Semiconductor Corp._6.3.9600.171_rtxusbadft1.inf_amd64_60d8b182f64d5269 HP Thunderbolt Dock Audio Headset',
        'USB\VID_03F0&PID_0269&REV_0003&MI_00',
        'USB\VID_03F0&PID_0269&REV_0017&MI_00',
        'USB\VID_03F0&PID_0269&MI_00',
        'ETB3G2CubeDock:Net_Realtek_10.22.1212.2017_rtux64w10.inf_amd64_2d6a016cc91488f8 Realtek USB GbE Family Controller',
        'USB\VID_0BDA&PID_8153&REV_3001',
        'USB\VID_0BDA&PID_8153',
        'ETB3G2CubeDock:System_Intel(R) Corporation_17.4.75.8_tbt100x.inf_amd64_04d6e57dae007385',
        'PCI\VEN_8086&DEV_15D9&SUBSYS_00008086&REV_02',
        
        'ETB3G1Dock:Broadcom NetXtreme Gigabit Ethernet',
        'PCI\VEN_14E4&DEV_1682&SUBSYS_168214E4&REV_01',
        'ETB3G1Dock:HP Dock Audio/Conexant',
        'USB\VID_0572&PID_1804&REV_0304&MI_00',
        'ETB3G1Dock:Thunderbolt(TM) Controller - 15D2',
        'PCI\VEN_8086&DEV_15D2&SUBSYS_11112222&REV_02',
        'PCI\VEN_8086&DEV_15D2&SUBSYS_11112222',
        'ETB3G1Dock:Thunderbolt(TM) Controller - 1577',
        'PCI\VEN_8086&DEV_1577&SUBSYS_11112222&REV_00',
        'PCI\VEN_8086&DEV_1577&SUBSYS_11112222',
        'ETB3G1Dock:ASMedia USB Root Hub',
        'USB\ASMEDIAROOT_Hub&VID1B21&PID1142&VER01164901',
        'ETB3G1Dock:ASMedia USB3.0 eXtensible Host Controller',
        'PCI\VEN_1B21&DEV_1142&SUBSYS_8190103C&REV_00',
        
        'EUSBCG3Dock:Realtek USB GbE Family Controller',
        'USB\VID_0BDA&PID_8153&REV_3001',
        'EUSBCG3Dock:USB Audio Device',
        'USB\VID_0BDA&PID_482A&REV_0002&MI_00',
        
        'EUSBCG1Dock:DisplayLink USB Device',
        'USB\VID_17E9&PID_4354&REV_3109&MI_00',
        'EUSBCG1Dock:Realtek USB GbE Family Controller',
        'USB\VID_0BDA&PID_8153&REV_3000',
        'EUSBCG1Dock:DisplayLink USB Audio Adapter',
        'USB\VID_17E9&PID_4354&REV_3109&MI_02'
    ),
    # Specifcy base directory to output driver package
    #[ValidateScript({ Test-Path $_ })]
    $OutputDir = "C:" ,
    # Specify whether or not to copy final driver output to common SCCM Driver source
    [switch]
    $CopyToCMDriverSource,
    [switch]
    $SkipConnectHardwareWarning,
    # Specify SCCM Driver source
    [ValidateScript( { Test-Path $_ })]
    $CMDriverSourceDir = "C:\TEMP",
    #Compare resulting driver package with another driver package source
    [ValidateScript( { Test-Path $_ })]
    $CompareWithOldRefDriverPackageFolderPath,
    # Specify whether or not to copy old drivers into new driver package during comparison
    [switch]
    $CopyOldRefDrivers,
    # Specify whether or not to seperate out the NEW drivers into the new driver package during comparison into it's own sub folder
    [switch]
    $SeperateNewDrivers,
    # Specify whether or not to seperate out the SAME drivers into the new driver package during comparison into it's own sub folder
    [switch]
    $SeperateSameDrivers,
    # Specify whether or not to optionally create a trigger file for the auto import script
    [switch]
    $AutoImportAtCompletion,
    # Specify whether or not to generate the companion Microsoft Configuration Manager DRIVER PACKAGE import script file.
    [bool]
    $GenerateCMDriverPackageImportScript = $false ,
    # Specify whether or not to generate the companion Microsoft Configuration Manager STANDARD APPLICATION PACKAGE import script file.
    [bool]
    $GenerateCMDPackageImportScript = $true ,
    # Specify whether or not to generate a PNPUtil Windows import batch file.
    [bool]
    $GeneratePNPUtilWindowsImportCMD = $true ,
    # Specify whether or not to copy a companion Mass import script file by specifying it's location.
    [ValidateScript( { Test-Path $_ })]
    $AutoMassCMImportScriptFileToCopy,
    # Specify whether or not to Generate a companion import Microsoft Deployment Tool Kit driver import script file
    [bool]
    $GenerateMDTImportScript = $true ,
    # Specify whether or not to optionally create a Zipped copy of the driver package
    [switch]
    $CreateZip,
    [switch]
    $EmailResults,
    [string]
    $EmailTo
)
if (!$SkipConnectHardwareWarning) {
    "Insert a SmartCard, SD Card and all other devices for which you intend to export a driver for." | Write-Warning
    Read-Host 'Press Enter to continue'
}
"Getting Directory and file names for driver package output" | Write-Verbose
$ComputerSystem = GWMI Win32_ComputerSystem
$Manufacturer = $ComputerSystem.Manufacturer
$Model = ($ComputerSystem.Model).trim()
$ManufacturerABRV = $Manufacturer -replace " ", "" -replace "HP", "HP" -replace "Hewlett-Packard", "HP" -replace "MicrosoftCorporation", "MS"
$ModelABRV = $Model -replace "HP" -replace "Elite", "E" -replace "Pro", "P" -replace "Book", "B" -replace "Desk", "D" -replace "Folio", "F" -replace "Revolve", "R" -replace " "

$Architecture = $env:PROCESSOR_ARCHITECTURE -replace "AMD64", "x64"
$WindowsVer = ("$((Get-WmiObject Win32_OperatingSystem).Caption -replace "Microsoft" -replace "Server" -replace "2012","7" -replace "2016","10" -replace "Standard" -replace "DataCenter" -replace "Pro" -replace "Enterprise" -replace "Home") $Architecture" -replace "  ", " " -replace "  ", " ").Trim()
$OS = $WindowsVer -replace "Windows", "W" -replace "Server" -replace "2012", "7" -replace "2016", "10" -replace "Standard" -replace "DataCenter" -replace "x86" -replace "x64" -replace " "
$DateTime = Get-Date -Format yyyy-MM-dd-HHmm
$OSManModelArch = "$OS.$ManufacturerABRV.$ModelABRV.$Architecture"
$OSManModelArchDate = "$OS.$ManufacturerABRV.$ModelABRV.$Architecture.v$DateTime"
$OutputDirManModelArchDate = "$OutputDir\$OSManModelArchDate"
$OutputDirManModelArchDateIMPORTED = "$OutputDir\$OSManModelArchDate"
$OutputDirManModelArchDateDriverExportCSVFile = "$OutputDirManModelArchDate\Driver Export $OSManModelArchDate.csv"

$OutputDirManModelArchDateDeviceManagerCSVFile = "$OutputDirManModelArchDate\Device Manager $OSManModelArchDate.csv"

$OutputDirManModelArchDatePNPUtilWindowsImportCMDFile = "$OutputDirManModelArchDate\INSTALL.cmd"

$OutputDirManModelArchDateMDTImportPS1File = "$OutputDirManModelArchDate\Import-MDTDrivers $OSManModelArchDate.PS1"
$OutputDirManModelArchDateCMDriverPackageImportPS1File = "$OutputDirManModelArchDate\IMPORT-CMDriverPackage.PS1"
$OutputDirManModelArchDateCMPackageImportPS1File = "$OutputDirManModelArchDate\IMPORT-CMPackage.PS1"
$OutputDirManModelArchDateHTMFile = "$OutputDirManModelArchDate\HPSSMLog_$OSManModelArchDate.htm"
$OutputDirManModelArchDateBIOSSettingsCSVFile = "$OutputDirManModelArchDate\BIOSSettings $OSManModelArchDate.csv"
$OutputDirManModelArchDateEXPORTEDFile = "$OutputDirManModelArchDate\EXPORTED.TXT"
$OutputDirManModelArchDateIMPORTFile = "$OutputDirManModelArchDate\IMPORT.TXT"
$OutputDirManModelArchDateZIPFile = "$OutputDir\$OSManModelArchDate.zip"


if ($Cleanup) {
    $LastThreeExport = Get-ChildItem -Path "$OutputDir\$OSManModelArch`*" -Directory | Select-Object -Last 2
    Get-ChildItem -Path "$OutputDir\$OSManModelArch`*" -Directory | Where-Object { $_.Name -notin $LastThreeExport.Name } | Remove-Item -Recurse -Force
}

"Creating Output Directory if needed" | Write-Verbose
if (!(Test-Path $OutputDirManModelArchDate )) { 
    "`$OutputDirManModelArchDate $OutputDirManModelArchDate did not exist. Creating now" | Write-Verbose
    New-Item $OutputDirManModelArchDate -ItemType Directory 
}
"Exporting a list of ONLY system drivers currently in use and outputting results to Comma Seperated Value file for processing." | Write-Verbose
$Devices = Get-WmiObject win32_PNPSignedDriver | ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $env:COMPUTERNAME -PassThru | Add-Member -MemberType NoteProperty -Name 'MODEL' -Value ((GWMI Win32_ComputerSystem).MODEL) -PassThru | Add-Member -MemberType NoteProperty -Name 'SerialNumber' -Value ((GWMI Win32_BIOS).SerialNumber) -PassThru }
$Devices | Select-Object -Property ComputerName, MODEL, SerialNumber, Description, DeviceClass, DeviceID, DeviceName, DriverDate, DriverName, DriverProviderName, DriverVersion, FriendlyName, HardWareID, InfName, IsSigned, Location, Manufacturer, Signer | Export-Csv $OutputDirManModelArchDateDeviceManagerCSVFile -NoTypeInformation -Force

Write-Debug 'check devices'

"Exporting a list of ALL drivers in the system Windows driver store not included inbox and outputting results to Comma Seperated Value file for processing." | Write-Verbose
Export-WindowsDriver -Online -Destination $OutputDirManModelArchDateIMPORTED | Export-Csv -Path $OutputDirManModelArchDateDriverExportCSVFile -NoTypeInformation
Start-Sleep -Seconds 10
"Importing CSV for processing and organization of exported drivers" | Write-Verbose

$CSV = Import-Csv $OutputDirManModelArchDateDriverExportCSVFile
$CSV | measure
"Check Driver export CSV so far" | Write-Debug

#"Waiting 5minutes before continuing" | Write-Verbose
#Start-Sleep -Seconds 300

"Processing exported drivers and organizing into categories based on Driver class, vendor and version." | Write-Verbose
$csv | ForEach-Object { 
    $Driver = $_
    $DriverName = $_.OriginalFileName | Split-Path -Leaf
    $OriginalFileNameParentFolder = $($_.OriginalFilename | Split-Path | Split-Path -Leaf)
    $DriverFolder = "$OutputDirManModelArchDateIMPORTED\$OriginalFileNameParentFolder"    
    $DriverVersion = $_.Version
    $DriverClassName = $_.ClassName
    $DriverProviderName = $_.ProviderName
    $DriverInf = $_.Driver
    $HardwareID = $Devices | Where-Object { $_.DriverVersion -eq $DriverVersion -and $_.DriverProviderName -eq $DriverProviderName } | Select-Object -ExpandProperty HardWareID
    
    $HardwareID

    foreach ($item in $HardwareID) {
        "Processing $item" | Out-File -FilePath "$OutputDirManModelArchDate\DriverExport.log" -Encoding default -Append -Force
        [switch]$IsDock = $false
        if ($item -in $DockHardwareIDs) {
            $IsDock = $true
        }
    }
    
    "Removing user defined unwanted driver classes, vendors, printers and virtual devices." | Write-Verbose
    if ($_.ClassName -in $IgnoreClasses ) {
        "Removing user defined ignored driver class ""$DriverClassName"" in ""$DriverFolder""." | Out-File -FilePath "$OutputDirManModelArchDate\DriverExport.log" -Encoding default -Append -Force
        Remove-Item -Path $DriverFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
    elseif ( $_.ProviderName -in $IgnoreVendor ) {
        "Removing user defined ignored driver vendor/provider ""$DriverProviderName"" in ""$DriverFolder""." | Out-File -FilePath "$OutputDirManModelArchDate\DriverExport.log" -Encoding default -Append -Force
        Remove-Item -Path $DriverFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
    elseif ( $OriginalFileNameParentFolder -in $IgnoreDriver ) {
        "Removing user defined ignored specific driver ""$DriverName"" in ""$DriverFolder""." | Out-File -FilePath "$OutputDirManModelArchDate\DriverExport.log" -Encoding default -Append -Force
        Remove-Item -Path $DriverFolder -Recurse -Force -ErrorAction SilentlyContinue

    }
    elseif ( $IgnoreDock -and $IsDock ) {
        "Removing user defined Docking station HardwareID ""$HardwareID"" in ""$DriverFolder""." | Out-File -FilePath "$OutputDirManModelArchDate\DriverExport.log" -Encoding default -Append -Force
        Remove-Item -Path $DriverFolder -Recurse -Force -ErrorAction SilentlyContinue
        
    }
    elseif ($DockOnly -and $IsDock -ne $true ) {
        "Removing user defined NON Docking station HardwareID ""$item"" in ""$DriverFolder""." | Out-File -FilePath "$OutputDirManModelArchDate\DriverExport.log" -Encoding default -Append -Force
        Remove-Item -Path $DriverFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
    elseif ( ($DriverVersion -notin $Devices.DriverVersion -AND $DriverName -notin $KeepDriverNames) -and $ExportDriverSet -eq 'ActiveDriversOnly' ) {
        "Removing copy of exported driver ""$DriverName $DriverVersion"" found in Windows Driver store but not currently in use by a active device from ""$DriverFolder"". To keep this driver, run the export again while the device is active." | Out-File -FilePath "$OutputDirManModelArchDate\DriverExport.log" -Encoding default -Append -Force
        Remove-Item -Path $DriverFolder -Recurse -Force -ErrorAction SilentlyContinue
        
    }
    else {
        # Categorize drivers into classes
        "Creating driver Category and Vendor directories for better organization." | Out-File -FilePath "$OutputDirManModelArchDate\DriverExport.log" -Encoding default -Append -Force
        #$OutputDirManModelArchDateClassProviderVer = "$OutputDirManModelArchDateIMPORTED\$($_.ClassName)\$($_.ProviderName -replace '\?','')\$($_.Version)"
        $OutputDirManModelArchDateClassProviderVer = "$OutputDirManModelArchDateIMPORTED\$($_.ClassName)_$($_.ProviderName -replace '\?','')_$($_.Version)_$OriginalFileNameParentFolder"

        "`$OutputDirManModelArchDateClassProviderVer = $OutputDirManModelArchDateClassProviderVer"
        #if (!(Test-Path $OutputDirManModelArchDateClassProviderVer )){ New-Item $OutputDirManModelArchDateClassProviderVer -ItemType Directory }
        "Moving drivers into their proper Class and Vendor folders. Will attempt to move multiple times if failures encoutered" | Out-File -FilePath "$OutputDirManModelArchDate\DriverExport.log" -Encoding default -Append -Force
        #Rename-Item $DriverFolder\* $OutputDirManModelArchDateClassProviderVer\ -Force -ErrorAction SilentlyContinue 
        "$DriverFolder $OutputDirManModelArchDateClassProviderVer" | Out-File -FilePath "$OutputDirManModelArchDate\DriverExport.log" -Encoding default -Append -Force
        Rename-Item $DriverFolder $OutputDirManModelArchDateClassProviderVer -Force

        <#
        do { 
            $int = $null
            if (!(Test-Path $OutputDirManModelArchDateClassProviderVer)){ New-Item -Path $OutputDirManModelArchDateClassProviderVer -ItemType Directory }
            #Move-Item $DriverFolder\* $OutputDirManModelArchDateClassProviderVer\ -Force -ErrorAction SilentlyContinue 
            #Move-Item $DriverFolder\* $OutputDirManModelArchDateClassProviderVer -Force 
            #Copy-Item $DriverFolder\* -Recurse $OutputDirManModelArchDateClassProviderVer -Force
            if (!$?)
                {
                    Start-Sleep -Seconds 3
                    $int ++
                }
            } until (!(Test-Path $DriverFolder) -or $int -gt 100 )
            #>
    }
}


"Copying mandatory drivers for given systems." | Write-Warning
$ModelWMI = (Get-WmiObject Win32_ComputerSystem).Model
$ModelWMI = (Get-WmiObject Win32_ComputerSystem).Model
Copy-Item -Path "C:\TEMP\HPIAREPORTS\REQUIREDDRIVERS\ALLSYSTEMS\*" -Destination $OutputDirManModelArchDate -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path "C:\TEMP\HPIAREPORTS\REQUIREDDRIVERS\$ModelWMI\*" -Destination $OutputDirManModelArchDate -Recurse -ErrorAction SilentlyContinue


"Outputting a new Driver export CSV list without unwanted driver classes and vendors" | Write-Warning
#$CSV | Where-Object { $_.ClassName -NotIn $IgnoreClasses -and $_.ProviderName -notin  $IgnoreVendor } |  Export-Csv -Path $OutputDirManModelArchDateCSVFile -NoTypeInformation
#$CSV | Where-Object { $_.ClassName -NotIn $IgnoreClasses -and $_.ProviderName -notin  $IgnoreVendor -and $_.OriginalFileName -notin $DuplicateDrivers -and $DriverVersion -notin $Devices.DriverVersion } |  Export-Csv -Path $OutputDirManModelArchDateCSVFile -NoTypeInformation -Force -Encoding Default

$CSV = $CSV | Where-Object { $_.ClassName -NotIn $IgnoreClasses }
$CSV | measure
"Check CSV output so far: Removed Ignored Classes" | Write-Debug

$CSV = $CSV | Where-Object { $_.ProviderName -notin $IgnoreVendor }
$CSV | measure
"Check CSV output so far: Removed Ignored Vendors" | Write-Debug

$CSV = $CSV | Where-Object { $_.Version -in $Devices.DriverVersion }
$CSV | measure
"Check CSV output so far: Removed innactive drivers" | Write-Debug

$CSV | Export-Csv -Path $OutputDirManModelArchDateDriverExportCSVFile -NoTypeInformation -Force -Encoding Default

if ($GeneratePNPUtilWindowsImportCMD) {
    "Generating driver import script for Windows via PNPUtil" | Write-Verbose
    @"
::INSTRUCTIONS
::Place this file in any folder containing INF based drivers.
::Right click and "Run As Administrator" in the Windows File Explorer.
::It will find and install all drivers in the current folder AND all subdirectories.
%windir%\system32\pnputil.exe /add-driver %~dp0%\*.inf /install /subdirs
"@ | Out-File -FilePath $OutputDirManModelArchDatePNPUtilWindowsImportCMDFile -Encoding default
}

if ($GenerateMDTImportScript) {
    "Generating Driver Import script for Microsoft Deployment Toookit" | Write-Verbose
    @"
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name 'DS001' -PSProvider MDTProvider -Root `$((Get-MDTPersistentDrive)[0].Path)
new-item -path "DS001:\Out-of-Box Drivers" -enable "True" -Name "$WindowsVer" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Out-of-Box Drivers\$WindowsVer" -enable "True" -Name "$Model" -Comments "Imported from $OSManModelArchDate" -ItemType "folder" -Verbose
new-item -path "DS001:\Selection Profiles" -enable "True" -Name "$WindowsVer $Model" -Comments "Created from $OSManModelArchDate" -Definition "<SelectionProfile><Include path=``"Out-of-Box Drivers\$WindowsVer\$Model``" /></SelectionProfile>" -ReadOnly "False" -Verbose 
import-mdtdriver -path "DS001:\Out-of-Box Drivers\$WindowsVer\$Model" -SourcePath `$PSScriptRoot -Verbose
"@ | Out-File -FilePath $OutputDirManModelArchDateMDTImportPS1File -Encoding default
}

if ($GenerateCMDPackageImportScript) {
    @"
if (`$PSScriptRoot -match '^\\' -and (Test-Path "FILESYSTEM::`$PSScriptRoot"))
{    
    'CM Package Source IS UNC path and accessible'
    `$Name                     = `$PSScriptRoot | Split-Path -Leaf
    `$Description              = `$PSScriptRoot | Split-Path -Leaf
    `$Manufacturer             = 'BLM'
    `$Language                 = 'EN-US'
    `$Version                  = (`$Name -split ".v")[1]
    `$SourcePath               = `$PSScriptRoot
    `$CommandLine              = 'INSTALL.CMD'
    `$CommandlineDescription   = 'PNPUtil Windows import'
    `$DiskSpaceRequirementInMB = [int]("{0:N0}" -f ((Get-ChildItem "FILESYSTEM::`$PSScriptRoot" -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB))

    if (!(`$CMPackage = Get-CMPackage -Name `$Name | Where-Object { `$_.Version -eq `$Version }) | Select-Object -First 1 )
    {
        "Package ""`$Name"" does NOT already exist." | Write-Warning
        'Creating Configuration Manager Standard application package from drivers.' | Write-Warning
        `$CMPackage = New-CMPackage -Name `$Name -Description `$Description -Manufacturer `$Manufacturer -Language `$Language -Version `$Version -Path `$SourcePath
        New-CMProgram -CommandLine `$CommandLine -DiskSpaceUnit MB -DiskSpaceRequirement `$DiskSpaceRequirementInMB -PackageId `$CMPackage.PackageID -StandardProgramName `$CommandlineDescription -RunType Normal -ProgramRunType OnlyWhenUserIsLoggedOn -RunMode RunWithAdministrativeRights -UserInteraction `$false
    }
    ELSE
    {
        "Package ""`$Name"" Already exists. Skipping package creation" | Write-Warning
        "To import this driver package anyway, you must rename the folder containing the driver package to a unique name that does not match any existing standard application package" | Write-Warning
    }
}
ELSE
{
    'Path to source files does not exist or is not a UNC path' | Write-Warning
    'To run this script you must do the following:' | Write-Warning
    '- Run this script from an Elevated Powershell prompt' | Write-Warning
    '- Provide the full UNC path to this script.' | Write-Warning
    '- Run from a system with the Configuration Manager Console installed' | Write-Warning
    '- The system must have the CM Provider Commandlets loaded' | Write-Warning
}
"@ | Out-File -FilePath $OutputDirManModelArchDateCMPackageImportPS1File -Encoding default
}

if ($GenerateCMDriverPackageImportScript) {
    "Generating Driver Import script for Microsoft Configuration Manager" | Write-Verbose
    @'
<#
.Synopsis
   MUST be run on a system with the SCCM Console installed and with elevated rights.
   Imports the driver contents of the containing folder into Microsoft System Center Configuration Manager
.DESCRIPTION
   Imports the driver contents of the containing folder into Microsoft System Center Configuration Manager
   
   Create a folder structure like the example below.
   Place this script "Import-CMDriverPackage" in the root of the folder structure
   
   .\W10.HP.EliteBook850G3.x64.v2017-01-01
   .\IMPORTED
        Place all driver inf's and companion driver files in any structure you want here
   .\PACKAGED
        \v1
            Leave this folder empty
   .\Import-CMDriverPackage.ps1

.EXAMPLE
   .\Import-CMDriverPackage

   This will import all drivers in the "IMPORTED" folder into the first SCCM instance with the following attributes.
   - Will assign the driver category as the name of the folder containing the driver contents
   - Will assign the driver package name and description as the name of the folder containing the driver contents

.EXAMPLE
   .\IMPORT-CMDriverPackage.ps1 -DriverPackageName "HP Laptop" -DriverCategories "cat1","cat2","cat3","cat4","cat5" -DriverPackageDescription "test description" -Verbose

   Will import the contents of driver source folder .\IMPORTED and assign the specified driver package name, categories and description.

.EXAMPLE
   .\IMPORT-CMDriverPackage.ps1" -UNCDriverSource "\\ComputerName\NetworksharePath\DriverPackageSource" -UNCDriverPackagePath "\\ComputerName\NetworksharePath\DriverPackagePath" -DriverPackageName "HP Laptop" -DriverCategories "cat1","cat2","cat3","cat4","cat5" -DriverPackageDescription "test description 10" -Verbose

   Will import the driver contents of the specified network file share, create a new driver package at the specified Network file share driver package path with the specified driver package name, categories and description. 

.EXAMPLE
   .\IMPORT-CMDriverPackage.ps1" -DistributePackage

   Will create the new driver package with default and distribute it to the first distribution point found.
   Only use this for lab environments where there is usually only one distribution point.

.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   - Your default or specified driver package destination must be empty.
   Author: Brandon McGowan, Brandon.Lee.McGowan@live.com, @brandonliveuh
   Please give credit where credit is due and do not take credit for my work.
   Updated: 2017-12-21
        - Importing each driver via a for loop. The -Importfolder switch would cause import to fail if any drivers did not validate
   Updated: 2017-12-20
        - Corrected driver organization, excluded more files.
   Updated: 2017-10-24
        - Corrected Update-CMDistributionPoint usage to work with older Configuration Manager Cmdlet versions
   Updated: 2017-09-26
        - Added Update-CMDistributionPoint to resolve missing package size in CM Console
        - Reintegrated into Export-Drivers.ps1 script as a default option
#>
[CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                SupportsShouldProcess=$true, 
                PositionalBinding=$false,
                HelpUri = 'http://www.microsoft.com/',
                ConfirmImpact='Medium')]
[Alias()]
[OutputType([String])]
Param
(
    #Provide the SCCM Site code or accept the default as the first Site Code found
    [Parameter(ParameterSetName='Manual')]
    [Parameter(ParameterSetName='Automatic')]
    [ValidateScript({
        $SiteCode = $_
        Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
        ((Get-PSProvider | Where-Object {$_.Name -eq 'CMSite'}).Drives).Name -eq $SiteCode
    })]
    [string]
    $SiteCode = (Invoke-Command {
        Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
        ((Get-PSProvider | Where-Object {$_.Name -eq 'CMSite'}).Drives).Name | Select-Object -First 1
    }) ,
    #Provide Package name or default to name of containing folder
    [Parameter(ParameterSetName='Manual')]
    [Parameter(ParameterSetName='Automatic')]
    [ValidateLength(0,50)]
    [string]
    $DriverPackageName = (Get-Item FILESYSTEM::$PSScriptRoot).Name,
    
    #One or more category to assign the driver package
    [Parameter(ParameterSetName='Manual')]
    [Parameter(ParameterSetName='Automatic')]
    [array]
    $DriverCategories = (Get-Item FILESYSTEM::$PSScriptRoot).Name ,
    
    #Description of package or defaults to name of driver Package
    [Parameter(ParameterSetName='Manual')]
    [Parameter(ParameterSetName='Automatic')]
    [ValidateLength(0,127)]
    [string]
    $DriverPackageDescription = (Get-Item FILESYSTEM::$PSScriptRoot).Name ,
    
    #Specify this to override default driver source which would be the folder named "Imported" in your driver source folder
    [Parameter(ParameterSetName='Manual')]
    [ValidateScript({ (Test-Path FILESYSTEM::$_) -and (([uri]$_).IsUnc) })]
    $UNCDriverSource = "$PSScriptRoot\IMPORTED" ,
    
    #Specify this to override default driver package destination which would be the folder named "PACKAGED\v1" in your driver source
    [Parameter(ParameterSetName='Manual')]
    [ValidateScript({ (Test-Path FILESYSTEM::$_) -and (([uri]$_).IsUnc) })]
    $UNCDriverPackagePath = "$PSScriptRoot\PACKAGED\v1",
    
    #Optionally organize a standard SCCM Driver package export contents into default directories
    [Parameter(ParameterSetName='Automatic')]
    [switch]
    $OrganizePackage,
    
    #Only do this if you are in a lab environment with a single distribution point.    
    [Parameter(ParameterSetName='Manual')]
    [Parameter(ParameterSetName='Automatic')]
    [switch]
    $DistributePackage,
    
    # SCCM Distribution Point Group name if you want to distribute the package after import
    # Will get the first available sitecode if wasn't previous specified
    [Parameter(ParameterSetName='Manual')]
    [Parameter(ParameterSetName='Automatic')]
    [ValidateScript({
        if (!$SiteCode)
        {
            Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
            $SiteCode = ((Get-PSProvider | Where-Object {$_.Name -eq 'CMSite'}).Drives).Name | Select-Object -First 1
        }
        Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
        cd $SiteCode`:
        (Get-CMDistributionPointGroup -Name $_ ) -ne $null
        })]
    $DistributionPointGroupName ,

    # SCCM Distribution Point name if you want to distribute the package after import
    [Parameter(ParameterSetName='Manual')]
    [Parameter(ParameterSetName='Automatic')]
    [ValidateScript({ 
        $DistributionPoint = $_
        if (!$SiteCode)
        {
            Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
            $SiteCode = ((Get-PSProvider | Where-Object {$_.Name -eq 'CMSite'}).Drives).Name | Select-Object -First 1
        }
        Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
        cd $SiteCode`:
        ((Get-CMDistributionPointInfo).Name | Where-Object { $_ -EQ $DistributionPoint }) 
    })]
    $DistributionPoint
)


"Changing directory to the local file system to prevent any issues accessing the file system while at another PSProvider path such as the Configuration Manager PSProvider." | Write-Verbose
$PreviousDir = $PWD
Set-Location $env:SystemDrive

"Determining path to SCCM install and powershell module" | Write-Verbose
Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
"Getting SCCM site code and switching to PSProvider" | Write-Verbose
$SiteCode = ((Get-PSProvider | Where-Object {$_.Name -eq 'CMSite'}).Drives).Name | Select-Object -First 1
Set-Location -Path "$((Get-PSDrive -PSProvider CMSite).Name):"

"Getting start time" | Write-Verbose
$TimeStarted = Get-Date

if ($OrganizePackage)
{
    $SkipItems = "IMPORTED","PACKAGED","v1","Device*.csv","Driver*.csv","*.ps1","SP*.EXE","SP*.CVA","SP*.html"
    New-Item "FILESYSTEM::$PSScriptRoot\IMPORTED" -ItemType Directory -ErrorAction SilentlyContinue
    New-Item "FILESYSTEM::$PSScriptRoot\PACKAGED\v1" -ItemType Directory -ErrorAction SilentlyContinue
    Get-ChildItem "FILESYSTEM::$PSScriptRoot" -Exclude $SkipItems | Where-Object { $_.Name -NotIn $SkipItems } | Move-Item -Destination "FILESYSTEM::$PSScriptRoot\IMPORTED"
}

"Creating new blank array to store SCCM Driver Categories to assign to new package later" | Write-Verbose
$CMCategories = @()

foreach ($DriverCategory in $DriverCategories)
{
    "Clearing current/previous Category search result and searching for existing category" | Write-Verbose
    $CMCategory = $null
    $CMCategory = Get-CMCategory -Name $DriverCategory -ErrorAction SilentlyContinue
    if ($CMCategory -eq $null)
    {
        "Category does not already exist, creating it and assigning to the array of categories to add later" | Write-Verbose
        $CMCategories += New-CMCategory -Name $DriverCategory -CategoryType DriverCategories
    }
    else
    {
        "Category allready exists. Assigning existing category to the array of categories to add later" | Write-Verbose
        $CMCategories += $CMCategory
    }
}
"Creating new blank driver package unless it allready exists." | Write-Verbose
$CMDriverPackage = New-CMDriverPackage -Name $DriverPackageName -Path $UNCDriverPackagePath -Description $DriverPackageDescription
"Importing drivers into new driver package and assigning categories." | Write-Verbose
$Drivers = Get-ChildItem "FILESYSTEM::$UNCDriverSource" -Recurse -Include *.INF
foreach ($Driver in $Drivers)
{
    Import-CMDriver -UncFileLocation $Driver.FullName -ImportDuplicateDriverOption AppendCategory -EnableAndAllowInstall $true -AdministrativeCategory $CMCategories -DriverPackage $CMDriverPackage -ErrorAction Continue
}
"Updating Distribution points, should be none right now but is needed to get package size." | Write-Verbose
Update-CMDistributionPoint -DriverPackageId $CMDriverPackage.PackageID
if ($DistributePackage)
{
    "Distributing new package to SCCM distribution point(s)" | Write-Verbose
    if ($DistributionPointGroupName)
    {
        Start-CMContentDistribution -DriverPackage $CMDriverPackage -DistributionPointGroupName $DistributionPointGroupName
    }
    if ($DistributionPoint)
    {
        Start-CMContentDistribution -DriverPackage $CMDriverPackage -DistributionPointName $DistributionPoint
    }
}

"Changing directory back to previous location" | Write-Verbose
Set-Location $PreviousDir

$TimeEnded = Get-Date
Write-Warning "Process took"
$TimeEnded - $TimeStarted
'@ | Out-File -FilePath $OutputDirManModelArchDateCMDriverPackageImportPS1File -Encoding default
}



"Copying HP System Software Manager utility SoftPaq installation log file if it exists" | Write-Verbose
if (Test-Path "$env:TEMP\$env:COMPUTERNAME.htm") {
    "$env:TEMP\$env:COMPUTERNAME.htm exists. Copying it now" | Write-Verbose
    Copy-Item "$env:TEMP\$env:COMPUTERNAME.htm" "$OutputDirManModelArchDateHTMFile"   
}

"Optionally creating trigger file for the auto import script" | Write-Verbose
"`$AutoImportAtCompletion = $AutoImportAtCompletion" | Write-Verbose
if ($AutoImportAtCompletion) { 
    Out-File -FilePath $OutputDirManModelArchDateEXPORTEDFile -Encoding default -Force
    Out-File -FilePath $OutputDirManModelArchDateIMPORTFile -Encoding default -Force 
}

if ($CreateZip) {
    "Creating Driver Package zip file" | Write-Verbose
    Add-Type -AssemblyName "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($OutputDirManModelArchDate, $OutputDirManModelArchDateZIPFile)   
}

"Exporting BIOS information and current settings. Use to determine if hardware was disabled at the point of export." | Write-Verbose
#Get-WmiObject -Namespace root/HP/InstrumentedBIOS -ClassName HP_BIOSSetting -ErrorAction SilentlyContinue | Export-Csv -Path $OutputDirManModelArchDateBIOSSettingsCSVFile -Encoding Default -NoTypeInformation

if ( $CompareWithOldRefDriverPackageFolderPath ) {
    "Comparing resulting Driver package with another" | Write-Verbose
    $DiffGridView = Compare-Object -ReferenceObject (Get-ChildItem -Directory "FILESYSTEM::$CompareWithOldRefDriverPackageFolderPath") -DifferenceObject (Get-ChildItem -Directory "FILESYSTEM::$OutputDirManModelArchDateIMPORTED") -IncludeEqual
    $Diff = Compare-Object -ReferenceObject (Get-ChildItem -Directory "FILESYSTEM::$CompareWithOldRefDriverPackageFolderPath") -DifferenceObject (Get-ChildItem -Directory "FILESYSTEM::$OutputDirManModelArchDateIMPORTED") -IncludeEqual -PassThru
    $DiffGridView | Out-GridView
    

    if ($CopyOldRefDrivers) {
        $Diff | Where-Object -Property SideIndicator -EQ '<=' | % { IF (!(Test-Path "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\OLD")) { New-Item -Path "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\OLD" -ItemType Directory -Force } ; Copy-Item -Path "FILESYSTEM::$($_.FullName)" -Destination "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\OLD" -Recurse }
    }

    if ($SeperateNewDrivers) {
        $Diff | Where-Object -Property SideIndicator -EQ '=>' | % { IF (!(Test-Path "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\NEW")) { New-Item -Path "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\NEW" -ItemType Directory -Force }   ; Move-Item -Path "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\$($_.Name)" -Destination "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\NEW" -Force }
    }
    if ($SeperateSameDrivers) {
        $Diff | Where-Object -Property SideIndicator -EQ '==' | % { IF (!(Test-Path "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\SAME")) { New-Item -Path "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\SAME" -ItemType Directory -Force } ; Move-Item -Path "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\$($_.Name)" -Destination "FILESYSTEM::$OutputDirManModelArchDateIMPORTED\SAME" -Force }
    }
}

if ($CopyToCMDriverSource -and $CMDriverSourceDir ) {
    Copy-Item -Recurse $OutputDirManModelArchDate $CMDriverSourceDir
}

if ($EmailResults) {
    [string]$Body = Get-ChildItem -Path $OutputDirManModelArchDate | Select-Object -Property Name | ConvertTo-Html -Fragment
    Send-MailMessage -SmtpServer 'mailhost.DOMAIN.com' -To $EmailTo -Subject "$($Env:COMPUTERNAME):Export-Drivers:$OSManModelArchDate`:COMPLETE" -From "user@BLM.com" -Body $Body -BodyAsHtml -Attachments $OutputDirManModelArchDateDriverExportCSVFile
}