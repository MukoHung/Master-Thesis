<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.136
	 Created on:   	11/03/2017 8:48 AM
	 Created by:   	Grant Schmarr
	 Organization: 	
	 Filename:     	RemoveXML4v2.ps1
	 Last Modified: 20/03/2017
	 Modifications: Modified logging so that if the script is run a second time
					after cleaning up the first time, it reports if no files or 
					registry entries were found
	===========================================================================
	.DESCRIPTION
		This script prepares a machine for the removal of Microsoft XML4 files 
		and registry settings. It moves the known MS XML4 related files from 
		either system32 or SYSWOW64 folders to a backup folder, exports the 
		registry settings from HKEY_CLASSES_ROOT and HKEY_LOCALMACHINE_SOFTWARE_CLASSES
		and then deletes the registry setting.
　
		If it's found as a result of PIV (Post Implementation Validation) that MS XML4
		is still required, the files can be moved back to the orginal location and the
		exported registry entries can be re-imported.
　
		The script requires administator level credentials to run on a local machine, it
		has not been written to run remotely.
　
		Requirements: Run from a Run As Administrator Powershell command prompt
#>
 
　
　
#region Variables and Arguments
$CurrentTime = Get-Date
$StartTime = Get-Date
$Logname = "XML4RemovalReport.log"
$DefaultPath = "C:\Staging\"
　
# Counters 
$CLSID_Count = 0
$ProgID_Count = 0
$WOWCLSID_Count = 0
$HKLM_ProgIdCount = 0
$HKLM_CLSIDCount = 0
$HKLM_WOWCLSIDCount = 0
　
# Get Operating System information - this determines where to look for the MSXML4 files
$OSInfo = (Get-WmiObject Win32_OperatingSystem -ComputerName $env:COMPUTERNAME)
$OS = $OSInfo.caption
$OSArch = ""
　
# XML 4 file related variables
$FileNames = @("msxml4.dll", "msxml4.inf", "msxml4a.dll", "msxml4r.dll")
$FileCount = 0
$FileLocation = ""
$ArchiveTo = ""
$SysWow = "Windows\SysWoW64"
$Sys32 = "Windows\System32"
　
# Registry related strings
$HKLM = "HKEY_LOCAL_MACHINE"
$HKCU = "HKEY_CURRENT_USER"
$HKCR = "HKEY_CLASSES_ROOT"
$WOW64 = "Wow6432Node"
　
# CLSID - Class ID's for the entries we want to remove
$ClassID1 = "{88d969c0-f192-11d4-a65f-0040963251e5}"
$ClassID2 = "{88d969c4-f192-11d4-a65f-0040963251e5}"
$ClassID3 = "{88d969c1-f192-11d4-a65f-0040963251e5}"
$ClassID4 = "{88d969c9-f192-11d4-a65f-0040963251e5}"
$ClassID5 = "{88d969d6-f192-11d4-a65f-0040963251e5}"
$ClassID6 = "{88d969c8-f192-11d4-a65f-0040963251e5}"
$ClassID7 = "{88d969ca-f192-11d4-a65f-0040963251e5}"
$ClassID8 = "{7c6e29bc-8b8b-4c3d-859e-af6cd158be0f}"
$ClassID9 = "{88d969c6-f192-11d4-a65f-0040963251e5}"
$ClassID10 = "{88d969c5-f192-11d4-a65f-0040963251e5}"
$ClassID11 = "{88d969c2-f192-11d4-a65f-0040963251e5}"
$ClassID12 = "{88d969c3-f192-11d4-a65f-0040963251e5}"
　
# ProgIDs for the entries we want to remove
$ProgID1 = "Msxml2.DOMDocument.4.0"
$ProgID2 = "Msxml2.DSOControl.4.0"
$ProgID3 = "Msxml2.FreeThreadedDOMDocument.4.0"
$ProgID4 = "Msxml2.MXHTMLWriter.4.0"
$ProgID5 = "Msxml2. MXNamespaceManager.4.0"
$ProgID6 = "Msxml2.MXXMLWriter.4.0"
$ProgID7 = "Msxml2.SAXAttributes.4.0"
$ProgID8 = "Msxml2.SAXXMLReader.4.0"
$ProgID9 = "Msxml2.ServerXMLHTTP.4.0"
$ProgID10 = "Msxml2.XMLHTTP.4.0"
$ProgID11 = "Msxml2.XMLSchemaCache.4.0"
$ProgID12 = "Msxml2.XSLTemplate.4.0"
　
# Create arrays to hold our CLSIDs and ProgID's
# These could have been assigned directly but this is somewhat neater code
$CLSID = @(
	$ClassID1, $ClassID2, $ClassID3, $ClassID4, $ClassID5, $ClassID6, $ClassID7, $ClassID8, $ClassID9, $ClassID10, $ClassID11, $ClassID12 )
