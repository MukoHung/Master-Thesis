# Important note: this enables REMOTE DESKTOP! Use good passwords!

## function definitions
function Set-Reg($key, $name, $value, $type) {
    If (-Not (Test-Path "$key")) {
        New-Item -Path "$key" -ItemType RegistryKey -Force | Out-Null
    }
    if ($type -eq $null) {
        Set-ItemProperty -path "$key" -Name "$name" -Value $value	
    } else {
        Set-ItemProperty -path "$key" -Name "$name" -Value $value -Type "$type"
    }
}

function Delete-LockedFile($path) { 
    $path = (Resolve-Path $path).Path 
    $MOVEFILE_DELAY_UNTIL_REBOOT = 0x00000004
    $memberDefinition = @' 
    [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Auto)] 
    public static extern bool MoveFileEx(string lpExistingFileName, string lpNewFileName, 
       int dwFlags); 
'@

    $type = Add-Type -Name MoveFileUtils -MemberDefinition $memberDefinition -PassThru
    $result = $type::MoveFileEx($path, [NullString]::Value, $MOVEFILE_DELAY_UNTIL_REBOOT)
    if ($result -eq 0) {
        throw [ComponentModel.Win32Exception][Runtime.InteropServices.Marshal]::GetLastWin32Error()
    }
}

function Force-Delete-Path($path) {
    $acl = Get-Acl "$path"
    $acl.SetOwner([System.Security.Principal.NTAccount] "Administrators")
    Get-ChildItem -Force -Recurse "$path" | Set-Acl -aclobject $acl

    Force-Delete-Recursive "$path"
}

function Force-Delete-Recursive($path) {
    gci -Force "$path" | % {
        if ($_.PSIsContainer) { Force-Delete-Recursive $_.FullName }
        else { Delete-LockedFile $_.FullName }
    }
    Delete-LockedFile "$path"
}

Function WSUSUpdate {
    $Criteria = "IsInstalled=0 and Type='Software'"
    $Searcher = New-Object -ComObject Microsoft.Update.Searcher
    try {
        $SearchResult = $Searcher.Search($Criteria).Updates
        if ($SearchResult.Count -eq 0) {
            Write-Output "There are no applicable updates."
            exit
        } else {
            $Session = New-Object -ComObject Microsoft.Update.Session
            $Downloader = $Session.CreateUpdateDownloader()
            $Downloader.Updates = $SearchResult
            $Downloader.Download()
            $Installer = New-Object -ComObject Microsoft.Update.Installer
            $Installer.Updates = $SearchResult
            $Result = $Installer.Install()
        }
    } catch {
        Write-Output "There are no applicable updates."
    }
}

cd $env:TEMP
Start-Transcript -path "$env:TEMP/installation.log"

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

# install GPO
(New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip", "$env:TEMP\LGPO.zip")

$shell = new-object -com shell.application
$zip = $shell.NameSpace("$env:TEMP\LGPO.zip")
foreach($item in $zip.items()) {
    $shell.Namespace("$env:TEMP\").copyhere($item)
}

(New-Object System.Net.WebClient).DownloadFile("https://gist.githubusercontent.com/Tharre/6aba0fb594376c17c5734ae4e01cc157/raw/", "$env:TEMP\registry_machine.cfg")
.\LGPO_30\LGPO.exe /t registry_machine.cfg
gpupdate /force

Get-Netadapter -Physical | foreach {
	# set dns
	Set-DNSClientServerAddress -interfaceIndex $_.ifIndex -ServerAddresses ("8.8.8.8", "84.200.69.80")
	
	# make network "private"
	Set-NetConnectionProfile -InterfaceIndex $_.ifIndex -NetworkCategory Private
}

# allow ICMP
netsh advfirewall firewall add rule name="ICMP Allow V4" protocol=icmpv4:8,any dir=in action=allow
netsh advfirewall firewall add rule name="ICMP Allow V6" protocol=icmpv6:8,any dir=in action=allow

# keyboard input settings
$ll = New-WinUserLanguageList de-DE
$ll[0].InputMethodTips.Add('0409:00000409')
Set-WinUserLanguageList $ll -Force

# use proper folder options
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Hidden 1
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" HideFileExt 0
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ShowSuperHidden 1
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" SeparateProcess 1
#Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" AltTabSettings 1 # better alt-tab
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\" UseDesktopIniCache 0

Stop-Process -processname explorer

# map CAPSLOCK to F13
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout" "Scancode Map" ([byte[]](
                   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
                   0x02,0x00,0x00,0x00,
                   0x5b,0x00,0x3a,0x00,
                   0x00,0x00,0x00,0x00))

