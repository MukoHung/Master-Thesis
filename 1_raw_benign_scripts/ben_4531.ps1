# Run this from Powershell as Administrator with (New-Object System.Net.WebClient).DownloadString("https://gist.github.com/damieng/881852e7112be7d97957/raw") | powershell -command -
Write-Output "Making Windows more developer oriented (Revision 26)..."
Set-ExecutionPolicy Unrestricted

if ([System.Environment]::OSVersion.Version.Major -ge 10) {
    Write-Output " * Detected Windows 10"

    Write-Output "    * Removing Windows 10 bloatware"
    $apps = @(
        "Microsoft.3DBuilder"
        "Microsoft.Appconnector"
        "Microsoft.BingFinance"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingWeather"
        "Microsoft.Getstarted"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.Office.OneNote"
        "Microsoft.People"
        "Microsoft.SkypeApp"
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsCamera"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsSoundRecorder"
#       "Microsoft.XboxApp" # Leaving this one for screen recording
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "microsoft.windowscommunicationsapps"
        "Microsoft.MinecraftUWP"
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.Messaging"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.Office.Sway"
        "9E2F88E3.Twitter"
        "Flipboard.Flipboard"
        "ShazamEntertainmentLtd.Shazam"
        "king.com.CandyCrushSodaSaga"
        "ClearChannelRadioDigital.iHeartRadio"
        "TheNewYorkTimes.NYTCrossword"
    )
    foreach ($app in $apps) {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage
    }

    Write-Output "    * Opting out of Windows 10 data collection"
    $key = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
    md -Force $key | Out-Null
    sp $key "AcceptedPrivacyPolicy" 0 -type dword
    $key = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    md -Force $key | Out-Null
    sp $key "HarvestContacts" 0 -type dword
    $key = 'HKCU:\SOFTWARE\Microsoft\InputPersonalization'
    md -Force $key | Out-Null
    sp $key "RestrictImplicitInkCollection" 1 -type dword
    sp $key "RestrictImplicitTextCollection" 1 -type dword
    $user = New-Object System.Security.Principal.NTAccount($env:UserName)
    $sid = $user.Translate([System.Security.Principal.SecurityIdentifier]).value
    $key = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\"
    $ukey = ($key + $sid)
    md -Force $ukey | Out-Null
    sp $ukey "FeatureStates" 0x33c -type dword
    sp $key "WiFiSenseCredShared" 0 -type dword
    sp $key "WiFiSenseOpen" 0 -type dword
    Write-Output "    * Enabling long paths (Win10 build 14352+ required)"
    $key = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    md -Force $key | Out-Null
    sp $key "LongPathsEnabled" 1 -type dword
} else {
    Write-Output " * Turning off Windows 10 upgrade toasts"
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Gwx'
    if (-Not (Test-Path $key)) { New-Item $key | Out-Null }
    New-ItemProperty -path $key -name 'DisableGwx' -value 0x1 -PropertyType dword -force | Out-Null 
}

Write-Output " * Making Windows Explorer system oriented"
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
sp $key ShowFrequent 0 -type dword
sp $key ShowRecent 0 -type dword
$key = ($key + '\Advanced')
sp $key Hidden 1 -type dword
sp $key HideFileExt 0 -type dword
sp $key ShowSuperHidden 1 -type dword
sp $key LaunchTo 1 -type dword
# Remove Videos, Music and Pictures shortcuts from My Computer view
$shortcutKeys = @(
    "{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
    "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
    "{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
    "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
    "{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
    "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
)
foreach ($mode in @("", "\Wow6432Node")) {
    $key = "HKLM:\SOFTWARE" + $mode + "\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\"
    foreach($shortcut in $shortcutKeys) {
        $path = ($key + $shortcut)
        if (Test-Path $path) { rm -Force $path | Out-Null }
    }
}
Stop-Process -processname explorer

Write-Output " * Tweaking Console defaults"
sp "HKCU:\Console" -name QuickEdit -value 1 -type dword
sp "HKCU:\Console" -name FaceName -value "Consolas"
sp "HKCU:\Console" -name FontFamily -value 48 -type dword
sp "HKCU:\Console" -name FontSize -value 0xe0000 -type dword
sp "HKCU:\Console" -name HistoryBufferSize -value 100 -type dword
sp "HKCU:\Console" -name CursorSize -value 0x64 -type dword

Write-Output "Complete."
