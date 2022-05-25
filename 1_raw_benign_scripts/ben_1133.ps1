# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

# Basic setup
Update-ExecutionPolicy Unrestricted
Set-ExplorerOptions -showFileExtensions
#Enable-RemoteDesktop
#Disable-InternetExplorerESC
Disable-UAC
#Set-TaskbarSmall
Enable-MicrosoftUpdate

if (Test-PendingReboot) { Invoke-Reboot }

# Update Windows and reboot if necessary
Install-WindowsUpdate -AcceptEula
if (Test-PendingReboot) { Invoke-Reboot }

# Install Visual Studio 2013 Professional 
#cinst VisualStudio2013Professional -InstallArguments WebTools
#if (Test-PendingReboot) { Invoke-Reboot }
#
# Visual Studio SDK required for PoshTools extension
#cinst VS2013SDK
#if (Test-PendingReboot) { Invoke-Reboot }

cinst DotNet3.5 # Not automatically installed with VS 2013. Includes .NET 2.0. Uses Windows Features to install.
if (Test-PendingReboot) { Invoke-Reboot }

# VS extensions
#Install-ChocolateyVsixPackage PowerShellTools http://visualstudiogallery.msdn.microsoft.com/c9eb3ba8-0c59-4944-9a62-6eee37294597/file/112013/6/PowerShellTools.vsix
#Install-ChocolateyVsixPackage WebEssentials2013 http://visualstudiogallery.msdn.microsoft.com/56633663-6799-41d7-9df7-0f2a504ca361/file/105627/31/WebEssentials2013.vsix
#Install-ChocolateyVsixPackage T4Toolbox http://visualstudiogallery.msdn.microsoft.com/791817a4-eb9a-4000-9c85-972cc60fd5aa/file/116854/1/T4Toolbox.12.vsix
#Install-ChocolateyVsixPackage StopOnFirstBuildError http://visualstudiogallery.msdn.microsoft.com/91aaa139-5d3c-43a7-b39f-369196a84fa5/file/44205/3/StopOnFirstBuildError.vsix

# AWS Toolkit is now an MSI available here http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi (no chocolatey package as of FEB 2014)
# Install-ChocolateyVsixPackage AwsToolkit http://visualstudiogallery.msdn.microsoft.com/175787af-a563-4306-957b-686b4ee9b497

#Other dev tools
#cinst fiddler4
#cinst beyondcompare
cinst sysinternals
#cinst NugetPackageExplorer
#cinst windbg
#cinst Devbox-Clink
cinst TortoiseHg
#cinst VisualHG # Chocolatey package is corrupt as of Feb 2014 
#cinst linqpad4
#cinst TestDriven.Net
#cinst ncrunch2.vs2013
cinst notepadplusplus.install
#cinst nodejs.install
cinst visualstudiocode
cinst resharper-platform

#Browsers
cinst googlechrome
cinst firefox

#Other essential tools
cinst 7zip
cinst adobereader
cinst jdk8
cinst skype
cinst putty
cinst dropbox
cinst teamviewer
cinst winscp
#cinst cmder
cinst googledrive
cinst logparser
cinst markdownpad2
#cinst mssqlservermanagementstudio2014express
cinst stylecop
#cinst vmwarevsphereclient -version 5.5.0
#cinst cdburnerxp
#cinst autohotkey
#cinst gmvault
cinst pdfcreator
cinst lastpass
#cinst r.studio
#cinst ultravnc
#cinst balsamiqmockups3
#cinst calibre




# Arduino
#cinst arduino
#cinst fritzing

# App
#cinst handbrake
#cinst makemkv
#cinst plexmediaserver
#cinst r.studio
#cinst crashplan
#cinst steam


#cinst Microsoft-Hyper-V-All -source windowsFeatures
#cinst IIS-WebServerRole -source windowsfeatures
#cinst IIS-HttpCompressionDynamic -source windowsfeatures
#cinst IIS-ManagementScriptingTools -source windowsfeatures
#cinst IIS-WindowsAuthentication -source windowsfeatures

Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
#Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"

Enable-UAC