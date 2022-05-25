Write-Host -NoNewline " "
Write-Host -NoNewline "  _______  _______  ___      _______  _______  _______  "
Write-Host -NoNewline " |       ||   _   ||   |    |   _   ||  _    ||       | "
Write-Host -NoNewline " |   _   ||  |_|  ||   |    |  |_|  || |_|   ||  _____| "
Write-Host -NoNewline " |  | |  ||       ||   |    |       ||       || |_____  "
Write-Host -NoNewline " |  |_|  ||       ||   |___ |       ||  _   | |_____  | "
Write-Host -NoNewline " |       ||   _   ||       ||   _   || |_|   | _____| | "
Write-Host -NoNewline " |_______||__| |__||_______||__| |__||_______||_______| "
Write-Host -NoNewline " "
Write-Host -NoNewline " "
Write-Host -NoNewline "       ==== x86 VM Setup for Malware Analysis ====      "
Write-Host -NoNewline "              https://www.openanalysis.net/             "
Write-Host -NoNewline "  "
Write-Host -NoNewline "   Maintained by:                                       "
Write-Host -NoNewline "                  @herrcore                             "
Write-Host -NoNewline "                  @seanmw                               "
Write-Host -NoNewline "  "

###############################################################################
# Quickstart:
#
# Set-ExecutionPolicy Unrestricted;
# iex ((New-Object System.Net.WebClient).DownloadString('http://boxstarter.org/bootstrapper.ps1'));
# get-boxstarter -Force;
# Install-BoxstarterPackage -PackageName <this gist raw url>
#
################################################################################

################################################################################
##
## START: Hacky way to remove pinned items from task bar
## 
 # NAME: PinnedApplications.psm1 
 #  
 # AUTHOR: Jan Egil Ring, Crayon 
 # 
 # DATE  : 06.08.2010  
 #  
 ###########################################################################
 
function Set-PinnedApplication 
{ 
<#  
.SYNOPSIS  
This function are used to pin and unpin programs from the taskbar and Start-menu in Windows 7 and Windows Server 2008 R2 
.DESCRIPTION  
The function have to parameteres which are mandatory: 
Action: PinToTaskbar, PinToStartMenu, UnPinFromTaskbar, UnPinFromStartMenu 
FilePath: The path to the program to perform the action on 
.EXAMPLE 
Set-PinnedApplication -Action PinToTaskbar -FilePath "C:\WINDOWS\system32\notepad.exe" 
.EXAMPLE 
Set-PinnedApplication -Action UnPinFromTaskbar -FilePath "C:\WINDOWS\system32\notepad.exe" 
.EXAMPLE 
Set-PinnedApplication -Action PinToStartMenu -FilePath "C:\WINDOWS\system32\notepad.exe" 
.EXAMPLE 
Set-PinnedApplication -Action UnPinFromStartMenu -FilePath "C:\WINDOWS\system32\notepad.exe" 
#>  
       [CmdletBinding()] 
       param( 
      [Parameter(Mandatory=$true)][string]$Action,  
      [Parameter(Mandatory=$true)][string]$FilePath 
       ) 
       if(-not (test-path $FilePath)) {  
           throw "FilePath does not exist."   
    } 

       function InvokeVerb { 
           param([string]$FilePath,$verb) 
        $verb = $verb.Replace("&","") 
        $path= split-path $FilePath 
        $shell=new-object -com "Shell.Application"  
        $folder=$shell.Namespace($path)    
        $item = $folder.Parsename((split-path $FilePath -leaf)) 
        $itemVerb = $item.Verbs() | ? {$_.Name.Replace("&","") -eq $verb} 
        if($itemVerb -eq $null){ 
            throw "Verb $verb not found."             
        } else { 
            $itemVerb.DoIt() 
        } 

       } 
    function GetVerb { 
        param([int]$verbId) 
        try { 
            $t = [type]"CosmosKey.Util.MuiHelper" 
        } catch { 
            $def = [Text.StringBuilder]"" 
            [void]$def.AppendLine('[DllImport("user32.dll")]') 
            [void]$def.AppendLine('public static extern int LoadString(IntPtr h,uint id, System.Text.StringBuilder sb,int maxBuffer);') 
            [void]$def.AppendLine('[DllImport("kernel32.dll")]') 
            [void]$def.AppendLine('public static extern IntPtr LoadLibrary(string s);') 
            add-type -MemberDefinition $def.ToString() -name MuiHelper -namespace CosmosKey.Util             
        } 
        if($global:CosmosKey_Utils_MuiHelper_Shell32 -eq $null){         
            $global:CosmosKey_Utils_MuiHelper_Shell32 = [CosmosKey.Util.MuiHelper]::LoadLibrary("shell32.dll") 
        } 
        $maxVerbLength=255 
        $verbBuilder = new-object Text.StringBuilder "",$maxVerbLength 
        [void][CosmosKey.Util.MuiHelper]::LoadString($CosmosKey_Utils_MuiHelper_Shell32,$verbId,$verbBuilder,$maxVerbLength) 
        return $verbBuilder.ToString() 
    } 

    $verbs = @{  
        "PintoStartMenu"=5381 
        "UnpinfromStartMenu"=5382 
        "PintoTaskbar"=5386 
        "UnpinfromTaskbar"=5387 
    } 

    if($verbs.$Action -eq $null){ 
           Throw "Action $action not supported`nSupported actions are:`n`tPintoStartMenu`n`tUnpinfromStartMenu`n`tPintoTaskbar`n`tUnpinfromTaskbar" 
    } 
    InvokeVerb -FilePath $FilePath -Verb $(GetVerb -VerbId $verbs.$action) 
} 
################################################################################
##
## END: Hacky way to remove pinned items from task bar
##
################################################################################



