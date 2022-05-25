#  START http://boxstarter.org/package/nr/url?https://gist.githubusercontent.com/duanenewman/1a71fae24da1e64df14113c9de8f2ade/raw/d2837a391dc24e186262ff1f505911ced6066e51/BoxStarterScript.ps1
# 

# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot


#### .NET 3.5 ####

choco install dotnet3.5 # Not automatically installed. Includes .NET 2.0. Uses Windows Features to install.
if (Test-PendingReboot) { Invoke-Reboot }

#### WINDOWS SETTTINGS #####

# Basic setup
Update-ExecutionPolicy Unrestricted
Set-ExplorerOptions -showFileExtensions
#Enable-RemoteDesktop
#Disable-InternetExplorerESC
#Disable-UAC
#Set-TaskbarSmall

# disable defrag because I have an SSD
Get-ScheduledTask -TaskName *defrag* | Disable-ScheduledTask

################################# POWER SETTINGS #################################

# Turn off hibernation
# powercfg /H OFF

# Change Power saving options (ac=plugged in dc=battery)
powercfg -change -monitor-timeout-ac 0
powercfg -change -monitor-timeout-dc 15
powercfg -change -standby-timeout-ac 0
powercfg -change -standby-timeout-dc 30
powercfg -change -disk-timeout-ac 0
powercfg -change -disk-timeout-dc 30
powercfg -change -hibernate-timeout-ac 0

## When docked - Make sure that when I close the lid of my laptop it doesn't go to sleep

# retrieve the current power mode Guid
$guid = (Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -Filter "isActive='true'").InstanceID.tostring() 
$regex = [regex]"{(.*?)}$" 
$guidVal = $regex.Match($guid).groups[1].value #$regex.Match($guid) 
# Write-Host $guidVal
# Set close the lid power option to 'Do Nothing' for plugged in.
powercfg -SETACVALUEINDEX $guidVal 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
#To see what other options are available - run the following:
# powercfg -Q $guidVal

################################# SOFTWARE #######################################


# install apps

choco install dropbox
choco install googlechrome

choco install Office365HomePremium
choco install filezilla
choco install winscp.install
choco install adobe-creative-cloud
choco install autodesk-fusion360
choco install vlc
choco install sysinternals
choco install lastpass

choco install git.install
choco install git-credential-manager-for-windows
choco install nuget.commandline
choco install pscx
choco install poshgit

choco install VisualStudioCode
choco install notepadplusplus
choco install postman
choco install ilspy
#choco install sourcetree
choco install beyondcompare
choco install linqpad5
#choco install projectmyscreen
#choco install mobizen

choco install visualstudio2017enterprise --package-parameters "--add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetCoreTools --add Microsoft.VisualStudio.Workload.NetCrossPlat --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.Universal --includeRecommended --passive --locale en-US"
if (Test-PendingReboot) { Invoke-Reboot }

choco install resharper
choco install Wix35

#choco install you-need-a-budget
#choco install Quicktime
#choco install skype

choco install paint.net
choco install slack

choco install teamviewer
choco install InkScape
choco install putty.install
choco install steam
choco install keepass
choco install spotify
choco install 7zip
choco install windirstat
#choco install lastpass-for-applications

#todo: setup default powershell profile to include import of newman.psm1




# Update Windows and reboot if necessary
Install-WindowsUpdate -AcceptEula -GetUpdatesFromMS
if (Test-PendingReboot) { Invoke-Reboot }

