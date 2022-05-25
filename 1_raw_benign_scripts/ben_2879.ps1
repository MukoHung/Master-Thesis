# Setting TLS settings to TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy RemoteSigned

# Powershell Version
$PSVersionTable

# Install IIS via PowerShell
Import-Module ServerManager
Install-WindowsFeature -name Web-Server -IncludeManagementTools

# Getting files from a provided link: https://4sysops.com/archives/use-powershell-to-download-a-file-with-http-https-and-ftp/

# Installing PowerShell 7/Core
wget "https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/PowerShell-7.1.3-win-x64.msi" -outfile "PowerShell-7.1.3-win-x64.msi"
msiexec.exe /package PowerShell-7.1.3-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1

# Ensuring that AWS PowerShell tools are installed
wget "https://sdk-for-net.amazonwebservices.com/ps/v4/latest/AWSPowerShell.zip" -outfile "AWSPowerShell.zip"
# Source: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive?view=powershell-7.1
Expand-Archive -LiteralPath AWSPowerShell.zip
msiexec.exe /package PowerShell-7.1.3-win-x64.msi /quiet

# PowerShellGet is installed now?
Get-Module -ListAvailable PowerShellGet

# Enable windows updates
Install-Module PSWindowsUpdate
Import-Module PSWindowsUpdate

# Issues with Windwos not making IISAdministration compatible with Powershell 7 on 2012 R2
# https://github.com/PowerShell/PowerShell/issues/11792

# In order to run IISAdministration in version 1.1.0.0 or via PowerShell 5 tyhen the WMF package needs to be installed
wget "https://go.microsoft.com/fwlink/?linkid=839516" -outfile "Win8.1AndW2K12R2-KB3191564-x64.msu"
# Install WMF 5.1 Now: https://github.com/MicrosoftDocs/PowerShell-Docs/blob/staging/reference/docs-conceptual/windows-powershell/wmf/setup/install-configure.md
.\Win8.1AndW2K12R2-KB3191564-x64.msu /quiet /norestart
# Installing WMF 5.1 requires a reboot. Using the /quiet option alone will reboot the system without warning. Use the /norestart option to avoid rebooting. However, WMF 5.1 will not be installed until you have rebooted.

# Non Directory Windows Update Settings:
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name AUOptions -Value 3

# Install IISAdministration Module
Install-Module IISAdministration
Import-Module IISAdministration

# Creating the new IIS Site
New-IISSite -Name "aws_Challenge_site" -BindingInformation "*:80:" -PhysicalPath "C:\ANCILE"
# Creating a new IIS Site with proper certs as well
# New-IISSite -Name "TestSite" -PhysicalPath "$env:systemdrive\inetpub\testsite" -BindingInformation "*:443:" -CertificateThumbPrint "D043B153FCEFD5011B9C28E186A60B9F13103363" -CertStoreLocation "Cert:\LocalMachine\Webhosting" -Protocol https
