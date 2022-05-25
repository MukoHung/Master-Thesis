#Runs Script as Admin
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

Start-Sleep 60

powershell -command "& { iwr https://downloads.dell.com/FOLDER05257671M/1/Dell-Precision-Optimizer_6CDFM_WIN_5.1.13_A00.EXE -OutFile C:\Windows\Temp\DellPrecisionOptimizer.EXE }"
Write-Host "Dell Precision Optimizer"
Start-Process C:\Windows\Temp\DellPrecisionOptimizer.EXE /s
Start-Sleep 10
#Dell Precision Optimizer

powershell -command "& { iwr https://downloads.dell.com/FOLDER04691657M/3/Intel-HID-Event-Filter-Driver_779H4_WIN_2.2.1.364_A06.EXE -OutFile C:\Windows\Temp\HIDEventFilterDriver.EXE }"
Write-Host "Intel HID Event Filter Driver"
Start-Process C:\Windows\Temp\HIDEventFilterDriver.EXE /s
Start-Sleep 10
#Intel HID Event Filter Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER04674197M/4/Chipset_Driver_19Y3F_WN32_11.7.0.1054_A01_02.EXE -OutFile C:\Windows\Temp\ChipsetDriver.exe }"
Write-Host "Intel Management Engine Components Installer"
Start-Process C:\Windows\Temp\ChipsetDriver.exe /s
Start-Sleep 10
#Intel Management Engine Components Installer

powershell -command "& { iwr https://downloads.dell.com/FOLDER04724030M/2/Intel-Serial-IO-Driver_RXDJM_WIN_30.100.1725.1_A05.EXE -OutFile C:\Windows\Temp\SerialDriver.EXE }"
Write-Host "Intel Serial IO Driver"
Start-Process C:\Windows\Temp\SerialDriver.EXE /s
Start-Sleep 10
#Intel Serial IO Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER04672052M/1/Intel-Dynamic-Platform-and-Thermal-Framework_D4G6R_WIN_8.3.10207.5567_A09.EXE -OutFile C:\Windows\Temp\DynamicPlatformDriver.EXE }"
Write-Host "Intel Dynamic Platform and Thermal Framework"
Start-Process C:\Windows\Temp\DynamicPlatformDriver.EXE /s
Start-Sleep 10
#Intel Dynamic Platform and Thermal Framework

powershell -command "& { iwr https://downloads.dell.com/FOLDER04309668M/2/Intel-Thunderbolt-Controller-Driver_7X8Y6_WIN_16.3.61.275_A03_01.EXE -OutFile C:\Windows\Temp\ThunderboltControllerDriver.EXE }"
Write-Host "Intel Thunderbolt Controller Driver"
Start-Process C:\Windows\Temp\ThunderboltControllerDriver.EXE /s
Start-Sleep 10
#Intel Thunderbolt Controller Driver <- may get installed once you plug in dock

powershell -command "& { iwr https://downloads.dell.com/FOLDER04001557M/8/Intel-Chipset-Device-Software_HMDR4_WIN_10.1.1.38_A05_06.EXE -OutFile C:\Windows\Temp\ChipsetDeviceSoftwareDriver.EXE }"
Write-Host "Intel Chipset Device Software Driver"
Start-Process C:\Windows\Temp\ChipsetDeviceSoftwareDriver.EXE /s
Start-Sleep 60
#Intel Chipset Device Software Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER05171783M/1/ASMedia-USB-Extended-Host-Controller-Driver_JCDN0_WIN_1.16.54.1_A10.EXE -OutFile C:\Windows\Temp\USBExtendedHostDriver.EXE }"
Write-Host "ASMedia USB Extended Host Controller Driver"
Start-Process C:\Windows\Temp\USBExtendedHostDriver.EXE /s
Start-Sleep 60
#ASMedia USB Extended Host Controller Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER04844504M/1/Docks_Stands_Driver_J5P2D_WN32_2.43.2017.1123_A09.EXE -OutFile C:\Windows\Temp\DocsDriver.EXE }"
Write-Host "Realtek USB GBE Ethernet Controller Driver applicable for TB16/WD15/DS1000 Dock"
Start-Process C:\Windows\Temp\DocsDriver.EXE /s
Start-Sleep 60
#Realtek USB GBE Ethernet Controller Driver applicable for TB16/WD15/DS1000 Dock

powershell -command "& { iwr https://downloads.dell.com/FOLDER04790879M/1/Docks_Stands_Driver_CC1D2_WN32_6.3.9600.132_A08.EXE -OutFile C:\Windows\Temp\DocsDriver2.EXE }"
Write-Host "Realtek USB Audio Driver"
Start-Process C:\Windows\Temp\DocsDriver2.EXE /s
Start-Sleep 60
#Realtek USB Audio Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER04496085M/1/Intel-Rapid-Storage-Technology-Driver-and-Management_66MG5_WIN_15.7.5.1025_A03.EXE -OutFile C:\Windows\Temp\RapidStorageDriver.EXE }"
Write-Host "Intel Rapid Storage Technology Driver and Management Console"
Start-Process C:\Windows\Temp\RapidStorageDriver.EXE /s
Start-Sleep 30
#Intel Rapid Storage Technology Driver and Management Console

powershell -command "& { iwr https://downloads.dell.com/FOLDER04514170M/1/System-Utilities_Application_8MJFN_WN64_2.2.1_A00.EXE -OutFile C:\Windows\Temp\SysUtilitiesAppDriver.EXE }"
Write-Host "Dell Command | Power Manager"
Start-Process C:\Windows\Temp\SysUtilitiesAppDriver.EXE /s
Start-Sleep 10
#Dell Command | Power Manager

powershell -command "& { iwr https://downloads.dell.com/FOLDER04929303M/1/Intel-HD-Graphics_M1P36_WIN_23.20.16.4973_A06.EXE -OutFile C:\Windows\Temp\IntelHDGraphicsDriver.EXE }"
Write-Host "Intel HD Graphics"
Start-Process C:\Windows\Temp\IntelHDGraphicsDriver.EXE /s
Start-Sleep 30
#Intel HD Graphics

powershell -command "& { iwr https://downloads.dell.com/FOLDER04813714M/1/nVIDIA-GeForce-GTX-Quadro-graphic-Driver_YG5MX_WIN_23.21.13.9065_A14.EXE -OutFile C:\Windows\Temp\nVIDIADriver.EXE }"
Write-Host "NVIDIA Driver"
Start-Process C:\Windows\Temp\nVIDIADriver.EXE /s
Start-Sleep 10
#NVIDIA Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER04795647M/1/Intel_TBT3_FW_UPDATE_NVM26_NVNKG_A03_4.26.12.001.exe -OutFile C:\Windows\Temp\ThunderboltFirmwareDriver.EXE }"
Write-Host "Thunderbolt Firmware Update"
Start-Process C:\Windows\Temp\ThunderboltFirmwareDriver.EXE /s
Start-Sleep 40
#Thunderbolt Firmware Update

powershell -command "& { iwr https://downloads.dell.com/FOLDER05267494M/1/Precision_5520_1.12.1.exe -OutFile C:\Windows\Temp\5520BIOS.exe }"
Write-Host "BIOS Update - Restart after this"
Start-Process C:\Windows\Temp\5520BIOS.exe
Start-Sleep 10
#Dell Precision 5520 system BIOS

$RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
set-itemproperty $RunOnceKey "NextRun" 'powershell "& {c:\scripts\psh_updates.ps1}"'
Start-Sleep 10
Restart-Computer
