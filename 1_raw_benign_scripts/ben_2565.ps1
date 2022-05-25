Summary
----
PowerShell script to create OS Base VHD for Windows 8/Windows Server2012 Hyper-V.

Note
----
Applying WIM image and offline patch operation take long times.
Please check VirusScan engine don't waste power of CPU or DiskIO.

It is recommend to exclude policy DISM exectable(DISM.exe/DismHost.exe), and work directory.
In case of WindowsDefender, it's about 2x faster if exclude policy setted.

Usage
----
Create OS VHD from template

``` powershell
#Requires –Version 3
#Requires –Modules PShould

param(
    [int]$index
)

Import-Module PShould
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$params=[ordered]@{
   VhdPath      = ""
   OsImageName  = ""
   MediaPath    = ""
   VhdConfig    =  [ordered]@{
       VhdSize  = 32GB           #Default: 127GB (Windows Server2012 Minimum:32GB)
       VhdType  = "Dynamic"      #Default: Dynamic
       VhdBlockSize = 2MB        #Default: 2 MB - Max 256MB (Fixed VHD always 0MB? parameter ignored)
       PartitionStyle = "MBR"    #Hyper-V Only MBR Support?
       AllocationUnitSize = 64KB  #Default: 4KB (Max 64KB)
       CreateReservedPartition = $true
   }
   DismConfig = [ordered]@{
       Culture ="ja-JP"
       PackagePath="" 
       UnAttendXmlPath = ""
       Source = ""
       ProductKey=""
       FeatureName=""
   }
   OptimizeVHD = $false
   ReadOnly = $true
}

$osList = [ordered]@{
    1 = "Windows 8 Enterprise Evaluate"
    2 = "Windows Server 2012 Standard"
    3 = "Windows Server 2012 Standard ServerCore(MinGUI)"
}

if($index -eq 0)
{
    Write-Host "Select OS index from following list..."
    Write-Host "-----------------------------------------------"
    foreach($os in $osList.GetEnumerator())
    {
        Write-Host ("`t{0}: {1}" -f $os.Name,$os.Value)
    }
    Write-Host "-----------------------------------------------"
    $index = [int](Read-Host -Prompt "OS Index")
}

$osName = $osList.Item([object]$index)

switch($index)
{
    1 {
        Write-Host "Selected OS: $osName"  #Windows 8 Enterprise Evaluate
        $params.OsImageName ="Windows 8 Enterprise Evaluation"
        $params.VhdPath     = Join-Path (Get-VMHost).VirtualHardDiskPath  "Windows8_Enterprise.vhdx"
        $params.MediaPath   = "D:\Shared\Images\9200.16384.WIN8_RTM.120725-1247_X64FRE_ENTERPRISE_EVAL_JA-JP-HRM_CENA_X64FREE_JA-JP_DV5.ISO"
        $params.DismConfig.PackagePath     = "\\172.16.0.1\Shared\Images\Windows8\WindowsUpdate"
        $params.DismConfig.UnAttendXmlPath = "\\172.16.0.1\Shared\Images\UnattendXml\Unattend_Win8.xml"
    }
    2{ 
        Write-Host "Selected OS: $osName" # Windows Server 2012 Standard
        $params.OsImageName ="Windows Server 2012 SERVERSTANDARD"
        $params.VhdPath     =  Join-Path (Get-VMHost).VirtualHardDiskPath  "WinSvr2012_Std.vhdx"
        $params.MediaPath   = "D:\Shared\Images\9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_JA-JP-HRM_SSS_X64FREE_JA-JP_DV5.iso"
        $params.DismConfig.PackagePath     = "\\172.16.0.1\Shared\Images\WindowsServer2012\WindowsUpdate"
        $params.DismConfig.UnAttendXmlPath = "\\172.16.0.1\Shared\Images\UnattendXml\Unattend_WinSvr2012.xml"
    }
    3{
        Write-Host "Selected OS: $osName" #Windows Server 2012 Standard ServerCore(MinGUI)
        $params.OsImageName ="Windows Server 2012 SERVERSTANDARDCORE"
        $params.VhdPath     = Join-Path (Get-VMHost).VirtualHardDiskPath  "WinSvr2012_Std_MinGUI.vhdx"
        $params.MediaPath   = "D:\Shared\Images\9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_JA-JP-HRM_SSS_X64FREE_JA-JP_DV5.iso"
        $params.DismConfig.PackagePath     = "\\172.16.0.1\Shared\Images\WindowsServer2012\WindowsUpdate"
        $params.DismConfig.UnAttendXmlPath = "\\172.16.0.1\Shared\Images\UnattendXml\Unattend_WinSvr2012.xml"
        $params.DismConfig.Source          = "\\172.16.0.1\Shared\Images\WindowsServer2012\WinSxs"
        $params.DismConfig.FeatureName     = "Server-Gui-Mgmt"
    }
    default{
        throw "Not Supported OS Selected!"
    }
}

