$ResourceGroupName = "RG-TFE-Development" 

$vmname = "winvm01"



# Invoke-AzVMRunCommand -ResourceGroupName '<myResourceGroup>' `
#         -Name '<myVMName>' -CommandId 'RunPowerShellScript' `
#         -ScriptPath '<pathToScript>' `
#         -Parameter @{"arg1" = "var1";"arg2" = "var2"}

# Run Powershell to configure Windows for Ansible management

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
Invoke-WebRequest -Uri $url -OutFile "ConfigureRemotingForAnsible.ps1"
Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $vmname `
    -CommandId 'RunPowerShellScript' -ScriptPath "ConfigureRemotingForAnsible.ps1"



#Adding FW Rule Minim Requirement
$remoteCommand = @'
# Update Firewall Rule to Allow SQLg
New-NetFirewallRule -DisplayName "Allow WinRM HTTP" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow

$selector_set = @{
    Address = "*"
    Transport = "HTTPS"
}
$value_set = @{
    CertificateThumbprint = "E6CDAA82EEAF2ECE8546E05DB7F3E01AA47D76CE"
}

New-WSManInstance -ResourceURI "winrm/config/Listener" -SelectorSet $selector_set -ValueSet $value_set


'@
# Save the command to a local file
Set-Content -Path .\Command.ps1 -Value $remoteCommand
# Invoke the command on the VM, using the local file
Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $vmname `
    -CommandId 'RunPowerShellScript' -ScriptPath .\Command.ps1
# Clean-up the local file
Remove-Item .\Command.ps1






# Same Advance SCripts 
$remoteCommand = @'
New-Item -Path "c:\" -Name "logfiles" -ItemType "directory"
New-Item -Path "c:\" -Name "Download" -ItemType "directory"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome -y
choco install powershell-core --pre -y

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
Invoke-WebRequest -Uri $url -OutFile "c:\Download\ConfigureRemotingForAnsible.ps1"

$url = 'https://download.microsoft.com/download/1/a/a/1aaa9177-3578-4931-b8f3-373b24f63342/SQLServerReportingServices.exe'
Invoke-WebRequest -Uri $url -OutFile "c:\Download\SQLServerReportingServices.exe"

# $url = "https://download.microsoft.com/download/7/f/8/7f8a9c43-8c8a-4f7c-9f92-83c18d96b681/SQL2019-SSEI-Expr.exe"
# Invoke-WebRequest -Uri $url -OutFile "c:\Download\SQL2019-SSEI-Expr.exe"
# msiexec /a c:\Download\SQL2019-SSEI-Expr.exe /qb TARGETDIR=c:\temp\test
# Extracting SQL EXPRESSS
# c:\Download\SQL2019-SSEI-Expr.exe /ACTION=Download MEDIAPATH=C:\Download /MEDIATYPE=Core /QUIET


# Update Firewall Rule to Allow SQLg
New-NetFirewallRule -DisplayName "SQLServer default instance" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "SQLServer Browser service" -Direction Inbound -LocalPort 1434 -Protocol UDP -Action Allow


# Download SQL 2019 DEV
$url= "https://go.microsoft.com/fwlink/?linkid=866662"
Invoke-WebRequest -Uri $url -OutFile "c:\Download\SQL2019-SSEI-Dev.exe"
# Extract SQL 2019 DEV
c:\Download\SQL2019-SSEI-Dev.exe /ACTION=Download MEDIAPATH=C:\Downloads /MEDIATYPE=CAB /QUIET
c:\Download\SQLEXPR_x64_ENU.exe /q /x:C:\Downloads\SQLEXPR_2019



.\SQL2019-SSEI-Dev.exe /ACTION=Download MEDIAPATH=C:\Downloads /MEDIATYPE=CAB /QUIET
# SSMS automated install https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?redirectedfrom=MSDN&view=sql-server-ver15#unattended-install


$url = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/PowerShell-7.1.3-win-x64.msi"
Invoke-WebRequest -Uri $url -OutFile "c:\Download\PowerShell-7.1.3-win-x64.msi"
msiexec.exe /package "c:\Download\PowerShell-7.1.3-win-x64.msi" /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1


$ SSMS SQL
$url = "https://aka.ms/ssmsfullsetup"

Add-WindowsFeature RSAT-Clustering-PowerShell

# Install Failover Cluster
$check = Get-WindowsFeature -Name Failover-Clustering
if (! $check.Installed ){
    Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools
}

## Configure DNS
$netconfig = Get-NetIPConfiguration 
if (! $netconfig.DNSServer.ServerAddresses.contains("10.1.0.5") ){
    $currentconfig = Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | ? {$_.ServerAddresses -eq "168.63.129.16"}
    Set-DnsClientServerAddress -InterfaceIndex $currentconfig.InterfaceIndex -ServerAddresses 10.1.0.5, 168.63.129.16
}



'@

# Save the command to a local file
Set-Content -Path .\Command.ps1 -Value $remoteCommand
# Invoke the command on the VM, using the local file
Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $vmname `
    -CommandId 'RunPowerShellScript' -ScriptPath .\Command.ps1
# Clean-up the local file
Remove-Item .\Command.ps1