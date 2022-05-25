# idchoppers, 4/3/2021 
# Developed quick 'n dirty in PowerShell ISE (BTW its a really handy tool, I will use it more!)

Write-Host ""
Write-Host "############################" -ForegroundColor Green -BackgroundColor DarkBlue
Write-Host "#                          #" -ForegroundColor Green -BackgroundColor DarkBlue
Write-Host "#  Windows 10 SetupScript  #" -ForegroundColor Green -BackgroundColor DarkBlue
Write-Host "#      By: idchoppers      #" -ForegroundColor Green -BackgroundColor DarkBlue
Write-Host "#                          #" -ForegroundColor Green -BackgroundColor DarkBlue
Write-Host "############################" -ForegroundColor Green -BackgroundColor DarkBlue
Write-Host ""



Write-Host "Creating Restore Point..." -ForegroundColor Yellow
Checkpoint-Computer -Description "RestorePoint1" -RestorePointType "MODIFY_SETTINGS"                                                                  # This is good practice
Write-Host "Restore Point Created!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Muting system sounds..." -ForegroundColor Yellow                                                                                          # A reg hive that mutes system sounds
Start-Process reg -ArgumentList "import sounds.reg" 
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Adding Open Powershell Here..." -ForegroundColor Yellow
Start-Process reg -ArgumentList "import openpshere.reg"                                                                                               # Add open with powershell here to folders
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Setting Power to High Performance..." -ForegroundColor Yellow                                                                             # Add some zeros to the power bill
powercfg /S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Making UAC secure..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" 3                               # UAC prompt should always require a password
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Disable easy access keyboard stuff..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506"                                                                   # Disable sticky keys
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122"                                                            # Spped up keyboard response time
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58"                                                                    # Disable toggle keys
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Setting folder view options..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1                                                 # Show hidden files
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0                                            # Show file extensions
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideDrivesWithNoMedia" 0                                  # Disable hiding storage media if empty
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0                          # Disable Sync to OneDrive notifs
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Disable Pretty Path..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DontPrettyPath" 1                                         # Disables changing the upper or lower case of filenames
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Disable Aero-Shake Minimize feature..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisallowShaking" 1                                        # Disable Aero-Shake
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Setting default explorer view to This PC..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 1                                               # Make Explorer's default page This PC
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Making taskbar look better..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSmallIcons" 1                                      # Make taskbar use small icons
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCortanaButton" 0                                      # Hide Cortana button
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0                                              # Hide search bar
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0                                     # Hide Tasks button
New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies -Name "Explorer” -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAMeetNow" 1                                         # Hide Meet Now button
New-Item -Path HKCU:\Software\Policies\Microsoft\Windows -Name "Explorer” -Force
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "HidePeopleBar" 1                                                         # Hide People button
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft -Name "WindowsInkWorkspace” -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" "AllowWindowsInkWorkspace" 0                                           # Disable Windows Ink
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" 2                                          # Disable Weather widget
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Enabling Dark Mode and Aero..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" -Value 0 -Type Dword -Force        # Systemwide Aero
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" -Value 0                              # App dark mode
Start-Sleep 1
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Disabling transparancy..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 -Type Dword -Force                 # Disable transparency
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Disabling lock screen..." -ForegroundColor Yellow
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name "Personalization” -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreen" 1 -Type Dword -Force                                # Disables the swipe up to logon thingy, this is a PC, not a tablet :/
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Making WinLogon use a solid color background..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableLogonBackgroundImage" 1 -Type Dword -Force                          # Disable Winlogon's background
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Making Start Menu faster..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" "MenuShowDelay" 50                                                                               # Default speed is 400, this is faster 
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Disable Bing in search menu..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1                                           # Removes searching on Bing in the Start Menu 
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Disable look for app in app store prompt..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "NoUseStoreOpenWith" 1                                                    # Removes "look for app in app store" when opening something with an unknown extension 
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Disable Cortana..." -ForegroundColor Yellow
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name "Windows Search” -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0                                                    # Disables Cortana, RIP  
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Enable Secure Attention..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "DisableCAD" 0                                                   # This enables Ctrl+Alt+Del to logon, is a lot safer than regular logon 
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Enable verbosity during logon..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "verbosestatus" 1                                            # Verbosity is always nice just in case you want to snoop, or if something goes awry
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Enable Windows 7 UI elements..." -ForegroundColor Yellow
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "MTCUVC” -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" "EnableMtcUvc" 0 -Type Dword -Force                                # This volume manager may not be Metro-style, but it is very fast to use
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" "UseWin32TrayClockExperience" 1 -Type Dword -Force            # Has an analog clock so its cooler
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" "UseWin32BatteryFlyout" 1 -Type Dword -Force                  # Windows 7 battery flyout
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" "UseActionCenterExperience" 0 -Type Dword -Force              # Old Action center uses less memory
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "EnableXamlStartMenu" 0 -Type Dword -Force                 # Old menu saves memory
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "EnableXamlJumpView" 1 -Type Dword -Force                  # Jump View is useful
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Disable Animations..." -ForegroundColor Yellow                                                                                            # This script contains some C# code because you have to interact with the system to disable animations, it should return True if successful
Add-Type -TypeDefinition @"                                                                                                                           
    using System;
    using System.Runtime.InteropServices;
    [StructLayout(LayoutKind.Sequential)] public struct ANIMATIONINFO {
        public uint cbSize;
        public bool iMinAnimate;
    }
    public class PInvoke { 
        [DllImport("user32.dll")] public static extern bool SystemParametersInfoW(uint uiAction, uint uiParam, ref ANIMATIONINFO pvParam, uint fWinIni);
    }
"@
$animInfo = New-Object ANIMATIONINFO
$animInfo.cbSize = 8
$animInfo.iMinAnimate = $args[0]
[PInvoke]::SystemParametersInfoW(0x49, 1, [ref]$animInfo, 3)
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Change wallpaper..." -ForegroundColor Yellow
Function Set-WallPaper($Value)
{

 Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $value

 rundll32.exe user32.dll, UpdatePerUserSystemParameters

}
Set-WallPaper -value "img0.jpg"
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Enable WSL2..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart                                                       # WSL2 is a must have
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "Create PowerShell profile..." -ForegroundColor Yellow
if (!(Test-Path -Path $PROFILE))
{
        New-Item -Type file -Force $PROFILE
        Move-Item -Force -Path Microsoft.PowerShell_profile.ps1 -Destination $env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1  # Profile
}

Write-Host "Restart explorer..." -ForegroundColor Yellow
Stop-Process -name explorer –force                                                                                                                    # Restart explorer for cosmetic changes
Write-Host "Done!" -ForegroundColor Black -BackgroundColor Green
Write-Host ""

Write-Host "!!! WARNING !!!" -ForegroundColor White -BackgroundColor Red                                                                              # Because I used DISM to install WSL2, a restart is needed
Write-Host "!!! WARNING !!!" -ForegroundColor White -BackgroundColor Red
Write-Host "!!! WARNING !!!" -ForegroundColor White -BackgroundColor Red

Write-Host "A Restart is needed to finalize these changes!" -BackgroundColor Red -ForegroundColor White
Write-Host ""
$input = Read-Host "Restart computer now? [y/n]"
switch($input)
{
          y{Restart-computer -Force -Confirm:$false}
          n{exit}
    default{write-warning "Invalid Input"}
}