$PROGID = @(
	$ProgID1, $ProgID2, $ProgID3, $ProgID4, $ProgID5, $ProgID6, $ProgID7, $ProgID8, $ProgID9, $ProgID10, $ProgID11, $ProgID12)
　
# Define variable to contain carriage return and line feed for our text output
$CRLF = "`r`n"
#endregion
　
Function Write-ConLog
{
<# 
    .SYNOPSIS
    This function writes to the console and log file for the script
    .DESCRIPTION
    This function writes to the console and log file for the script
    Normally we would use the tee function for this e.g $TextToWrite | Tee-Object -Append -file $LogFileName
    The default behaviour of the powershell tee function is to overwrite what is in the destination file
    The -append parameter wasn't added until Powershell 3 and as we are supporting Powershell 2 and above
    I've written this function to take the text and write to output and log file
    .PARAMETER TEXT
    The text to be written to the output device and log file
    .PARAMETER LOG
    The name of the log file to which the Text should be written
#>
	[CmdletBinding()]
	param (
		[string]$text,
		[string]$log)
	
	Write-Output $text
	$text >> $log
}
　
　
　
# Check if log folder (Default Path) exists, if not, attempt to create it
if (-Not (Test-path -path $DefaultPath))
{
	New-Item -path "$DefaultPath" -ItemType directory | Out-Null
	Set-Location -Path $DefaultPath
	Write-ConLog "$DefaultPath does not exist. Creating it..." $Logname
}
　
Set-Location -Path $DefaultPath
　
$Message = "XML 4 removal script run by " + $env:USERNAME + " at " + $StartTime.ToShortTimeString() + " on " + $StartTime.ToShortDateString() + "$CRLF"
　
Write-ConLog $Message $Logname
　
　
　
　
　
#region Search for XML4 related files
# Search the Windows folder structure for the XML4 files we need to remove
# Add the files to an array which we will loop through and move to our backup folder
　
Function Move-XML4Files()
{
<#
	.SYNOPSIS
    Searches for MS XML4 files in Windows folder and moves them to a backup folder
    .DESCRIPTION
	This function searches the Windows folder structure for the MSXML4 files we need to remove,
	adds them to an array. Loop through the array and move the file to a designated backup folder.
	This is in preparation for eventual deletion from the system after PIV (Post Implementation Validation)
#>
　
# If the OS is NOT Windows 2003 use the OSArchitecture property (our default)
if ($OS -notlike "*2003*")
{
	$OSArch = $OSInfo.OSArchitecture
}
else
{
	# OS is Windows 2003, use the AddressWidth to construct the architecture
	$OSArch = [string]((Get-WmiObject -Class Win32_Processor).AddressWidth) + "-bit"
}
　
# Locate XML4 related files
　
if ($OSArch -eq "64-bit")
{
	$FileLocation = "C:\$SysWow"
	$ArchiveTo = "$SysWow"
}
else
{
	$FileLocation = "C:\$Sys32"
	$ArchiveTo = "$Sys32"
}
　
　
Write-ConLog "Searching for MSXML4 related files in $FileLocation $CRLF"
　
foreach ($file in $FileNames)
{
	if (Test-Path -Path "$FileLocation\$file")
	{
		Write-ConLog "Found $file - moving to $DefaultPath\$ArchiveTo folder" $LogName
		#Check if our archive folder exists, if not create it
		if (-Not (Test-Path $DefaultPath\$ArchiveTo))
		{
			Write-ConLog "Creating $DefaultPath\$ArchiveTo folder $CRLF" $Logname
			New-Item $DefaultPath\$ArchiveTo -type directory | Out-Null
		}
		Move-Item -Path "$FileLocation\$file" -Destination "$DefaultPath\$ArchiveTo" -Force 
		Write-ConLog "Moved $file to $DefaultPath\$ArchiveTo $CRLF" $Logname
		$script:FileCount++
	}
	else
	{
		Write-ConLog "Did not find $file in $FileLocation folder" $Logname
	}
}
　
Write-ConLog "$CRLF -- File Move Activity Complete -- $CRLF" $Logname
}
#endregion
　
#region Search Registry for XML4 registry entries
# Search for each of the registry entries based on the Microsoft article on XML4 GUIDs and ProgIDs
# https://msdn.microsoft.com/en-us/library/ms754671(v=vs.85).aspx
# Export the registry entries (if present) to our backup folder and then delete the entries 
　
# If it's not already defined, map a new PSDrive to connect to HKEY_CLASSES_ROOT 
# (this is not provided by default in Powershell as we normally only need to access HKLM or HKCU entries)
　
if (!(Test-Path HKCR:))
{
	New-PSDrive -Name HKCR -PSProvider Registry -Root $HKCR | Out-Null
}
　
　
　
# Variables to work with the  Registry Hive we are accessing.
# Powershell uses a different format (Powershell Drive using colon :) than what the reg.exe (Registry editor) uses
# Using the two variables allows us to cater for the differences
# $HivePath will contain the path used by the reg.exe command
# $HiveDrive will contain the path used by powershell to access the PSDrive
# HiveExport will contain the string representation of the path to include in our export file
$HivePath = ""
$HiveDrive = ""
$HiveExport = ""
　
Function Remove-XML4
{
	<#
	.SYNOPSIS
    Searches for registry entries for MS XML4, exports entry then deletes from regisry
    .DESCRIPTION
	This function searches the registry for MS XML4 GUIDs (CLSID) and ProgID's defined in 
	Microsoft article https://msdn.microsoft.com/en-us/library/ms754671(v=vs.85).aspx
	Based on the parameter provided it will either search HKEY_ClASSES_ROOT or
	HKEY_LOCALMACHINE\Software\Classes for the entries to be removed.
	If found, the entry is exported via the reg.exe utility to a pre-defined
	backup folder using the hive, key and subkey as the name for the exported file
	The registry entry is then deleted.
	.PARAMETER - HIVE
	The registry hive that is to be searched for MSXML entries. There are two supported
	options (HKCR and HKLM.)  HKCR will connect to HKEY_CLASSES_ROOT, while HKLM will connect
	to HKEY_LOCALMACHINE\Software\Classes
#>
	
	[CmdletBinding()]
	param (
		[string]$hive)
	
	# If we received the HKEY_LOCALMACHINE parameter, change our variables to suit
	if ($hive -eq "HKLM")
	{
		$HivePath = "HKLM\Software\Classes"
		$HiveDrive = "HKLM:\SOFTWARE\Classes"
        $HiveExport = "HKLM_Software_Classes"
	}
	# Else if we receved the HKEY_CLASSES_ROOT parameter, change our variables to suit
	elseif ($hive -eq "HKCR")
	{
		$HivePath = "HKCR"
		$HiveDrive = "HKCR:"
		$HiveExport = "HKCR"
	}
	
		
	Write-ConLog "Searching for $HivePath\$WOW64\CLSID Entries $CRLF " $Logname
　
# Loop through and find the HKCR\WOW6432Node\CLSID  or HKLM\WOW6432Node\CLSID entries
foreach ($ID in $CLSID)
{
	if (Test-path -path "$HiveDrive\$WOW64\CLSID\$ID")
	{
		Write-ConLog "Found Registry key $HivePath\$WOW64\CLSID\$ID $CRLF" $Logname
		$ExportName = "$HiveExport" + "_$WOW64" + "_CLSID_" + $ID
		reg export "$HivePath\$WOW64\CLSID\$ID" "$DefaultPath\$ExportName.reg"
		Write-ConLog "Exported Registry key $ExportName $CRLF" $Logname
		Write-ConLog "Deleting Registry key $HivePath\$WOW64\CLSID\$ID $CRLF" $Logname
		Remove-Item -Path "$HiveDrive\$WOW64\CLSID\$ID" -Recurse 
		if ($hive -eq "HKCR")
		{
			$script:WOWCLSID_Count++
		}
		elseif ($hive -eq "HKLM")
		{
			$script:HKLM_WOWCLSIDCount++
		}	
	}
	else
	{
		Write-ConLog "Registry key $HivePath\$WOW64\CLSID\$ID NOT found!" $Logname
	}
}
	
	Write-ConLog "$CRLF -- End of $HiveDrive\$WOW64\CLSID Cleanup --$CRLF" $Logname
　
# Loop through and find the ProgID entries in the registry, if found, export to a reg file then delete key
Write-ConLog "Searching for $HivePath\ProgID Entries $CRLF " $Logname
　
foreach ($ID in $PROGID)
{
	if (Test-Path -Path "$HiveDrive\$ID")
	{
		Write-ConLog "Found Registry key $HivePath\$ID $CRLF" $Logname
        $ExportName = "$HiveExport" + "_" + "$ID.reg"
		reg export "$HivePath\$ID" "$DefaultPath\$ExportName.reg"
		Write-ConLog "Exported Registry key $HivePath\$ID $CRLF" $Logname
		Write-ConLog "Deleting Registry key $HivePath\$ID $CRLF" $Logname
		Remove-Item -Path "$HiveDrive\$ID" -Recurse 
		if ($hive -eq "HKCR")
		{
			$script:ProgID_Count++
		}
		elseif ($hive -eq "HKLM")
		{
			$script:HKLM_ProgIdCount++
		}
		
	}
	else
	{
		Write-ConLog "Registry key HKCR\$ID NOT found!" $Logname
	}
}
	
	Write-ConLog "$CRLF -- End of Registry Cleanup --$CRLF" $Logname
	
}
#endregion
　
　
# First call the Move-XML4Files function to move move the files to our backup folder
Move-XML4Files
　
# Backup the MSXML4 registry entries then delete the MSXML4 related entries from HKEY_Classes_Root
# HKEY_CLASSES_Root is the result of merging from HKLM\Software\Classes and the HKCU\Software\Classes hives
Remove-XML4("HKCR")
　
# Backup the MSXML4 registry entries then delete the MSXML4 related entries from HKEY_LOCALMACHINE\Software\Classes
Remove-XML4("HKLM")
　
#region Summary Report
# Summarise the results of the script execution
# Get the size of the arrays containing our registry and file information
$FilesExpected = $FileNames.Length
$CLSIDsExpected = $CLSID.Length
$WOW64Expected = $CLSID.Length
$PROGIDsExpected = $PROGID.Length
　
$Message = "Files Expected:   $FilesExpected $CRLF"
$Message += "Files Found:      $FileCount $CRLF"
$Message += "Wow64 Expected:   $WOW64Expected $CRLF"
$Message += "Wow64 Found:      $WOWCLSID_Count $CRLF"
$Message += "ProgIDs Expected: $PROGIDsExpected $CRLF"
$Message += "ProgIDs Found:    $ProgID_Count $CRLF $CRLF"
　
# If the files found was not equal to the number expected display a message
# unless none of the expected files were found
if ($FileCount -lt $FilesExpected -and $FileCount -ne 0)
{
	$Message += "The number of files found did not match expected result. $CRLF"
	$Message += "Please check $FileLocation to cofirm no MSXML4*.* files remain $CRLF"
}
else
{
	$Message += "No MSXML4 files were found. $CRLF"
}
　
if ($WOWCLSID_Count -ne $ProgID_Count -and $WOWCLSID_Count -ne 0 -and $ProgID_Count -ne 0)
{
	$Message += "The GUID's cleaned up did not match the ProgID's cleaned up. Normally they should match. $CRLF"
	$Message += "Please check the Microsoft article https://msdn.microsoft.com/en-us/library/ms754671(v=vs.85).aspx $CRLF"
}
else
{
	$Message += "No MS XML4 registry entries were found."	
}
　
Write-ConLog  $Message $Logname
　
$endTime = Get-Date
　
$Message = "Script completed at " + $endTime.ToShortTimeString() + " on " + (Get-Date).ToShortDateString() + "$CRLF"
　
# Measure the time between script start and completion
$timespan = (New-TimeSpan -Start $StartTime -End $endTime)
　
$days = $timespan.Days
$hours = $timespan.Hours
$minutes = $timespan.Minutes
$seconds = $timespan.Seconds
　
$Message += "Script took $days days, $hours hours, $minutes minutes and $seconds seconds to complete $CRLF"
　
#Write total execution time to log
Write-ConLog $Message $Logname
　
"------ END OF REPORT ------$CRLF" >> $Logname
　
Write-Output "The result of this command can be seen in $(Get-Location)\$Logname $CRLF"
#endregion