#region parameter assertion
$params.MediaPath                  | should exist
$params.DismConfig.UnAttendXmlPath | should exist
if(![String]::IsNullOrEmpty($params.DismConfig.PackagePath)){
    $params.DismConfig.PackagePath | should exist
}
if(![String]::IsNullOrEmpty($params.DismConfig.Source)){
    $params.DismConfig.Source | should exist
}
#endregion 

$sw = [Diagnostics.Stopwatch]::StartNew()
New-OSBaseImage @params -Verbose -Debug -Force
Write-Host ("Elapsed {0} [minutes]." -f $sw.Elapsed.TotalMinutes)
```

Unattend.xml for Windows Server 2012
---

``` xml
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="generalize">
        <component name="Microsoft-Windows-Security-SPP" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SkipRearm>1</SkipRearm>
        </component>
    </settings>
    <settings pass="specialize">
		<component name="Microsoft-Windows-Security-SPP-UX" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SkipAutoActivation>true</SkipAutoActivation>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName>*</ComputerName>
        </component>
        <component name="Microsoft-Windows-UnattendedJoin" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Identification>
                <JoinWorkgroup>WORKGROUP</JoinWorkgroup>
            </Identification>
        </component>
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ExtendOSPartition>
                <Extend>true</Extend>
            </ExtendOSPartition>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
 			<AutoLogon>
                <Enabled>true</Enabled>
                <LogonCount>1</LogonCount>
                <Username>Administrator</Username>
				<Password>
					<Value>Password!</Value>
                    <PlainText>true</PlainText>
				</Password>
            </AutoLogon>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>Password!</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <TimeZone>Tokyo Standard Time</TimeZone>
            <OOBE>
				<ProtectYourPC>1</ProtectYourPC>
                <HideEULAPage>true</HideEULAPage>
                <SkipUserOOBE>true</SkipUserOOBE>
            </OOBE>
        </component>
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>0411:00000411</InputLocale>
            <SystemLocale>ja-JP</SystemLocale>
            <UILanguage>ja-JP</UILanguage>
            <UserLocale>ja-JP</UserLocale>
        </component>
    </settings>
</unattend>
```

Unattend.xml for Windows 8
---
*Note: WinRM for local administrator enabled *
``` xml
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="generalize">
        <component name="Microsoft-Windows-Security-SPP" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SkipRearm>1</SkipRearm>
        </component>
    </settings>
    <settings pass="specialize">
		<component name="Microsoft-Windows-Security-SPP-UX" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SkipAutoActivation>true</SkipAutoActivation>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName>*</ComputerName>
        </component>
        <component name="Microsoft-Windows-UnattendedJoin" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Identification>
                <JoinWorkgroup>WORKGROUP</JoinWorkgroup>
            </Identification>
        </component>
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ExtendOSPartition>
                <Extend>true</Extend>
            </ExtendOSPartition> 
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<AutoLogon>
                <Enabled>true</Enabled>
                <LogonCount>1</LogonCount>
                <Username>Administrator</Username>
				<Password>
					<Value>Password!</Value>
                    <PlainText>true</PlainText>
				</Password>
            </AutoLogon>
			<UserAccounts>
				<LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Group>Administrators</Group>
                        <Name>Administrator</Name>
                    </LocalAccount>
                </LocalAccounts>
				<AdministratorPassword>
                    <Value>Password!</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <TimeZone>Tokyo Standard Time</TimeZone>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
				<HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
				<NetworkLocation>Work</NetworkLocation>
                <ProtectYourPC>1</ProtectYourPC>
                <SkipUserOOBE>true</SkipUserOOBE>
				<HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
            </OOBE>
			<FirstLogonCommands>
				<SynchronousCommand wcm:action="add">
					<Order>1</Order>
                    <CommandLine>powershell -Command &quot;Enable-PSRemoting -Force&quot;</CommandLine>
                    <RequiresUserInput>false</RequiresUserInput>
			   </SynchronousCommand>
			</FirstLogonCommands>
        </component>
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>0411:00000411</InputLocale>
            <SystemLocale>ja-JP</SystemLocale>
            <UILanguage>ja-JP</UILanguage>
            <UserLocale>ja-JP</UserLocale>
        </component>
    </settings>
</unattend>
```
