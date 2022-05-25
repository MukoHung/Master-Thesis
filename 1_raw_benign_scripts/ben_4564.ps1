# WindowsBootstrap
# ----------------
# By default, this script will install Consul and Nomad both in client+server mode to create
# a single node Windows cluster. This script also installs Windows Containers. Would be good
# to have Java and QEMU in here too as optional dependencies for task drivers.

## Don't forget to add a password for the services.

$CONSUL_VERSION = 1.10.1
$NOMAD_VERSION = 1.0.3

$CONSUL_ADDR_LIST = 
$CONSUL_SERVICE_USER_NAME = ".\Administrator"
$CONSUL_SERVICE_USER_PASS = ""
$NOMAD_SERVICE_USER_NAME = $CONSUL_SERVICE_USER_NAME
$NOMAD_SERVICE_USER_PASS = $CONSUL_SERVICE_USER_PASS
$global:IP = $null     #  This gets set once the function exists. Just here for documentation sake.

function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

function Enable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 1
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 1
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been enabled." -ForegroundColor Green
}

function Disable-UserAccessControl {
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000
    Write-Host "User Access Control (UAC) has been disabled." -ForegroundColor Green    
}

function Enable-RemoteDesktop {
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"  
    Write-Host "Remote Desktop Connections have been enabled." -ForegroundColor Green
}

function Get-DefaultIPAddress {
  $defaultIface=Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -ExpandProperty "ifIndex"
  Get-NetIPAddress -InterfaceIndex $defaultIface -AddressFamily IPV4 | Select-Object -ExpandProperty "IPAddress"
}

$global:IP = Get-DefaultIPAddress

function Install-wget {
  Write-Host "Installing wget..." -ForegroundColor Green
  $client = New-Object System.Net.WebClient;
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
  $client.DownloadFile("https://eternallybored.org/misc/wget/1.19.4/64/wget.exe","c:\windows\system32\wget.exe")
}

function Install-nssm {
  Write-Host "Installing nssm..." -ForegroundColor Green
  wget.exe -q --no-check-certificate https://nssm.cc/release/nssm-2.24.zip
  Expand-Archive -path .\nssm-2.24.zip
  Copy .\nssm-2.24\nssm-2.24\win64\nssm.exe C:\Windows\System32
  erase .\nssm-2.24\ -Recurse
  erase .\nssm-2.24.zip
}

function Generate-ConsulConfig {
@"
server = true
bootstrap_expect = 1
retry_join = [`"$CONSUL_ADDR_LIST`"]
bind_addr = "{{ GetDefaultInterfaces | include `"type`" `"ipv4`" | attr `"address`" }}"
client_addr = "0.0.0.0"
datacenter = "dc1"
data_dir = "c:\\consul\\data"
log_level = "DEBUG"
node_name = "$env:computername"
"@ | Out-File -Encoding ASCII -FilePath c:\consul\config\consul.hcl
}

function Install-consul {
  Write-Host "Installing Consul..." -ForegroundColor Green
  mkdir c:\consul\bin -ErrorAction SilentlyContinue;
  mkdir c:\consul\data -ErrorAction SilentlyContinue;
  mkdir c:\consul\logs -ErrorAction SilentlyContinue;
  mkdir c:\consul\config -ErrorAction SilentlyContinue;
  wget.exe -q --no-check-certificate  https://releases.hashicorp.com/consul/$CONSUL_VERSION/consul_$CONSUL_VERSION_windows_amd64.zip
  Expand-Archive -path .\consul_$CONSUL_VERSION_windows_amd64.zip
  copy .\consul_$CONSUL_VERSION_windows_amd64\consul.exe c:\consul\bin
  erase .\consul_$CONSUL_VERSION_windows_amd64.zip
  erase .\consul_$CONSUL_VERSION_windows_amd64 -Recurse
  sc.exe create "Consul" binPath="c:\consul\bin\consul.exe agent -config-dir c:\consul\config" start=auto
  Write-Host "   Adding Consul to Path..." -ForegroundColor Green
  $path = [System.Environment]::GetEnvironmentVariable("Path", "User")
  [System.Environment]::SetEnvironmentVariable("Path", $path + "c:\consul\bin;", "User")
}

function Generate-NomadConfig {
@"
  datacenter = `"dc1`"
  data_dir = `"c:\\nomad\\data`"
  bind_addr = `"$global:IP`"

  server {
    enabled = true
  }

  client {
    enabled = true
  }

  plugin "raw_exec" {
    config {
      enabled = true
    }
  }
"@ | Out-File -Encoding ASCII -FilePath C:\Nomad\config\nomad.hcl
}

function Install-nomad {
  Write-Host "Installing Nomad..." -ForegroundColor Green
  mkdir c:\nomad\bin -ErrorAction SilentlyContinue;
  mkdir c:\nomad\data -ErrorAction SilentlyContinue;
  mkdir c:\nomad\logs -ErrorAction SilentlyContinue;
  mkdir c:\nomad\config -ErrorAction SilentlyContinue;
  wget.exe -q --no-check-certificate https://releases.hashicorp.com/nomad/$NOMAD_VERSION/nomad_$NOMAD_VERSION_windows_amd64.zip
  Expand-Archive -path .\nomad_$NOMAD_VERSION_windows_amd64.zip
  copy .\nomad_$NOMAD_VERSION_windows_amd64\nomad.exe c:\nomad\bin
  erase .\nomad_$NOMAD_VERSION_windows_amd64.zip
  erase .\nomad_$NOMAD_VERSION_windows_amd64 -Recurse
  Write-Host "   Creating Nomad Service..." -ForegroundColor Green
  sc.exe create "Nomad" binPath="c:\nomad\bin\nomad.exe agent -config c:\nomad\config" start=auto
  Write-Host "   Adding Nomad to Path..." -ForegroundColor Green
  $path = [System.Environment]::GetEnvironmentVariable("Path", "User")
  [System.Environment]::SetEnvironmentVariable("Path", $path + "c:\nomad\bin;", "User")
  [System.Environment]::SetEnvironmentVariable("NOMAD_ADDR", "http://${global:IP}:4646", "User")
}

function Install-Docker {
  Write-Host "Installing Docker...  (this will reboot the node)" -ForegroundColor Green
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  Install-Module -Name DockerMsftProvider -Force
  Unregister-PackageSource -ProviderName DockerMsftProvider -Name DockerDefault -Erroraction Ignore
  Register-PackageSource -ProviderName DockerMsftProvider -Name Docker -Location https://download.docker.com/components/engine/windows-server/index.json
  Install-Package -Name docker -ProviderName DockerMsftProvider -Source Docker -Force
  Write-Host "Rebooting the node..." -ForegroundColor Yellow
  Restart-Computer -Force
}

clear

Disable-InternetExplorerESC
Enable-RemoteDesktop 
Install-wget
# Install-nssm
Install-consul
Generate-ConsulConfig
Install-nomad
Generate-NomadConfig
Install-docker
