$hostname = "csateng-vpnclient-win10"
$network_interface = "Ethernet0"
$ip_Address = "10.89.49.68"
$subnet_mask = "26"
$default_gateway = "10.89.49.65"
$dns_Servers = "10.89.49.50, 10.89.49.51"
$timezone = "Central Standard Time"

Rename-Computer -NewName $hostname

# Set timezone
Set-TimeZone -Id $timezone 

# Disable Sleep and Hibernation
powercfg.exe -x -monitor-timeout-ac 0
powercfg.exe -x -monitor-timeout-dc 0
powercfg.exe -x -disk-timeout-ac 0
powercfg.exe -x -disk-timeout-dc 0
powercfg.exe -x -standby-timeout-ac 0
powercfg.exe -x -standby-timeout-dc 0
powercfg.exe -x -hibernate-timeout-ac 0
powercfg.exe -x -hibernate-timeout-dc 0
powercfg.exe -h off

# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Set IP and DNS 
New-NetIPAddress –InterfaceAlias $network_interface –IPv4Address $ip_Address –PrefixLength $subnet_mask -DefaultGateway $default_gateway
Set-DnsClientServerAddress -InterfaceAlias $network_interface -ServerAddresses $dns_Servers
Set-NetConnectionProfile -InterfaceAlias $network_interface -NetworkCategory Private

# Download and Run Clean up Script
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
$cleanscript_download = "https://raw.githubusercontent.com/suidroot/WindowsVMBuildScripts/master/CleanWindows10.ps1"
IEX(New-Object Net.WebClient).downloadString($cleanscript_download)

