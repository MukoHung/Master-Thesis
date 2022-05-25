[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$wc = New-Object System.Net.WebClient

if (!(Test-Path "C:\Tools")) {
    New-Item -Path "C:\" -Name "Tools" -ItemType "directory"
}

# SYSMON
# Download Sysmon
$SysmonDirectory = "C:\Tools\Sysmon\"

$SysmonLocalZip = "C:\Tools\Sysmon.zip"
$SysmonURL = "https://download.sysinternals.com/files/Sysmon.zip"

if (!(Test-Path $SysmonLocalZip)) {
    $wc.DownloadFile($SysmonURL, $SysmonLocalZip)
    Expand-Archive -LiteralPath $SysmonLocalZip -DestinationPath $SysmonDirectory
}

# Download Sysmon SwiftOnSecurity Config
$SysmonLocalConfig = $SysmonDirectory + "sysmon-config.xml"
$SysmonConfigURL = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"

if (!(Test-Path $SysmonLocalConfig)) {
    $wc.DownloadFile($SysmonConfigURL, $SysmonLocalConfig)
}

# Execute Sysmon
$ServiceName = 'Sysmon'
$SysmonService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($SysmonService.Status -ne 'Running')
{
    $SysmonExe = $SysmonDirectory + "Sysmon.exe"
    & $SysmonExe -i $SysmonLocalConfig -accepteula 
}

# SilkService
$SilkServiceURL = "https://github.com/fireeye/SilkETW/releases/download/v0.8/SilkETW_SilkService_v8.zip"
$SilkServiceLocalZip = "C:\Tools\SilkService.zip"
$SilkServiceDirectory = "C:\Tools\SilkService"

if (!(Test-Path $SilkServiceLocalZip)) {
    $wc.DownloadFile($SilkServiceURL, $SilkServiceLocalZip)
    Expand-Archive -LiteralPath $SilkServiceLocalZip -DestinationPath $SilkServiceDirectory
}

$DotNetInstaller = $SilkServiceDirectory + "\v8\Dependencies\dotNetFx45_Full_setup.exe"
$vc2015Installer = $SilkServiceDirectory + "\v8\Dependencies\vc2015_redist.x86.exe"

& $DotNetInstaller /SILENT
& $vc2015Installer /SILENT

$SilkServiceConfigLocation = $SilkServiceDirectory + "\v8\SilkService\SilkServiceConfig.xml"
$SilkServiceConfig = @"
<!--
  SilkService Config
  Author:   Roberto Rodriguez (@Cyb3rWard0g)
  License:  GPL-3.0
  Version:  0.0.1
  References:   https://github.com/Cyb3rWard0g/mordor/blob/master/environments/windows/configs/erebor/erebor_SilkServiceConfig.xml
-->
<SilkServiceConfig>
    <!--
        Microsoft-Windows-LDAP-Client ETW Provider
    -->
    <ETWCollector>
        <Guid>859efb51-6985-480f-8094-77192b2a7407</Guid>
        <CollectorType>user</CollectorType>
        <ProviderName>099614a5-5dd7-4788-8bc9-e29f43db28fc</ProviderName>
        <UserKeywords>0x1</UserKeywords><!--Search-->
        <OutputType>eventlog</OutputType>
    </ETWCollector>
    <!--
        Microsoft-Windows-Crypto-DPAPI ETW Provider
    -->
    <ETWCollector>
        <Guid>df7461c7-7c11-4429-806f-a6ec34d08c0c</Guid>
        <CollectorType>user</CollectorType>
        <ProviderName>89fe8f40-cdce-464e-8217-15ef97d4c7c3</ProviderName>
        <UserKeywords>0xa</UserKeywords><!--ETW_TASK_MASTERKEY_OPERATION,ETW_TASK_CREDKEY_OPERATION-->
        <OutputType>eventlog</OutputType>
    </ETWCollector>
    <!--
        Microsoft-Windows-DNS-Client ETW Provider
    -->
    <ETWCollector>
        <Guid>c96e5920-f384-49b7-be43-2b408b4f0d75</Guid>
        <CollectorType>user</CollectorType>
        <ProviderName>1c95126e-7eea-49a9-a3fe-a378b03ddb4d</ProviderName>
        <OutputType>eventlog</OutputType>
    </ETWCollector>
    <!--
        Microsoft-Windows-DotNETRuntime ETW Provider
    -->
    <ETWCollector>
        <Guid>072e0373-213b-4e3d-881a-6430d6d9e369</Guid>
        <CollectorType>user</CollectorType>
        <ProviderName>e13c0d23-ccbc-4e12-931b-d9cc2eee27e4</ProviderName>
        <UserKeywords>0x2038</UserKeywords><!--Loader,Jit,NGen,Interop"-->
        <OutputType>eventlog</OutputType>
    </ETWCollector>
    <!--
        Microsoft-Windows-SMBServer ETW Provider
    -->
    <ETWCollector>
        <Guid>f7569862-691a-4a38-9f0e-e3ed815920ba</Guid>
        <CollectorType>user</CollectorType>
        <ProviderName>D48CE617-33A2-4BC3-A5C7-11AA4F29619E</ProviderName>
        <UserKeywords>0x9</UserKeywords><!--Request,Operational"-->
        <OutputType>eventlog</OutputType>
    </ETWCollector>
    <!--
        Microsoft-Windows-WMI-Activity ETW Provider
    -->
    <ETWCollector>
        <Guid>e58efae6-883b-4a05-95b5-ec2f697b2dc5</Guid>
        <CollectorType>user</CollectorType>
        <ProviderName>1418ef04-b0b4-4623-bf7e-d74ab47bbdaa</ProviderName>
        <OutputType>eventlog</OutputType>
    </ETWCollector>
    <!--
        Microsoft-Windows-TCPIP ETW Provider
    -->
    <ETWCollector>
        <Guid>e58efae6-883b-4aaa-95b5-ec2f697b2dc5</Guid>
        <CollectorType>user</CollectorType>
        <ProviderName>2F07E2EE-15DB-40F1-90EF-9D7BA282188A</ProviderName>
        <OutputType>eventlog</OutputType>
    </ETWCollector>
    <!--
        This is a kernel collector (ImageLoad)
    -->
    <ETWCollector>
        <Guid>870b50e1-04c2-43e4-82ac-817444a56364</Guid>
        <CollectorType>kernel</CollectorType>
        <KernelKeywords>ImageLoad</KernelKeywords>
        <FilterValue>Image/Load</FilterValue>
        <OutputType>eventlog</OutputType>
    </ETWCollector>
</SilkServiceConfig>
"@

if (!(Test-Path $SilkServiceConfigLocation)) {
    Set-Content -Path $SilkServiceConfigLocation -Value $SilkServiceConfig
}

$SilkService = Get-Service -Name "SilkService" -ErrorAction SilentlyContinue

if ($SilkService.Status -ne 'Running')
{
    $params = @{
    Name = "SilkService"
    BinaryPathName = "C:\Tools\SilkService\v8\SilkService\SilkService.exe"
    DependsOn  = "NetLogon"
    DisplayName = "SilkETW Service"
    StartupType = "Automatic"
    Description = "SilkService."
    }
    New-Service @params
}


# WINLOGBEAT
# https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_87.html

# Download Winlogbeat

$WinlogbeatDirectory = "C:\Tools\Winlogbeat\"
$WinlogbeatLocalZip = "C:\Tools\Winlogbeat.zip"
$WinlogbeatURL = "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.6.2-windows-x86_64.zip"

$WinlogbeatLocalConfigLocation = "C:\Program Files\Winlogbeat\winlogbeat-7.6.2-windows-x86_64\winlogbeat.yml"

$WinlogbeatLocalConfig = @"
#======================= Winlogbeat specific options ==========================
winlogbeat.event_logs:
  - name: Application
    ignore_older: 30m
  - name: Security
    ignore_older: 30m
  - name: System
    ignore_older: 30m
  - name: Microsoft-windows-sysmon/operational
    ignore_older: 30m
  - name: Microsoft-windows-PowerShell/Operational
    ignore_older: 30m
    event_id: 4103, 4104
  - name: Windows PowerShell
    event_id: 400,600
    ignore_older: 30m
  - name: Microsoft-Windows-WMI-Activity/Operational
    event_id: 5857,5858,5859,5860,5861
  - name: SilkService-Log
    ignore_older: 72h

#----------------------------- Kafka output --------------------------------
output.kafka:
  hosts: ["<HELK-IP>:9092","<HELK-IP>:9093"]
  topic: "winlogbeat"
  ############################# HELK Optimizing Latency ######################
  max_retries: 2
  max_message_bytes: 1000000
"@

if (!(Test-Path $WinlogbeatLocalZip)) {
    $wc.DownloadFile($WinlogbeatURL, $WinlogbeatLocalZip)
    Expand-Archive -LiteralPath $WinlogbeatLocalZip -DestinationPath $WinlogbeatDirectory

    Move-Item -Path $WinlogbeatDirectory.TrimEnd('/') -Destination "C:\Program Files\" -Force

    Push-Location "C:\Program Files\Winlogbeat\winlogbeat-7.6.2-windows-x86_64"

    # Install Winlogbeat service
    .\install-service-winlogbeat.ps1

    Pop-Location

    Remove-Item -Path $WinlogbeatLocalConfigLocation -Force

    Set-Content -Path $WinlogbeatLocalConfigLocation -Value $WinlogbeatLocalConfig

    $stringToFind = '\["<HELK-IP>:9092","<HELK-IP>:9093"\]'
    $stringToReplace = '["' + $env:HELK_IP + ':9092"]'
    ((Get-Content -path $WinlogbeatLocalConfigLocation) -replace $stringToFind,$stringToReplace) | Set-Content -Path $WinlogbeatLocalConfigLocation

    Start-Service Winlogbeat
}