# disable mouse acceleration
Set-Reg "HKCU:\Control Panel\Mouse" MouseSpeed 0
Set-Reg "HKCU:\Control Panel\Mouse" MouseThreshold1 0
Set-Reg "HKCU:\Control Panel\Mouse" MouseThreshold2 0

# Treat CMOS time as UTC, as any sane OS would
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" RealTimeIsUniversal 1

# resync time
net start w32time
w32tm /config /update
net stop w32time
net start w32time
w32tm /resync /force

# disable sticky keys
Set-Reg "HKCU:\Control Panel\Accessibility\StickyKeys" Flags 10
Set-Reg "HKCU:\Control Panel\Accessibility\Keyboard Response" Flags 122
Set-Reg "HKCU:\Control Panel\Accessibility\ToggleKeys" Flags 58

# disable the default alt-shift keyboard language switching hotkey
Set-Reg "HKCU:\Keyboard Layout\Toggle" Hotkey 3 String
Set-Reg "HKCU:\Keyboard Layout\Toggle" "Language Hotkey" 3 String
Set-Reg "HKCU:\Keyboard Layout\Toggle" "Layout Hotkey" 3 String

# deinstall bullshit
Get-AppXProvisionedPackage -online | Remove-AppxProvisionedPackage -online 2> $null
Get-AppxPackage -AllUsers | Remove-AppxPackage 2> $null

# disable "real-time protection" from windows defender (the option that automatically turns itself back on
# if you try to disable it in the settings)
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" DisableRealtimeMonitoring 1

# deinstall cortana
#Force-Delete-Path "C:\Windows\SystemApps\Microsoft.Windows.Cortana_*"
#Force-Delete-Path "C:\Windows\SystemApps\CortanaListenUIApp_*"

# don't automatically reduce audio volume during skype calls
Set-Reg "HKCU:\Software\Microsoft\Multimedia\Audio" UserDuckingPreference 3

# disable windows search index
net stop WSearch
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" Start 4

# disable "fast startup"
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" HiberbootEnabled 0

# disable the joke that is game bar
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" AppCaptureEnabled 0
Set-Reg "HKCU:\System\GameConfigStore" GameDVR_Enabled 0

# disable "People" button in taskbar
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" PeopleBand 0

# remove "3D Objects"
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" "ThisPCPolicy" "Hide"
Set-Reg "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" "ThisPCPolicy" "Hide"

# add "syncthing" to the file explorer's navigation bar
New-Item -Path "$env:USERPROFILE\Share" -ItemType directory -Force
Set-Reg "HKCR:\CLSID\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}" '(default)' "Syncthing"
Set-Reg "HKCR:\CLSID\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}" "System.IsPinnedToNameSpaceTree" 1
Set-Reg "HKCR:\CLSID\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}" "SortOrderIndex" 0x00000042
Set-Reg "HKCR:\CLSID\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}\DefaultIcon" '(default)' "C:\ProgramData\chocolatey\bin\syncthing.exe"
Set-Reg "HKCR:\CLSID\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}\InProcServer32" '(default)' "%SystemRoot%\\system32\\shell32.dll"
Set-Reg "HKCR:\CLSID\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}\Instance" "CLSID" "{0E5AAE11-A475-4c5b-AB00-C66DE400274E}"
Set-Reg "HKCR:\CLSID\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}\Instance\InitPropertyBag" "Attributes" 0x00000011
Set-Reg "HKCR:\CLSID\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}\Instance\InitPropertyBag" "TargetFolderPath" "%USERPROFILE%\Share" ExpandString
Set-Reg "HKCR:\CLSID\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}\ShellFolder" "Attributes" 0xf080004d
Set-Reg "HKCR:\CLSID\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}\ShellFolder" "FolderValueFlags" 0x00000028
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{A89779A7-A2C7-4296-9879-FA1C2B767CC8}" 1
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{A89779A7-A2C7-4296-9879-FA1C2B767CC8}" '(default)' "Syncthing"

