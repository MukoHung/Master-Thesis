# Windows 10 Unbloating
# Inspired by:
# https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/remove-default-apps.ps1
# https://github.com/Disassembler0/Win10-Initial-Setup-Script/blob/master/Win10.ps1

# Uninstall default Microsoft applications
$MsftBloatApps =  @(
	"Microsoft.3DBuilder"
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
	"Microsoft.Windows.Photos"
	"Microsoft.WindowsAlarms"
	"Microsoft.WindowsCamera"
	"microsoft.windowscommunicationsapps"
	"Microsoft.WindowsMaps"
	"Microsoft.WindowsPhone"
	"Microsoft.WindowsSoundRecorder"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"Microsoft.AppConnector"
	"Microsoft.ConnectivityStore"
	"Microsoft.Office.Sway"
	"Microsoft.Messaging"
	"Microsoft.CommsPhone"
	"Microsoft.MicrosoftStickyNotes"
	"Microsoft.OneConnect"
	"Microsoft.WindowsFeedbackHub"
	"Microsoft.MinecraftUWP"
	"Microsoft.MicrosoftPowerBIForWindows"
	"Microsoft.NetworkSpeedTest"
	"Microsoft.MSPaint"
	"Microsoft.Microsoft3DViewer"
	"Microsoft.RemoteDesktop"
	"Microsoft.Print3D"
)

# Uninstall default third party applications
$ThirdPartyBloatApps = @(
	"9E2F88E3.Twitter"
	"king.com.CandyCrushSodaSaga"
	"4DF9E0F8.Netflix"
	"Drawboard.DrawboardPDF"
	"D52A8D61.FarmVille2CountryEscape"
	"GAMELOFTSA.Asphalt8Airborne"
	"flaregamesGmbH.RoyalRevolt2"
	"AdobeSystemsIncorporated.AdobePhotoshopExpress"
	"ActiproSoftwareLLC.562882FEEB491"
	"D5EA27B7.Duolingo-LearnLanguagesforFree"
	"Facebook.Facebook"
	"46928bounde.EclipseManager"
	"A278AB0D.MarchofEmpires"
	"KeeperSecurityInc.Keeper"
	"king.com.BubbleWitch3Saga"
	"89006A2E.AutodeskSketchBook"
	"CAF9E577.Plex"
	"A278AB0D.DisneyMagicKingdoms"
	"828B5831.HiddenCityMysteryofShadows"
)

# Uninstall Windows Store
$WindowsStoreApps =@(
	"Microsoft.DesktopAppInstaller"
	"Microsoft.WindowsStore"
)

$XboxFeaturesApps = @(
	"Microsoft.XboxApp"
	"Microsoft.XboxIdentityProvider"
	"Microsoft.XboxSpeechToTextOverlay"
	"Microsoft.XboxGameOverlay"
	"Microsoft.Xbox.TCUI"

)

#Remove Microsoft Bloat Apps
foreach ($MsftBloatApp in $MsftBloatApps) {

    Get-AppxPackage -Name $MsftBloatApp -AllUsers | Remove-AppxPackage -AllUsers

    Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ $MsftBloatApp | Remove-AppxProvisionedPackage -Online
}

#Remove Third Party Apps
foreach ($ThirdPartyBloatApp in $ThirdPartyBloatApps) {

    Get-AppxPackage -Name $ThirdPartyBloatApp -AllUsers | Remove-AppxPackage -AllUsers

    Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ $ThirdPartyBloatApp | Remove-AppxProvisionedPackage -Online
}

#Remove Windows Store App
foreach ($WindowsStoreApp in $WindowsStoreApps) {

    Get-AppxPackage -Name $WindowsStoreApp -AllUsers | Remove-AppxPackage -AllUsers

    Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ $WindowsStoreApp | Remove-AppxProvisionedPackage -Online
}

#Remove Xbox Apps
foreach ($XboxFeaturesApp in $XboxFeaturesApps) {

    Get-AppxPackage -Name $XboxFeaturesApp -AllUsers | Remove-AppxPackage -AllUsers

    Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ $XboxFeaturesApp | Remove-AppxProvisionedPackage -Online
}

#Disable Xbox gaming features
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

# Uninstall Windows Media Player
Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue

# Disable search for app in store for unknown extensions
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1



#Disable Telemetry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0


#Disable Wi-Fi Sense
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {

	New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null

}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0

#Disable Bing Search in Start Menu
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {

	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null

}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
