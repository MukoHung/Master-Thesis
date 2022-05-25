# NUC workstation setup
# VeriTech Solution @ 2015 
# https://veritech.io/
# START http://boxstarter.org/package/nr/url?http://bit.ly/1IMTQcD

# enable reboot
$Boxstarter.RebootOk=$true
$Boxstarter.NoPassword=$false
$Boxstarter.AutoLogin=$true

# PS and win explorer
Update-ExecutionPolicy Unrestricted
Set-ExplorerOptions -showFileExtensions
Enable-RemoteDesktop
Disable-InternetExplorerESC
Disable-UAC
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

if (Test-PendingReboot) { Invoke-Reboot }

# OS updates
Install-WindowsUpdate -AcceptEula
if (Test-PendingReboot) { Invoke-Reboot }

# essential dev tools
choco install git.install -y
choco install notepadplusplus.install -y
choco install procexp -y
choco install conemu -y

# Servers
choco install tomcat -y
choco install nodejs.install -y

# Java tools
choco install eclipse -version 4.5.20150719 -y
choco install androidstudio -y

# VS
choco install visualstudiocode -version 0.5.0.0 - y
#choco install visualstudio2015community -y

# Browsers
choco install google-chrome-x64 -y
choco install firefox -y