######## Phil's dev VM boxstarter script ########

###############
#### NOTES ####
###############

## After a restart/reconnect, even though it shows the login screen, boxstarter is still working

### NOTES when kicking off remotely from host to VM, fails on Configuring CredSSP settings
## check http://blogs.technet.com/b/heyscriptingguy/archive/2012/12/30/understanding-powershell-remote-management.aspx

### MISC NOTES
## Boxstarter repeats the _entire_ script after restart. For already-installed packages, Chocolatey will take a couple seconds each to verify. This can get tedious, so consider putting packages that require a reboot near the beginning of the script.
## Boxstarter automatically disables windows update so you don't need to do that at the beginning of the script.
## you still want to Restart or Update and Restart afterwards - and to ensure UAC is enabled

### STATISTICS
## took 1:20 hours on an Azure VM with SSD
## required 4 reboots
## VS 2017 with 2 workloads took 28:23 minutes
## 6 Windows updates took 19:01 minutes

### HACK Workaround choco / boxstarter path too long error
## https://github.com/chocolatey/boxstarter/issues/241
$ChocoCachePath = "$env:USERPROFILE\AppData\Local\Temp\chocolatey"
New-Item -Path $ChocoCachePath -ItemType Directory -Force

$cup = 'choco upgrade --cacheLocation="$ChocoCachePath"'

######################################
#### make sure we're not bothered ####
######################################

Disable-UAC

######################
#### dependencies ####
######################

## NOTE none right now

#########################
#### requires reboot ####
#########################

Invoke-Expression "$cup googlechrome"

Invoke-Expression "$cup visualstudio2019enterprise"
Invoke-Expression "$cup visualstudio2019-workload-netcore"
Invoke-Expression "$cup visualstudio2019-workload-netweb"
Invoke-Expression "$cup visualstudio2019-workload-azure"

#######################
#### general utils ####
#######################

Invoke-Expression "$cup brave"
Invoke-Expression "$cup 7zip.install"
Invoke-Expression "$cup Recuva"

Invoke-Expression "$cup sysinternals"
## NOTE: by default, installs to C:\tools\sysinternals

Invoke-Expression "$cup windirstat"

Invoke-Expression "$cup lockhunter"
## NOTE: opens webpage after install

######################
#### general apps ####
######################

Invoke-Expression "$cup SublimeText3"

Invoke-Expression "$cup keepass.install"

Invoke-Expression "$cup teracopy"

###################
#### dev utils ####
###################

Invoke-Expression "$cup fiddler"

Invoke-Expression "$cup winmerge"

Invoke-Expression "$cup postman"

##################
#### dev apps ####
##################

Invoke-Expression "$cup resharper-ultimate-all"

Invoke-Expression "$cup sql-server-management-studio"

#################################
#### NOW get windows updates ####
#################################

Enable-MicrosoftUpdate
Install-WindowsUpdate -AcceptEula

#################
#### cleanup ####
#################

del C:\eula*.txt
del C:\install.*
del C:\vcredist.*
del C:\vc_red.*

###############################
#### windows configuration ####
###############################

## NOTE do these here so that it only happens once (shouldn't reboot any more at this point)

Enable-RemoteDesktop
Set-StartScreenOptions -EnableBootToDesktop -EnableDesktopBackgroundOnStart -EnableShowStartOnActiveScreen
Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles
TZUTIL /s "Eastern Standard Time"

################################
#### restore disabled stuff ####
################################

Enable-UAC

## TODO figure out how to force a single restart here, but only once (not every time the script runs)

#########################
#### manual installs ####
#########################

## NOTE none right now

###########################
#### optional installs ####
###########################

### general utils
# imgburn
# bulkrenameutility
# mpc-hc
# markdownpad2

# dropbox
## NOTE causes reboot
## NOTE opens UI after restart

### general apps
# Kindle
# skype
# foxitreader

### dev utils
# ilmerge
# ilspy

### sql server
# sql-server-express