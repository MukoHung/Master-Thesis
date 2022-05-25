<powershell>
$domain = "${ad_domain}"
$password = "${joiner_pw}" | ConvertTo-SecureString -asPlainText -Force
$username = "${ad_shortname}\${joiner_account}" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
$puppet_master_server = "${puppet_server}"
$puppet_agent_environment = "${puppet_env}"
$puppet_role = "${role}"


# Join to Domain
#Rename-Computer "${hostname}"
#Sleep 15
Add-Computer -DomainName "$domain" -NewName "${hostname}" -Credential $credential

# Install Puppet
$MsiUrl = "https://downloads.puppetlabs.com/windows/puppet-agent-x86-latest.msi"

$PuppetInstalled = $false
try {
  $ErrorActionPreference = "Stop";
  Get-Command puppet | Out-Null
  $PuppetInstalled = $true
  $PuppetVersion=&puppet "--version"
  Write-Host "Puppet $PuppetVersion is installed. This process does not ensure the exact version or at least version specified, but only that puppet is installed. Exiting..."
  Exit 0
} catch {
  Write-Host "Puppet is not installed, continuing..."
}

if (!($PuppetInstalled)) {
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if (! ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host -ForegroundColor Red "You must run this script as an administrator."
    Exit 1
  }

  # Install it - msiexec will download from the url
  $install_args = @("/qn", "/norestart","/i", $MsiUrl,"PUPPET_MASTER_SERVER=$puppet_master_server", "PUPPET_AGENT_ENVIRONMENT=$puppet_agent_environment")
  Write-Host "Installing Puppet. Running msiexec.exe $install_args"
  $process = Start-Process -FilePath msiexec.exe -ArgumentList $install_args -Wait -PassThru
  if ($process.ExitCode -ne 0) {
    Write-Host "Installer failed."
    Exit 1
  }

  # Stop the service that it autostarts
  Write-Host "Stopping Puppet service that is running by default..."
  Start-Sleep -s 5
  Stop-Service -Name puppet

  Write-Host "Puppet successfully installed."
}

"extension_requests:
    pp_role: ${role}" > C:/ProgramData/PuppetLabs/puppet/etc/csr_attributes.yaml

Restart-Computer

</powershell>
<powershellArguments>-ExecutionPolicy unrestricted -NoProfile -NonInteractive</powershellArguments> 
<runAsLocalSystem>true</runAsLocalSystem>
<persist>true</persist>