# disable security&maintenance notifications
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" Enabled 0

# disable notifications
Set-Reg "HKCU:\Software\Policies\Microsoft\Windows\Explorer" DisableNotificationCenter 1

# disable the "news and interests bar" found on the bottom right of the task bar
Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds" EnableFeeds 0

# disable the search bar found on the bottom left of the task bar
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" SearchBoxTaskbarMode 0

# open powershell as administrator
$ps_command = "$PSHOME\powershell.exe -NoExit -NoProfile -Command ""Set-Location '%V'"""
"directory", "directory\background", "drive" | ForEach-Object {
	Set-Reg "HKCR:\$_\shell\runas" HasLUAShield ""
	Set-Reg "HKCR:\$_\shell\runas" "(default)" "PowerShell Here"
	Set-Reg "HKCR:\$_\shell\runas\command" "(default)" $ps_command
}

#   Description:
# This script blocks telemetry related domains via the hosts file and related
# IPs via Windows Firewall.
#
# "THE BEER-WARE LICENSE" (Revision 42):

# As long as you retain this notice you can do whatever you want with this
# stuff. If we meet some day, and you think this stuff is worth it, you can
# buy us a beer in return.

# This project is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.

function force-mkdir($path) {
    if (!(Test-Path $path)) {
        #Write-Host "-- Creating full path to: " $path -ForegroundColor White -BackgroundColor DarkGreen
        New-Item -ItemType Directory -Force -Path $path
    }
}

echo "Disabling telemetry via Group Policies"
force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
sp "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0

