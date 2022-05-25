<#
.SYNOPSIS
    Re-image Post-Install Script 
    Author: Patrick Hufford (angryhussord@outlook.com)
.DESCRIPTION
    After re-installing Windows, this will install chocolatey, install packages, then install custom packages that Chocolatey cannot/does not support. 
.EXAMPLE
    .\Install-Workstation.ps1
.INPUTS
    None
.OUTPUTS
    None
.LINK
 
    https://github.com/angryhussord/
#>

#Make sure PowerShell help is useful
Update-Help -Confirm:$false;

.\Update-OEMInformation.ps1
.\Set-HighPerformancePowerProfile.ps1

#Always start with Anti-virus software in case any of the below is compromised.
.\bitdefender\Install-BitDefender.ps1

#Setup local user profile and add features
. .\Restart-Explorer.ps1
. .\Move-UserShellFolders.ps1
Move-LibraryDirectory 'My Music' 'D:\Music'
Move-LibraryDirectory 'My Pictures' 'D:\Pictures'
Move-LibraryDirectory 'My Videos' 'D:\Videos'
Move-LibraryDirectory 'Personal' 'D:\Documents'
Move-LibraryDirectory 'OneDrive' 'D:\OneDrive'
Move-LibraryDirectory 'Downloads' 'D:\Downloads'
.\Install-GodMode.ps1
.\Install-WindowsFeature.ps1 TelnetClient
. .\Set-WindowsExplorerOptions.ps1
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowFullPathInTitleBar
. .\Enable-RemoteDesktop.ps1
Enable-RemoteDesktop

#Install chocolatey
.\Install-Chocolatey.ps1

#Install chocolatey packages
.\Install-WorkstationPackages.ps1 Workstation-Packages.txt

#Copy over config files
.\Copy-EqualizerAPOConfig.ps1
.\Copy-JoyToKeyConfig.ps1

#Add VLC Bluray Support
.\vlc-bluray\Install-VLCBluray.ps1

#Add SubmlimeText3 PowerShell support
.\SublimeText3\Install-PowerShellSupport.ps1

#Install Visual Studio 2015
.\VisualStudio2015\Install-VisualStudio.ps1

#Install Office 2013
.\office2013\Install-Office2013.ps1

#Import Start Menu Layout
Import-StartLayout -LayoutPath .\DefaultLayout.bin -MountPath C:\

#Install RSAT tools for Windows 10
.\Install-Windows10RSAT.ps1

Write-Output "Installing Windows Updates..."
Import-Module PSWindowsUpdate
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false | Out-Null
Get-WUList -MicrosoftUpdate | Out-Null
Get-WUInstall �MicrosoftUpdate �AcceptAll �AutoReboot
Restart-Computer