###############################################################################
# Configure system
###############################################################################

# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

# Basic setup
Update-ExecutionPolicy Unrestricted
Set-WindowsExplorerOptions -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowHiddenFilesFoldersDrives
Disable-BingSearch

# Disable UAC
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d "0" /f 

# Clean windows license server garbage 
# *OPTIONAL - only use if your VM is from https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/
# The default password for these VMs is: Passw0rd!
if (Test-Path "C:\BGinfo\build.cfg" -PathType Leaf)
{
write-host "Disabling Windows garbage from free VM!"
cmd.exe /c sc config OpenSSHd start= disabled
cmd.exe /c sc stop OpenSSHd
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "bginfo" /f 
}

# Disable Upates
write-host "Disabling Windows Update"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d "1" /f 

# Kill Windows Defender
write-host "Disabling Windows Defender"
cmd.exe /c sc config WinDefend start= disabled
cmd.exe /c sc stop WinDefend

# Shutup Action Center
write-host "Disabling Action Center notifications"
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v HideSCAHealth /t REG_DWORD /d "0x1" /f 

# Set windows Aero theme
write-host "Use Aero theme"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ThemeManager" /v DllName /t REG_EXPAND_SZ /d "%SystemRoot%\resources\themes\Aero\Aero.msstyles" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ThemeManager" /v ThemeActive /t REG_SZ /d "1" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" /v CurrentTheme /t REG_SZ /d "C:\Windows\resources\Themes\aero.theme" /f

# Set a nice OALABS wallpaper : )
write-host "Setting a nice wallpaper"
$web_dl = new-object System.Net.WebClient
$wallpaper_url = "https://gist.githubusercontent.com/OALabs/bfd29a3ad9f4f54d5fee4f1ea4ee706a/raw/ce9af14dc8374b531867ae00c9911dbeae566571/wallpaper.bmp"
$wallpaper_file = "C:\Users\Public\Pictures\wallpaper.bmp"
$web_dl.DownloadFile($wallpaper_url, $wallpaper_file)
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "C:\Users\Public\Pictures\wallpaper.bmp" /f
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallpaperStyle /t REG_DWORD /d "0" /f 
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v TileWallpaper /t REG_DWORD /d "0" /f 
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v Background /t REG_SZ /d "0 0 0" /f

# Set up Chocolatey
choco feature enable -n allowGlobalConfirmation
choco feature enable -n allowEmptyChecksums

# Configure FLARE chocolatey feed
# We use some package directly from FLARE since they don't contribute back to chocolatey : (
$flare = "https://www.myget.org/F/flare/api/v2"

###############################################################################
# Utilities
###############################################################################
cinst checksum   
cinst 7zip.install 
cinst procexp
try{
 # Rename procexp to avoid simple detection
 $procexp_old_target = "${env:chocolateyinstall}\lib\procexp\tools\procexp.exe"
 $procexp_new_target = "${env:chocolateyinstall}\lib\procexp\tools\pexp.exe"
 Copy-Item $procexp_old_target -Destination $procexp_new_target -Force
 # Hack to add procexp to start menu
 $procexp_shortcut = "${env:programdata}\Microsoft\Windows\Start Menu\Programs\pexp.lnk"
 Install-ChocolateyShortcut -shortcutFilePath $procexp_shortcut -targetPath $procexp_new_target
}
catch{
 write-host "Skip procexp post-setup"
}

cinst resourcehacker.portable --ignore-checksum
try{
 # Hack to pin the PE - may be updated as version is updated 
 $rhack_target = "${env:chocolateyinstall}\lib\resourcehacker.portable\tools\ResourceHacker.exe"
 $rhack_shortcut = "${env:programdata}\Microsoft\Windows\Start Menu\Programs\ResourceHacker.lnk"
 Install-ChocolateyShortcut -shortcutFilePath $rhack_shortcut -targetPath $rhack_target -PinToTaskbar
}
catch{
 write-host "Skip Resource hacker post-setup"
}