echo "Adding telemetry domains to hosts file"
$hosts_file = "$env:systemroot\System32\drivers\etc\hosts"
$domains = @(
    "a-0001.a-msedge.net"
    "a-0002.a-msedge.net"
    "a-0003.a-msedge.net"
    "a-0004.a-msedge.net"
    "a-0005.a-msedge.net"
    "a-0006.a-msedge.net"
    "a-0007.a-msedge.net"
    "a-0008.a-msedge.net"
    "a-0009.a-msedge.net"
    "a1621.g.akamai.net"
    "a1856.g2.akamai.net"
    "a1961.g.akamai.net"
    #"a248.e.akamai.net"            # makes iTunes download button disappear (#43)
    "a978.i6g1.akamai.net"
    "a.ads1.msn.com"
    "a.ads2.msads.net"
    "a.ads2.msn.com"
    "ac3.msn.com"
    "ad.doubleclick.net"
    "adnexus.net"
    "adnxs.com"
    "ads1.msads.net"
    "ads1.msn.com"
    "ads.msn.com"
    "aidps.atdmt.com"
    "aka-cdn-ns.adtech.de"
    "a-msedge.net"
    "any.edge.bing.com"
    "a.rad.msn.com"
    "az361816.vo.msecnd.net"
    "az512334.vo.msecnd.net"
    "b.ads1.msn.com"
    "b.ads2.msads.net"
    "bingads.microsoft.com"
    "b.rad.msn.com"
    "bs.serving-sys.com"
    "c.atdmt.com"
    "cdn.atdmt.com"
    "cds26.ams9.msecn.net"
    "choice.microsoft.com"
    "choice.microsoft.com.nsatc.net"
    "c.msn.com"
    "compatexchange.cloudapp.net"
    "corpext.msitadfs.glbdns2.microsoft.com"
    "corp.sts.microsoft.com"
    "cs1.wpc.v0cdn.net"
    "db3aqu.atdmt.com"
    "df.telemetry.microsoft.com"
    "diagnostics.support.microsoft.com"
    "e2835.dspb.akamaiedge.net"
    "e7341.g.akamaiedge.net"
    "e7502.ce.akamaiedge.net"
    "e8218.ce.akamaiedge.net"
    "ec.atdmt.com"
    "fe2.update.microsoft.com.akadns.net"
    "feedback.microsoft-hohm.com"
    "feedback.search.microsoft.com"
    "feedback.windows.com"
    "flex.msn.com"
    "g.msn.com"
    "h1.msn.com"
    "h2.msn.com"
    "hostedocsp.globalsign.com"
    "i1.services.social.microsoft.com"
    "i1.services.social.microsoft.com.nsatc.net"
    "ipv6.msftncsi.com"
    "ipv6.msftncsi.com.edgesuite.net"
    "lb1.www.ms.akadns.net"
    "live.rads.msn.com"
    "m.adnxs.com"
    "msedge.net"
    "msftncsi.com"
    "msnbot-65-55-108-23.search.msn.com"
    "msntest.serving-sys.com"
    "oca.telemetry.microsoft.com"
    "oca.telemetry.microsoft.com.nsatc.net"
    "onesettings-db5.metron.live.nsatc.net"
    "pre.footprintpredict.com"
    "preview.msn.com"
    "rad.live.com"
    "rad.msn.com"
    "redir.metaservices.microsoft.com"
    "reports.wes.df.telemetry.microsoft.com"
    "schemas.microsoft.akadns.net"
    "secure.adnxs.com"
    "secure.flashtalking.com"
    "services.wes.df.telemetry.microsoft.com"
    "settings-sandbox.data.microsoft.com"
    "settings-win.data.microsoft.com"
    "sls.update.microsoft.com.akadns.net"
    "sqm.df.telemetry.microsoft.com"
    "sqm.telemetry.microsoft.com"
    "sqm.telemetry.microsoft.com.nsatc.net"
    "ssw.live.com"
    "static.2mdn.net"
    "statsfe1.ws.microsoft.com"
    "statsfe2.update.microsoft.com.akadns.net"
    "statsfe2.ws.microsoft.com"
    "survey.watson.microsoft.com"
    "telecommand.telemetry.microsoft.com"
    "telecommand.telemetry.microsoft.com.nsatc.net"
    "telemetry.appex.bing.net"
    "telemetry.appex.bing.net:443"
    "telemetry.microsoft.com"
    "telemetry.urs.microsoft.com"
    "vortex-bn2.metron.live.com.nsatc.net"
    "vortex-cy2.metron.live.com.nsatc.net"
    "vortex.data.microsoft.com"
    "vortex-sandbox.data.microsoft.com"
    "vortex-win.data.microsoft.com"
    "watson.live.com"
    "watson.microsoft.com"
    "watson.ppe.telemetry.microsoft.com"
    "watson.telemetry.microsoft.com"
    "watson.telemetry.microsoft.com.nsatc.net"
    "wes.df.telemetry.microsoft.com"
    "win10.ipv6.microsoft.com"
    "www.bingads.microsoft.com"
    "www.go.microsoft.akadns.net"
    "www.msftncsi.com"

    # extra
    "fe2.update.microsoft.com.akadns.net"
    "s0.2mdn.net"
    "statsfe2.update.microsoft.com.akadns.net",
    "survey.watson.microsoft.com"
    "view.atdmt.com"
    "watson.microsoft.com",
    "watson.ppe.telemetry.microsoft.com"
    "watson.telemetry.microsoft.com",
    "watson.telemetry.microsoft.com.nsatc.net"
    "wes.df.telemetry.microsoft.com"
    "ui.skype.com",
    "pricelist.skype.com"
    "apps.skype.com"
    "m.hotmail.com"
    "s.gateway.messenger.live.com"
)
echo "" | Out-File -Encoding ASCII -Append $hosts_file
foreach ($domain in $domains) {
    if (-Not (Select-String -Path $hosts_file -Pattern $domain)) {
        echo "0.0.0.0 $domain" | Out-File -Encoding ASCII -Append $hosts_file
    }
}

