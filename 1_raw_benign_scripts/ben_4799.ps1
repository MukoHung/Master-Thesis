



# TODO set up Sysmon/config, look at FW rules

####-----------####
## The Red Chord ##
#-----{pull}------#

# Alternatew powershell install for the boxstarter module and then a command to pull a script that contains the desired config
# . { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force
# possible one-liner
# Install-BoxstarterPackage -PackageName https://gist.github.com/gistfile1.txt -DisableReboots

# Bypass ep and install choco
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install boxstarter

# Prep env for run
Disable-UAC
$Boxstarter.RebootOk=$true
$Boxstarter.AutoLogin=$true

# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf("/"))
$helperUri += "/scripts"
write-host "helper script base URI is $helperUri"

function executeScript {
    Param ([string]$script)
    write-host "executing $helperUri/$script ..."
	iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
}

#--- Setting up Windows ---
choco feature enable -n allowGlobalConfirmation
executeScript "FileExplorerSettings.ps1";
executeScript "SystemConfiguration.ps1";
executeScript "Browsers.ps1";
executeScript "CommonDevTools.ps1";
executeScript "RemoveDefaultApps.ps1";
executeScript "wtshortcut.ps1";
executeScript "creative.ps1";
executeScript "hacklivesmatter.ps1";
executeScript "mrmalware.ps1";
executeScript "Docker.ps1";
executeScript "sysmon.ps1";
executeScript "WSL.ps1";



# Set a Satanic wallpaper
# Going forward, make a gallery online and have this pull a random one? Could be fun
write-host "Setting a nice wallpaper"
$web_dl = new-object System.Net.WebClient
$wallpaper_url = "https://grpahics.s3.us-east-1.amazonaws.com/lich3.jpg"
$wallpaper_file = "C:\Users\Public\Pictures\hailsatan.png"
$web_dl.DownloadFile($wallpaper_url, $wallpaper_file)
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "C:\Users\Public\Pictures\hailsatan.png" /f
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallpaperStyle /t REG_DWORD /d "0" /f 
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v StretchWallpaper /t REG_DWORD /d "2" /f 
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v Background /t REG_SZ /d "0 0 0" /f

# Set windows Aero theme
write-host "Use Aero theme"
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ThemeManager" /v DllName /t REG_EXPAND_SZ /d "%SystemRoot%\resources\themes\Aero\Aero.msstyles" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ThemeManager" /v ThemeActive /t REG_SZ /d "1" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" /v CurrentTheme /t REG_SZ /d "C:\Windows\resources\Themes\aero.theme" /f


Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
