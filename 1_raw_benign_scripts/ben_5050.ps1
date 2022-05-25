#################################################################################################
# Name			: 	PSVLCRemote.ps1
# Description	: 	
# Author		: 	Axel Anderson
# License		:	
# Date			: 	15.11.2015 created
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#Requires –Version 3
Param   (

			[string]$ScriptConfigPath = ".",
			[string]$StreamConfigPath = "."
		
		)
Set-StrictMode -Version Latest	
#
#################################################################################################
#
# Onedrive Link : http://1drv.ms/1Pdx9TP
#
$script:DebugLevel = 0
#region ScriptVariables
$script:ScriptName		= "PS VLC Remote"
$script:ScriptDate		= "28. Oktober 2016"
$script:ScriptAuthor	= "Axel Anderson"					
$script:ScriptVersion	= "0.9.2.0"
$script:ConfigVersion	= "1"

$PSVLCRemoteVersion = [System.Version]$script:ScriptVersion

$Script:VersionHistory = @"

        History:
            0.1.0 15.11.2015 Project Start
            0.3.0 02.12.2015 First full functional release
            0.3.1 02.12.2015 Build ProgressBar in FileExplorer, 
                             used for adding directory content to Playlist
            0.3.2 03.12.2015 StatusInfo now_playing will be shown now (e.g. while playing Network Stream in VLC)
            0.3.3 04.12.2015 All images as base64 ressources ... (PSVLCRemoteRessource.ps1)
            0.3.4 05.12.2015 Fatal error on connection-switching, mismatch between local and script-variable
                             First Test with Network-Stream; Stream is fixed !!!!! For the Test-Folks....			
            0.3.5 05.12.2015 - All windows have now the TrayDown-Icon
            0.3.6 06.12.2015 DoubleClick on NotifyIcon shows all Open Windows
            0.3.7 06.12.2015 No StatusRefresh when PlayerWindow is minimized (timer-tick stopped)
            0.3.8 06.12.2015 Contect-Menu for Playlist-Window
            0.3.9 08.12.2015 Context-Menu for FileExplorer-Tree
            0.3.10 13.12.2015 Fehlermeldungen i Connection-Manager
            0.3.11 16.12.2015 New,Edit,Delete Network Streams
            0.3.12 17.12.2015 Opacity in PlayerWindow and PlaylistWindow;
                              RightMouseClick on TrayDown in PlayWindow minimize all PS VLC Windows;
                              F5 + ContextMenu in Fileexplorer-Tree
                              RMC on FileExplorer Icon in PlayerWindow refresh Root in  FileExplorer-Tree (ReLoad)
            0.4.00 17.12.2015 Quick Select Network Streams .... first Beta
            0.4.10 18.12.2015 Quick Select Network Streams fixed, New repeat Icon in MainPlayer, Position and Trackbar in one line, Toogle Favorite fixed
            0.4.20 18.12.2015 MainPlayer a little bit smaller
            0.4.30 19.12.2015 Path for Config and NetworkStram xml (start more than one PSVLCRemote)
            0.4.31 20.12.2015 Tooltip on TrackVolume shows Volume in Percent
                              TrackVolume now enabled on Muting, so you can correct Volume while Muting
            0.4.32 21.12.2015 Muting not Reset on Connection-Change
            0.4.33 23.12.2015 Edit Streamtype, Genre, Rate Fixed
            0.4.34 01.01.2016 Quit VLC on Right-Click at Exit-Button, MessageBox on Close Script and Close VLC
            0.4.35 03.01.2016 DBl-Click on File in File-Explorer Play File (on Dir open Directory)
            0.4.40 07.01.2016 Windows-Bounds Settings centralized
            0.4.50 07.01.2016 Set Track Position Dialog
            0.4.60 11.01.2016 Direct input Netstream URI; Play Settings (most, but still in work)
            0.4.61 15.01.2016 No MessageBox on Close-Script (Wishes from Uwe.....)
            0.4.62 23.01.2016 Get-VLCRemote-Status : Return Audio-/Subtitlestream as Array, if they have only one member
            0.5.00 31.01.2016 Play-Settings ready to use
            0.5.1  02.02.2016 TickFrequency corrected, renew RefreshTick and Failure Tick, Dialog ScriptSettings (without save to disk)
            0.5.2  02.02.2016 Refresh and Opacity in Dialog ScriptSettings, Save and Load to disk
            0.5.3  02.02.2016 Change start of script, check if DefaultConnection is alive, otherwise start with Connection-Manager
            0.6.0  27.02.2016 Marquee implemented, comes without settings to switch between Label and Marquee
            0.6.1   7.05.2016 Marquee Configuration implemented
            0.7.0  19.09.2016 Theme implemented (Standard and Dark)
			0.8.0  21.09.2016 Import NetworkStreams online from http://www.listenlive.eu or offline from  http://www.radio-browser.info/gui/#/ - MariaDB SQL Dumps 
			0.8.0 - 0.8.8	  Code Cleaning, Some Bugs, NetStreamFile-Manager, TrackerLabel instead of TitleBar in MainPlayer 
			0.8.9  16.10.2016 Import from  listenlive.eu
            0.9.0  27.10.2016 Enable Folder Play as DVD if Folder contains VIDEO_TS.IFO or conatins subolder VIDEO_TS with VIDEO_TS.IFO
			0.9.1.0 28.10.2016 DVD Control, Check GitHub Version
			0.9.2.0 29.10.2016 Import from Radio-Browser.info