echo "Adding telemetry ips to firewall"
$ips = @(
    "134.170.30.202"
    "137.116.81.24"
    "157.56.106.189"
    "2.22.61.43"
    "2.22.61.66"
    "204.79.197.200"
    "23.218.212.69"
    "65.39.117.230"
    "65.52.108.33"
    "65.55.108.23"
)
Remove-NetFirewallRule -DisplayName "Block Telemetry IPs" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Block Telemetry IPs" -Direction Outbound `
    -Action Block -RemoteAddress ([string[]]$ips)

#   Description:
# This script disables unwanted Windows services. If you do not want to disable
# certain services comment out the corresponding lines below.

$services = @(
    "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
    "DiagTrack"                                # Diagnostics Tracking Service
    "dmwappushservice"                         # WAP Push Message Routing Service
    "HomeGroupListener"                        # HomeGroup Listener
    "HomeGroupProvider"                        # HomeGroup Provider
    "lfsvc"                                    # Geolocation Service
    "MapsBroker"                               # Downloaded Maps Manager
    "NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
    "RemoteAccess"                             # Routing and Remote Access
    "RemoteRegistry"                           # Remote Registry
    "SharedAccess"                             # Internet Connection Sharing (ICS)
    "TrkWks"                                   # Distributed Link Tracking Client
    "WbioSrvc"                                 # Windows Biometric Service
    #"WlanSvc"                                 # WLAN AutoConfig
    "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
    "wscsvc"                                   # Windows Security Center Service
    #"WSearch"                                 # Windows Search
    "XblAuthManager"                           # Xbox Live Auth Manager
    "XblGameSave"                              # Xbox Live Game Save Service
    "XboxNetApiSvc"                            # Xbox Live Networking Service

    # Services which cannot be disabled
    #"WdNisSvc"
)

foreach ($service in $services) {
    echo "Trying to disable $service"
    Get-Service -Name $service | Set-Service -StartupType Disabled
}

# enable bash feature
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" AllowDevelopmentWithoutDevLicense 1
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux

# enable gpg ssh/putty support
New-Item -Path "$env:APPDATA\gnupg" -ItemType directory -Force
Set-Content -Path "$env:APPDATA\gnupg\gpg-agent.conf" -Value "enable-putty-support" -Force

# install chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# install packages
choco install -y 7zip autohotkey classic-shell curl firefox -packageParameters "l=en-GB" git gpg4win hashcheck imdisk imageglass notepadplusplus syncthing thunderbird putty veracrypt vlc

#WSUSUpdate

# change password at next login
#$usr=[ADSI]"WinNT://localhost/$env:UserName"  
#$usr.passwordExpired = 1  
#$usr.setinfo()  

# change background
(New-Object System.Net.WebClient).DownloadFile("https://www.androidguys.com/wp-content/uploads/2015/07/314903.jpg", "$env:APPDATA\wallpaper.jpg")
Set-Reg "HKCU:\Control Panel\Desktop\" wallpaper "$env:APPDATA\wallpaper.jpg"
rundll32.exe user32.dll, UpdatePerUserSystemParameters

(New-Object -ComObject Wscript.Shell).Popup("Installation finished!", 0, "Installation", 0x1)

# remove desktop links
Remove-Item "C:\Users\*\Desktop\*.lnk" -Force

Restart-Computer