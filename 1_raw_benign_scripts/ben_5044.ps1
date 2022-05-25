#Runs Script as Admin
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

Start-Sleep 60

powershell -command "& { iwr https://downloads.dell.com/FOLDER05257671M/2/Dell-Precision-Optimizer_6CDFM_WIN_5.1.13_A00.EXE -OutFile C:\Windows\Temp\DellPrecisionOptimizer.EXE }"
Write-Host "Dell Precision Optimizer"
Start-Process C:\Windows\Temp\DellPrecisionOptimizer.EXE /s
Start-Sleep 10
#Dell Precision Optimizer

powershell -command "& { iwr https://downloads.dell.com/FOLDER04839252M/1/Intel-HID-Event-Filter-Driver_KK611_WIN_2.2.1.369_A07.EXE -OutFile C:\Windows\Temp\HIDEventFilterDriver.EXE }"
Write-Host "Intel HID Event Filter Driver"
Start-Process C:\Windows\Temp\HIDEventFilterDriver.EXE /s
Start-Sleep 10
#Intel HID Event Filter Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER05123083M/6/Intel-Management-Engine-Components-Installer_JJMT9_WIN_1829.12.0.1154_A02.EXE -OutFile C:\Windows\Temp\ChipsetDriver.exe }"
Write-Host "Intel Management Engine Components Installer"
Start-Process C:\Windows\Temp\ChipsetDriver.exe /s
Start-Sleep 10
#Intel Management Engine Components Installer

powershell -command "& { iwr https://downloads.dell.com/FOLDER05014305M/3/Chipset_Driver_C67R4_WN32_30.100.1727.1_A01_01.EXE -OutFile C:\Windows\Temp\SerialDriver.EXE }"
Write-Host "Intel Serial IO Driver"
Start-Process C:\Windows\Temp\SerialDriver.EXE /s
Start-Sleep 10
#Intel Serial IO Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER04952741M/1/Intel-Dynamic-Platform-and-Thermal-Framework_591DK_WIN_8.4.10501.6067_A01.EXE -OutFile C:\Windows\Temp\DynamicPlatformDriver.EXE }"
Write-Host "Intel Dynamic Platform and Thermal Framework"
Start-Process C:\Windows\Temp\DynamicPlatformDriver.EXE /s
Start-Sleep 10
#Intel Dynamic Platform and Thermal Framework

powershell -command "& { iwr https://downloads.dell.com/FOLDER05072473M/4/Intel-Thunderbolt-Controller-Driver_886C9_WIN_17.4.77.400_A10.EXE -OutFile C:\Windows\Temp\ThunderboltControllerDriver.EXE }"
Write-Host "Intel Thunderbolt Controller Driver"
Start-Process C:\Windows\Temp\ThunderboltControllerDriver.EXE /s
Start-Sleep 10
#Intel Thunderbolt Controller Driver <- may get installed once you plug in dock

powershell -command "& { iwr https://downloads.dell.com/FOLDER04836034M/2/Intel-Chipset-Device-Software-Driver_691VF_WIN_10.1.17541.8066_A00.EXE -OutFile C:\Windows\Temp\ChipsetDeviceSoftwareDriver.EXE }"
Write-Host "Intel Chipset Device Software Driver"
Start-Process C:\Windows\Temp\ChipsetDeviceSoftwareDriver.EXE /s
Start-Sleep 60
#Intel Chipset Device Software Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER05316550M/1/ASMedia-USB-Extended-Host-Controller-Driver_XWHJY_WIN_1.16.55.1_A11.EXE -OutFile C:\Windows\Temp\USBExtendedHostDriver.EXE }"
Write-Host "ASMedia USB Extended Host Controller Driver"
Start-Process C:\Windows\Temp\USBExtendedHostDriver.EXE /s
Start-Sleep 60
#ASMedia USB Extended Host Controller Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER05316825M/1/Realtek-USB-GBE-Ethernet-Controller-Driver-applicable_CRFT8_WIN_2.45.2018.1025_A11.EXE -OutFile C:\Windows\Temp\DocsDriver.EXE }"
Write-Host "Realtek USB GBE Ethernet Controller Driver applicable for TB16/WD15/DS1000 Dock"
Start-Process C:\Windows\Temp\DocsDriver.EXE /s
Start-Sleep 60
#Realtek USB GBE Ethernet Controller Driver applicable for TB16/WD15/DS1000 Dock

powershell -command "& { iwr https://downloads.dell.com/FOLDER05348585M/1/Realtek-USB-Audio-Driver_5WNTT_WIN_6.3.9600.197_A11.EXE -OutFile C:\Windows\Temp\DocsDriver2.EXE }"
Write-Host "Realtek USB Audio Driver"
Start-Process C:\Windows\Temp\DocsDriver2.EXE /s
Start-Sleep 60
#Realtek USB Audio Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER05341399M/1/Intel-Rapid-Storage-Technology-F6-Driver_MCVTF_WIN64_16.7.10.1030_A04.EXE -OutFile C:\Windows\Temp\RapidStorageDriver.EXE }"
Write-Host "Intel Rapid Storage Technology Driver and Management Console"
Start-Process C:\Windows\Temp\RapidStorageDriver.EXE /s
Start-Sleep 30
#Intel Rapid Storage Technology Driver and Management Console

#powershell -command "& { iwr https://downloads.dell.com/FOLDER04514170M/1/System-Utilities_Application_8MJFN_WN64_2.2.1_A00.EXE -OutFile C:\Windows\Temp\SysUtilitiesAppDriver.EXE }"
#Write-Host "Dell Command | Power Manager"
#Start-Process C:\Windows\Temp\SysUtilitiesAppDriver.EXE /s
#Start-Sleep 10
#Dell Command | Power Manager

powershell -command "& { iwr https://downloads.dell.com/FOLDER05224772M/2/Intel-UHD-Graphics-630-P630_HFTD6_WIN_24.20.100.6287_A02.EXE -OutFile C:\Windows\Temp\IntelHDGraphicsDriver.EXE }"
Write-Host "Intel HD Graphics"
Start-Process C:\Windows\Temp\IntelHDGraphicsDriver.EXE /s
Start-Sleep 30
#Intel HD Graphics

powershell -command "& { iwr https://downloads.dell.com/FOLDER05021548M/3/nVIDIA-Graphics-Driver_X1N95_WIN_24.21.13.9793_A02_01.EXE -OutFile C:\Windows\Temp\nVIDIADriver.EXE }"
Write-Host "NVIDIA Driver"
Start-Process C:\Windows\Temp\nVIDIADriver.EXE /s
Start-Sleep 10
#NVIDIA Driver

powershell -command "& { iwr https://downloads.dell.com/FOLDER04891169M/1/ThunderboltFirmwareUpdate64_4.33.23.002.exe -OutFile C:\Windows\Temp\ThunderboltFirmwareDriver.EXE }"
Write-Host "Thunderbolt Firmware Update"
Start-Process C:\Windows\Temp\ThunderboltFirmwareDriver.EXE /s
Start-Sleep 40
#Thunderbolt Firmware Update

powershell -command "& { iwr https://downloads.dell.com/FOLDER05385691M/1/Precision_5530_01_07_00.exe -OutFile C:\Windows\Temp\5530BIOS.exe }"
Write-Host "BIOS Update - Restart after this"
Start-Process C:\Windows\Temp\5530BIOS.exe
Start-Sleep 10
#Dell Precision 5520 system BIOS


$RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
set-itemproperty $RunOnceKey "NextRun" 'powershell "& {c:\scripts\psh_updates.ps1}"'
Start-Sleep 10
Restart-Computer