cinst hxd
Install-ChocolateyPinnedTaskBarItem "${env:programfiles}\HxD\HxD.exe"

cinst sublimetext3
Install-ChocolateyPinnedTaskBarItem "${env:programfiles}\Sublime Text 3\sublime_text.exe"

cinst googlechrome

###############################################################################
# PE Tools
###############################################################################
cinst pebear --version 0.3.8
try{
 # Hack to pin the PE - must be updated as version is updated 
 $pebear_target = "${env:chocolateyinstall}\lib\pebear\tools\PE-bear_x86_0.3.8\PE-bear.exe"
 $pebear_shortcut = "${env:programdata}\Microsoft\Windows\Start Menu\Programs\pebear.lnk"
 Install-ChocolateyShortcut -shortcutFilePath $pebear_shortcut -targetPath $pebear_target -PinToTaskbar
}
catch{
 write-host "Skip pebear post-setup"
}

cinst lordpe.flare -s $flare  
try{
 # Remove silly FLARE folder and give this a sane place on the start menu
 Remove-Item -Recurse "${env:programdata}\Microsoft\Windows\Start Menu\Programs\FLARE"
 $lordpe_target = "${env:chocolateyinstall}\lib\lordpe.flare\tools\LordPE.EXE"
 $lordpe_shortcut = "${env:programdata}\Microsoft\Windows\Start Menu\Programs\LordPE.lnk"
 Install-ChocolateyShortcut -shortcutFilePath $lordpe_shortcut -targetPath $lordpe_target
}
catch{
 write-host "Skip lordpe post-setup"
}

###############################################################################
# Debugger
# TODO: really should move this out of FLARE and into Chocolatey and up version
###############################################################################
cinst x64dbg   -s $flare
try{
 # Unpin x64dbg from taskbar
 Set-PinnedApplication -Action UnPinFromTaskbar -FilePath  "${env:programfiles}\x64dbg\release\x64\x64dbg.exe"
}
catch{
 write-host "Unpin x64dbg failed"
}
try{
 # Move x32dbg to start menu
 $x32dbg_target = "${env:programfiles}\x64dbg\release\x32\x32dbg.exe"
 $x32dbg_shortcut = "${env:programdata}\Microsoft\Windows\Start Menu\Programs\x32dbg.lnk"
 Install-ChocolateyShortcut -shortcutFilePath $x32dbg_shortcut -targetPath $x32dbg_target
 # Remove silly FLARE folder
 Remove-Item -Recurse "${env:programdata}\Microsoft\Windows\Start Menu\Programs\FLARE"
}
catch{
 write-host "Skip procexp post-setup"
}

###############################################################################
# Python
###############################################################################
cinst python2 
refreshenv
cinst pip

# Python tools
python -m pip install --upgrade pip
pip install --upgrade setuptools
pip install pefile
pip install oletools
pip install yara

###############################################################################
# Hack install python strings util
###############################################################################
if (-not (Test-Path "${env:chocolateyinstall}\bin\strings.py" -PathType Leaf)){
 # Download strings.py script from gist
 write-host "Download python strings tool"
 $web_dl2 = new-object System.Net.WebClient
 $strings_url = "https://gist.githubusercontent.com/herrcore/0b66bef7e844187169a966ef606de563/raw/af459061a7164a1f154eb85cf29860e19dcea237/strings.py"
 $strings_file = "${env:chocolateyinstall}\bin\strings.py"
 $web_dl2.DownloadFile($strings_url, $strings_file)
}

###############################################################################
# Office Utilities
###############################################################################
cinst offvis              -s $flare 
cinst officemalscanner    -s $flare 

###############################################################################
# PDF Utilities
###############################################################################
cinst pdfid             -s $flare 
cinst pdfparser         -s $flare 
cinst pdfstreamdumper   -s $flare 

try{
 # Final FLARE folder clean up
 # Move the rest of the FLARE links to program files
 $flare_folder = "${env:programdata}\Microsoft\Windows\Start Menu\Programs\FLARE\*"
 $start_folder = "${env:programdata}\Microsoft\Windows\Start Menu\Programs\"
 Copy-Item -Path $flare_folder -Destination $start_folder -recurse -Force -Verbose
 Remove-Item -Recurse "${env:programdata}\Microsoft\Windows\Start Menu\Programs\FLARE"
}
catch{
 write-host "Skip final FLARE clean up"
}

###############################################################################
# WE ARE DONE : )
###############################################################################
Write-Host -NoNewline " - INSTALL COMPLETE! - "
