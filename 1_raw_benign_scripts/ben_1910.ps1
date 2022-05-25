$Boxstarter.RebootOk=$true

Set-WindowsExplorerOptions -EnableShowFileExtensions -DisableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFullPathInTitleBar
Enable-MicrosoftUpdate
Enable-UAC

Install-WindowsUpdate -AcceptEula
if (Test-PendingReboot) { Invoke-Reboot }

Update-Help

if ($env:computername -notmatch "^ART-PC$") {
 Rename-Computer -NewName ART-PC -Restart
}

Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\services\NetLogon\Parameters -Name AllowSingleLabelDnsDomain -Value 1 -Type DWORD
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\services\DnsCache\Parameters -Name UpdateTopLevelDomainZones -Value 1 -Type DWORD
if ((gwmi WIN32_ComputerSystem).Domain -notmatch "^KONTUR$") {
 Add-Computer -DomainName KONTUR -Credential KONTUR\art -Restart
}

powercfg.exe -change -disk-timeout-ac 0
powercfg.exe -change -standby-timeout-ac 0
powercfg.exe -change -hibernate-timeout-ac 0
Enable-RemoteDesktop
#todo add firewall exception for remote desktop

Update-ExecutionPolicy Unrestricted
cinst -y 7zip
cinst -y GoogleChrome
cinst -y VisualStudio2015Community
cinst -y Atom
cinst -y skype
cinst -y poshgit
cinst -y far
cinst -y itunes
cinst -y jre8
#todo remove desktop icon for chrome, atom & skype
#todo install github desktop (https://desktop.github.com/)
#todo install resharper (fix choco package)
#todo add http://ul-licserver to license servers
#todo install VisualStudio updates (NuGet)

#todo cinst -y DotNet3.5 не работает
#DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /Source:d:\sources\sxs - тоже не работает без диска
cinst -y DotNet4.5.1

dism /online /enable-feature /all /featurename:IIS-ASPNET45

Import-Module WebAdministration

$defaultWebSite = Get-Website -Name 'Default Web Site'

if ($defaultWebSite -ne $null) {
  Remove-WebSite -Name $defaultWebSite.name
}
#todo добавить 4 сайта

#todo cinst -y mongodb - монга не ставится, да и старая она
#todo add mongodb to path
cinst -y rabbitmq
#todo enable management plugin (add to choco package)
#todo add rabbitmq sbin to path

cinst -y elasticsearch
#todo починить elasticsearch-g
#todo нужно, чтобы elasticsearch ставил head и russian morphology

#todo urlrewrite
#todo modify hosts (localhost.dev.kontur, s3fake)