"@
<#
        ToDo:
            : OPEN   : Mini-Player
            : OPEN   : Save/Restore Playlist .... 
#>
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#Script Information
$script:WorkingFileName = $MyInvocation.MyCommand.Definition
$script:WorkingDirectory = Split-Path $script:WorkingFileName -Parent

#
# THIS IS IMPORTTANT, if you use relative Path to WorkingDirectory
# 
Set-Location $script:WorkingDirectory



$Script:VersionText = @"

Powershell VLC Remote Control
		
Author          : $($script:ScriptAuthor)
Version         : $($script:ScriptVersion)
ReleaseDate     : $($script:ScriptDate)

License         : CC BY-NC 4.0 (Namensnennung-Nicht kommerziell 4.0)
http://creativecommons.org/licenses/by-nc/4.0/deed.de

"@

$Script:MarqueeAvailable = $False

#end region ScriptVariables

Function Show-MessageBox {
	param ($title,$text,$buttons="OK",$icon="None")
	 
	$FormsAssembly = [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	 
	$dialogButtons = @{
	 "OK"=[Windows.Forms.MessageBoxButtons]::OK;
	 "OKCancel"=[Windows.Forms.MessageBoxButtons]::OKCancel;
	 "AbortRetryIgnore"=[Windows.Forms.MessageBoxButtons]::AbortRetryIgnore;
	 "YesNoCancel"=[Windows.Forms.MessageBoxButtons]::YesNoCancel;
	 "YesNo"=[Windows.Forms.MessageBoxButtons]::YesNo;
	 "RetryCancel"=[Windows.Forms.MessageBoxButtons]::RetryCancel }
	 
	$dialogIcons = @{
	 "None"=[Windows.Forms.MessageBoxIcon]::None
	 "Hand"=[Windows.Forms.MessageBoxIcon]::Hand
	 "Question"=[Windows.Forms.MessageBoxIcon]::Question
	 "Exclamation"=[Windows.Forms.MessageBoxIcon]::Exclamation
	 "Asterisk"=[Windows.Forms.MessageBoxIcon]::Asterisk
	 "Stop"=[Windows.Forms.MessageBoxIcon]::Stop
	 "Error"=[Windows.Forms.MessageBoxIcon]::Error
	 "Warning"=[Windows.Forms.MessageBoxIcon]::Warning
	 "Information"=[Windows.Forms.MessageBoxIcon]::Information
	}
	 
	$dialogResponses = @{
	 [System.Windows.Forms.DialogResult]::None="None";
	 [System.Windows.Forms.DialogResult]::OK="Ok";
	 [System.Windows.Forms.DialogResult]::Cancel="Cancel";
	 [System.Windows.Forms.DialogResult]::Abort="Abort";
	 [System.Windows.Forms.DialogResult]::Retry="Retry";
	 [System.Windows.Forms.DialogResult]::Ignore="Ignore";
	 [System.Windows.Forms.DialogResult]::Yes="Yes";
	 [System.Windows.Forms.DialogResult]::No="No"
	}
	 
	return $dialogResponses[[Windows.Forms.MessageBox]::Show($text,$title,$dialogButtons[$buttons],$dialogIcons[$icon])]
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Show-MessageYesNoAnswer {
[CmdletBinding()]
Param	(
		[Parameter(Mandatory=$true)][String]$Message
		)
	$d = Show-MessageBox "$script:ScriptName" $Message "YesNo" "Question"
	
	Write-output $d
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Show-ComingSoon {
[CmdletBinding()]
Param	(
		)
	$d = Show-MessageBox "$script:ScriptName" "Coming soon..." "Ok" "Information"
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Test-GithubVersion {
[CmdletBinding()]
Param	(
		)


	Invoke-WebRequest "https://raw.githubusercontent.com/AxelAn/PSVLCRemote/master/PSVLCRemoteVersion.xml" -OutFile (Join-Path $script:WorkingDirectory "GithubVersion.xml")
	
	$GithubVersion = Import-Clixml -Path (Join-Path $script:WorkingDirectory "GithubVersion.xml")
	
	if ($GithubVersion -gt  $PSVLCRemoteVersion) {
		$d = Show-MessageBox "$script:ScriptName" "There is an newer Version available!`n`nhttps://github.com/AxelAn/PSVLCRemote" "Ok" "Information"
	}
	
	Remove-Item (Join-Path $script:WorkingDirectory "GithubVersion.xml")
}
#region MAIN
# #############################################################################
# ##### MAIN
# #############################################################################

#
# PRE-Defined
#
$script:PSVLCRemoteScriptConfigurationPath = $script:WorkingDirectory
$script:PSVLCRemoteStreamConfigurationPath = $script:WorkingDirectory

###############################################################################

. (Join-Path $script:WorkingDirectory PSVLCRemoteLib.ps1)
. (Join-Path $script:WorkingDirectory PSVLCRemoteRessource.ps1)
. (Join-Path $script:WorkingDirectory PSVLCRemoteSettings.ps1)
. (Join-Path $script:WorkingDirectory PSVLCRemoteGUI.ps1)
. (Join-Path $script:WorkingDirectory PSVLCRemoteConnect.ps1)
. (Join-Path $script:WorkingDirectory PSVLCRemoteGUIPlaylist.ps1)
. (Join-Path $script:WorkingDirectory PSVLCRemoteGUIFileExplorer.ps1)
. (Join-Path $script:WorkingDirectory PSVLCRemoteNetworkStreams.ps1)
. (Join-Path $script:WorkingDirectory PSVLCTheme.ps1)
. (Join-Path $script:WorkingDirectory PSVLCRemoteNetworkStreamsImport.ps1)
. (Join-Path $script:WorkingDirectory PSVLCRemoteNetworkStreamsManager.ps1)

if (($ScriptConfigPath -ne ".") -and (Test-Path $ScriptConfigPath)) {
	$script:PSVLCRemoteScriptConfigurationPath = (Resolve-Path $ScriptConfigPath).Path
} 
if (($StreamConfigPath -ne ".") -and (Test-Path $StreamConfigPath)) {
	$script:PSVLCRemoteStreamConfigurationPath = (Resolve-Path $StreamConfigPath).Path
} 

$script:xmlNetworkStreamFilename = Join-Path $script:PSVLCRemoteStreamConfigurationPath $script:xmlNetworkStreamDefaultFilename

if (Test-Path (Join-Path $script:WorkingDirectory PSVLCRemoteMarquee.ps1)) {
. (Join-Path $script:WorkingDirectory PSVLCRemoteMarquee.ps1)
}

#$Script:VersionText | out-Host

$PSVLCRemoteVersion | Export-Clixml -Path (Join-Path $script:WorkingDirectory "PSVLCRemoteVersion.xml")
Test-GithubVersion

$Description	= "LOCALHOST"
$HostnameOrIP	= "LOCALHOST"
$Port			= "8080"
$Password		= "1234"
$UseAutoIP		= "0"	
$script:VLCRemoteConnectionData = $null

Add-Type -AssemblyName PresentationFramework

Load-Settings



if ($script:xmlconfig.Tables["Settings"]) {
	$SettingsObject = $script:xmlconfig.Tables["Settings"]
	if ($SettingsObject) {
		$DefaultConnectionID = $SettingsObject[0].DefaultConnectionID
		if ($DefaultConnectionID -and ($DefaultConnectionID -ne "")) {
			$SettingsObject = $script:xmlconfig.Tables["Connections"].Select(("ID = '"+$DefaultConnectionID+"'"))
			$Description	= $SettingsObject[0].Description
			$HostnameOrIP	= $SettingsObject[0].HostnameOrIP
			$Port			= $SettingsObject[0].Port
			$Password		= $SettingsObject[0].Password
			$UseAutoIP		= $SettingsObject[0].UseAutoIP
			$script:VLCRemoteConnectionData = New-VLCRemoteConnectionDataObject `
													-Description $Description `
													-HostnameOrIP $HostnameOrIP `
													-Port $Port `
													-Username "" `
													-Password $Password `
													-UseAutoIP $UseAutoIP
		}
	}
}

if ($script:VLCRemoteConnectionData -ne $null) {
	if ((Test-Connection $script:VLCRemoteConnectionData.HostnameOrIP $script:VLCRemoteConnectionData.Port $script:VLCRemoteConnectionData.Password)) {
	
		$script:CommonVLCRemoteController = New-VLCRemoteController `
												-HostnameOrIP $script:VLCRemoteConnectionData.HostnameOrIP `
												-Port $script:VLCRemoteConnectionData.Port `
												-Username $script:VLCRemoteConnectionData.Username `
												-Password $script:VLCRemoteConnectionData.Password	`
												-UseAutoIP $script:VLCRemoteConnectionData.UseAutoIP
										

		Show-VLCRemoteMainForm
	} else {
		Manage-VLCRemoteConnections
		
		if ($Script:ConnectionChanged) {
			Show-VLCRemoteMainForm 
		} else {
			Show-MessageConnectionFailed
		}	
	}
} else {
	Manage-VLCRemoteConnections
	
	if ($Script:ConnectionChanged) {
		Show-VLCRemoteMainForm 
	} else {
		Show-MessageConnectionFailed
	}
}

if ($Script:MarqueeAvailable) {
	$script:tmrTickMarquee.Remove_Tick($SBTimeTickMarquee)
}
# #############################################################################
# ##### END MAIN
# #############################################################################
#endregion MAIN
