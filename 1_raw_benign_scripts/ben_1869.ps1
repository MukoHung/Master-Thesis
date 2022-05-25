#requires -version 4.0
#requires -modules Storage,DISM
#Requires -RunAsAdministrator
<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.117
	 Created on:   	3/16/2016 10:05
	 Created by:   	Colin Squier <hexalon@gmail.com>
	 Filename:     	Imaging-Win10.ps1
	===========================================================================
	.DESCRIPTION
		Provides interactive/automated imaging operations using DISM and WinPE.
		Images are stored as a WIM file.
	
		TODO:
			-Add support for capturing image to UNC path
			-Better error handling for DISM
			-Capture to a VHD
#>
　
[CmdletBinding()]
Param (
	[switch]$Capture = $false,
	[switch]$Apply = $false
)
　
<#
	.SYNOPSIS
		Captures a image to a WIM.
	
	.DESCRIPTION
		Captures a image from a hard drive using DISM to a WIM.
	
	.PARAMETER SourceDrive
		Hard drive letter to capture
	
	.PARAMETER ImageDestination
		File path to store captured image.
	
	.EXAMPLE
		PS C:\> CaptureImage -SourceDrive "C:" -ImageDestination "D:\Images\Capture.wim"
	
	.NOTES
		Function has only been tested on WinPE 10 running PowerShell 5.
#>
function CaptureImage($SourceDrive, $ImageDestination, [switch]$Force)
{
	if ($Force)
	{
		Write-Verbose -Message "Image is being captured from $SourceDrive"
		Start-Process -FilePath "dism.exe" -ArgumentList "/Capture-Image /ImageFile:$ImageDestination /CaptureDir:$SourceDrive /Name:`"WIM`" /Compress:Maximum" -Wait -NoNewWindow -ErrorAction Stop
	}
	else
	{
		Do
		{
			#Configure yes choice
			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Capture image."
			#Configure no choice
			$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Return to menu."
			#Determine Values for choice
			$choice = [System.Management.Automation.Host.ChoiceDescription[]] @($yes, $no)
			#Determine Default Selection
			[int]$default = 0
			#Present choice option to user 
			$userchoice = $host.ui.PromptforChoice("Information", "Capture image", $choice, $default)
			
			switch ($userchoice)
			{
				0
				{
					Write-Verbose -Message "Image is being captured from $SourceDrive"
					Start-Process -FilePath "dism.exe" -ArgumentList "/Capture-Image /ImageFile:$ImageDestination /CaptureDir:$SourceDrive /Name:`"WIM`" /Compress:Maximum" -Wait -NoNewWindow -ErrorAction Stop
				}
				1
				{
					break;
				}
			}
		}
		#If user selects No, then quit the script
		Until ($userchoice -eq 1)
	}
}
　
<#    
    .SYNOPSIS
    Converts a hash table or an array to an ordered dictionary. 
            
    .DESCRIPTION
    ConvertTo-OrderedDictionary takes a hash table or an array and 
    returns an ordered dictionary. 
    
    If you enter a hash table, the keys in the hash table are ordered 
    alphanumerically in the dictionary. If you enter an array, the keys 
    are integers 0 - n.
            
    .PARAMETER  $hash
    Specifies a hash table or an array. Enter the hash table or array, 
    or enter a variable that contains a hash table or array.
　
    .INPUTS
    System.Collections.Hashtable
    System.Array
　
    .OUTPUTS
    System.Collections.Specialized.OrderedDictionary
　
    .EXAMPLE
    PS C:\> $myHash = @{a=1; b=2; c=3}
    PS C:\> .\ConvertTo-OrderedDictionary.ps1 -Hash $myHash
　
    Name                           Value                                                                                                                                                           
    ----                           -----                                                                                                                                                           
    a                              1                                                                                                                                                               
    b                              2                                                                                                                                                               
    c                              3                          
　
    .EXAMPLE
    PS C:\> $myHash = @{a=1; b=2; c=3}
    PS C:\> $myHash = .\ConvertTo-OrderedDictionary.ps1 -Hash $myHash
    PS C:\> $myHash
　
    Name                           Value                                                                                                                                                           
    ----                           -----                                                                                                                                                           
    a                              1                                                                                                                                                               
    b                              2                                                                                                                                                               
    c                              3
                  
　
    PS C:\> $myHash | Get-Member
    
       TypeName: System.Collections.Specialized.OrderedDictionary
       . . .
　
    .EXAMPLE
    PS C:\> $colors = "red", "green", "blue"
    PS C:\> $colors = .\ConvertTo-OrderedDictionary.ps1 -Hash $colors
    PS C:\> $colors
　
    Name                           Value                                                                                                                                                           
    ----                           -----                                                                                                                                                           
    0                              red                                                                                                                                                             
    1                              green                                                                                                                                                           
    2                              blue 
　
 
    .LINK
    about_hash_tables
#>
function ConvertTo-OrderedDictionary
{
	Param
	(
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		$Hash
	)
	
	if ($Hash -is [System.Collections.Hashtable])
	{
		$dictionary = [ordered]@{ }
		$keys = $Hash.keys | Sort-Object
		
		foreach ($key in $keys)
		{
			$dictionary.add($key, $Hash[$key])
		}
		
		return $dictionary
	}
	elseif ($Hash -is [System.Array])
	{
		$dictionary = [ordered]@{ }
		
		for ($i = 0; $i -lt $hash.count; $i++)
		{
			$dictionary.add($i, $hash[$i])
		}
		
		return $dictionary
	}
	else
	{
		Write-Error "Enter a hash table or an array."
	}
}
　
<#
	.SYNOPSIS
		Applies a image from a WIM.
	
	.DESCRIPTION
		Formats destination drive, creates new partitions and applies captured
		image.
	
	.PARAMETER SourceImage
		Image file to be deployed.
	
	.PARAMETER Force
		Deploy with out asking user to confirm actions.
	
	.PARAMETER Win7
		Deply a Windows 7 image instead of Windows 10.
　
	.PARAMETER EFI
		Deploy to a UEFI based computer.
	
	.PARAMETER ImagePath
		File path for captured image.
	
	.EXAMPLE
		PS C:\> DeployImage -ImagePath "D:\Images\Capture.wim"
	
	.NOTES
		Function has only been tested on WinPE 10 running PowerShell 5.	Function
		assumes that the computer only has one physical hard drive.
#>
function DeployImage($SourceImage, [switch]$Force, [switch]$Win7, [switch]$EFI)
{
	#Prepare disk
	if ($Force)
	{
		$ConfirmPreference = "None"
		$PSDefaultParameterValues = @{ "*:confirm" = $false }
		
		$IsDiskPrepared = $true
		
		#Check for new disk (RAW partition style)
		$NewDisk = (Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" })
		if (($NewDisk.PartitionStyle -eq "RAW"))
		{
			$DiskName = $NewDisk.FriendlyName
			$DiskNumber = $NewDisk.DiskNumber
			Write-Verbose -Message "New disk detected, initializing"
			Write-Verbose -Message "Preparing drive number $DiskNumber, from $DiskName with force."
			if ($EFI)
			{
				Write-Verbose "Initializing disk as GPT"
				Initialize-Disk -Number $DiskNumber -PartitionStyle GPT -Verbose -Confirm:$false -ErrorAction Stop
				$IsDiskPrepared = $false
			}
			else
			{
				Write-Verbose "Initializing disk as MBR"
				Initialize-Disk -Number $DiskNumber -PartitionStyle MBR -Verbose -Confirm:$false -ErrorAction Stop
				$IsDiskPrepared = $false
			}
		}
		#Check for EFI flag
		if ($EFI)
		{
			$Disk = (Get-Disk | Where-Object { $_.IsBoot -ne $true -and $_.ProvisioningType -eq "Fixed" -and ($_.BusType -eq "SATA" -or $_.BusType -eq "ATA" -or $_.BusType -eq "NVMe") })
			$DiskName = $Disk.FriendlyName
			$DiskNumber = $Disk.DiskNumber
			if ($IsDiskPrepared)
			{
				Write-Verbose -Message "Preparing drive number $DiskNumber, from $DiskName with force"
				Get-Disk $DiskNumber | Clear-Disk -RemoveData -RemoveOEM -Verbose -Confirm:$false -ErrorAction Stop
				Write-Verbose "Initializing disk as GPT"
				Initialize-Disk -Number $DiskNumber -PartitionStyle GPT -Verbose -Confirm:$false -ErrorAction Stop
			}
			Write-Verbose "Creating Extensible Firmware Interface (EFI) partitions"
						
			#create the RE Tools partition
			Write-Verbose "Creating a Recovery tools partition on disk number $DiskNumber"
			New-Partition -DiskNumber $DiskNumber -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -Size 300MB | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Windows RE Tools" -Confirm:$false -ErrorAction Stop | Out-Null
			$PartitionNumber = (Get-Disk $DiskNumber | Get-Partition | Where { $_.type -eq 'Recovery' }).PartitionNumber
			Write-Verbose "Retrieved WinRE partition number $PartitionNumber"
			
			#Run diskpart to set GPT attribute to prevent partition removal
@"
select disk $DiskNumber
select partition $PartitionNumber
gpt attributes=0x8000000000000001
exit
"@ | diskpart | ForEach-Object{ Write-Verbose "[DiskPart] $_" }
			
			#create the system partition
			Write-Verbose "Creating System partition"
			$PartitionSystem = New-Partition -DiskNumber $DiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -Size 100MB -ErrorAction Stop
			Format-Volume -Partition $PartitionSystem -FileSystem FAT32 -Force -NewFileSystemLabel "System" -Confirm:$false -ErrorAction Stop
			$PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' -ErrorAction Stop
			$PartitionNumber = $PartitionSystem.PartitionNumber
			Write-Verbose "Retrieved system partition number $PartitionNumber"
			
			#create MSR
			Write-Verbose "Creating MSR partition"
			New-Partition -DiskNumber $DiskNumber -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}' -Size 128MB -ErrorAction Stop | Out-Null
			
			#create OS partition
			Write-Verbose "Creating OS partition"
			New-Partition -DiskNumber $DiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem ntfs -NewFileSystemLabel "Windows 10" -confirm:$false -ErrorAction Stop | Out-Null
			$Drive = (Get-Volume | Where-Object { $_.FileSystemLabel -eq 'Windows 10' })
			$Drive = $Drive.DriveLetter + ":\"
			Write-Verbose "OS volume is '$Drive'"
		}
		else
		{
			Initialize-Disk -Number $DiskNumber -PartitionStyle MBR -Verbose -Confirm:$false -ErrorAction Stop
			New-Partition -DiskNumber $DiskNumber -Size 100MB -IsActive -DriveLetter S | Format-Volume -FileSystem ntfs -NewFileSystemLabel "System" -Verbose -Confirm:$false -ErrorAction Stop
			if ($Win7)
			{
				New-Partition -DiskNumber $DiskNumber -UseMaximumSize -IsActive -DriveLetter W | Format-Volume -FileSystem ntfs -NewFileSystemLabel "Windows 7" -Verbose -Confirm:$false -ErrorAction Stop
				$Drive = (Get-Volume | Where-Object { $_.FileSystemLabel -eq 'Windows 7' })
				$Drive = $Drive.DriveLetter + ":\"
				Write-Verbose "OS volume is '$Drive'"
			}
			else
			{
				New-Partition -DiskNumber $DiskNumber -UseMaximumSize -IsActive -DriveLetter W | Format-Volume -FileSystem ntfs -NewFileSystemLabel "Windows 10" -Verbose -Confirm:$false -ErrorAction Stop
				$Drive = (Get-Volume | Where-Object { $_.FileSystemLabel -eq 'Windows 10' })
				$Drive = $Drive.DriveLetter + ":\"
				Write-Verbose "OS volume is '$Drive'"
			}
		}
	}
	else
	{
		$IsDiskPrepared = $true
		
		#Check for new disk (RAW partition style)
		$NewDisk = (Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" })
		if (($NewDisk.PartitionStyle -eq "RAW"))
		{
			$DiskName = $NewDisk.FriendlyName
			$DiskNumber = $NewDisk.DiskNumber
			Write-Verbose -Message "New disk detected, initializing"
			Write-Verbose -Message "Preparing drive number $DiskNumber, from $DiskName"
			if ($EFI)
			{
				Write-Verbose "Initializing disk as GPT"
				Initialize-Disk -Number $DiskNumber -PartitionStyle GPT -Verbose -Confirm:$false -ErrorAction Stop
				$IsDiskPrepared = $false
			}
			else
			{
				Write-Verbose "Initializing disk as MBR"
				Initialize-Disk -Number $DiskNumber -PartitionStyle MBR -Verbose -Confirm:$false -ErrorAction Stop
				$IsDiskPrepared = $false
			}
		}
		#Check for EFI flag
		if ($EFI)
		{
			$Disk = (Get-Disk | Where-Object { $_.IsBoot -ne $true -and $_.ProvisioningType -eq "Fixed" -and ($_.BusType -eq "SATA" -or $_.BusType -eq "ATA" -or $_.BusType -eq "NVMe") })
			$DiskName = $Disk.FriendlyName
			$DiskNumber = $Disk.DiskNumber
			if ($IsDiskPrepared)
			{
				Write-Verbose -Message "Preparing drive number $DiskNumber, from $DiskName"
				Get-Disk $DiskNumber | Clear-Disk -RemoveData -RemoveOEM -Verbose -Confirm:$false -ErrorAction Stop
				Write-Verbose "Initializing disk as GPT"
				Initialize-Disk -Number $DiskNumber -PartitionStyle GPT -Verbose -Confirm:$false -ErrorAction Stop
			}
			Write-Verbose "Creating Extensible Firmware Interface (EFI) partition"
					
			#create the RE Tools partition
			Write-Verbose "Creating a Recovery tools partition on disk number $DiskNumber"
			New-Partition -DiskNumber $DiskNumber -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -Size 300MB | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Windows RE Tools" -ErrorAction Stop | Out-Null
			$PartitionNumber = (Get-Disk $DiskNumber | Get-Partition | Where { $_.type -eq 'Recovery' }).PartitionNumber
			Write-Verbose "Retrieved WinRE partition number $PartitionNumber"
			
			#Run diskpart to set GPT attribute to prevent partition removal
@"
select disk $DiskNumber
select partition $PartitionNumber
gpt attributes=0x8000000000000001
exit
"@ | diskpart | ForEach-Object{ Write-Verbose "[DiskPart] $_" }
			
			#create the system partition
			Write-Verbose "Creating System partition"
			$PartitionSystem = New-Partition -DiskNumber $DiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -Size 100MB -ErrorAction Stop
			Format-Volume -Partition $PartitionSystem -FileSystem FAT32 -Force -NewFileSystemLabel "System" -ErrorAction Stop
			$PartitionSystem | Set-Partition -GptType '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' -ErrorAction Stop
			$PartitionNumber = $PartitionSystem.PartitionNumber
			Write-Verbose "Retrieved system partition number $PartitionNumber"
			
			#create MSR
			Write-Verbose "Creating MSR partition"
			New-Partition -DiskNumber $DiskNumber -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}' -Size 128MB -ErrorAction Stop | Out-Null
			
			#create OS partition
			Write-Verbose "Creating OS partition"
			New-Partition -DiskNumber $DiskNumber -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem ntfs -NewFileSystemLabel "Windows 10" -ErrorAction Stop | Out-Null
			$Drive = (Get-Volume | Where-Object { $_.FileSystemLabel -eq 'Windows 10' })
			$Drive = $Drive.DriveLetter + ":\"
			Write-Verbose "OS volume is '$Drive'"
		}
		else
		{
			Initialize-Disk -Number $DiskNumber -PartitionStyle MBR -Verbose -ErrorAction Stop
			New-Partition -DiskNumber $DiskNumber -Size 100MB -IsActive -DriveLetter S | Format-Volume -FileSystem ntfs -NewFileSystemLabel "System" -Verbose -ErrorAction Stop
			if ($Win7)
			{
				New-Partition -DiskNumber $DiskNumber -UseMaximumSize -IsActive -DriveLetter W | Format-Volume -FileSystem ntfs -NewFileSystemLabel "Windows 7" -Verbose -ErrorAction Stop
				$Drive = (Get-Volume | Where-Object { $_.FileSystemLabel -eq 'Windows 7' })
				$Drive = $Drive.DriveLetter + ":\"
				Write-Verbose "OS volume is '$Drive'"
			}
			else
			{
				New-Partition -DiskNumber $DiskNumber -UseMaximumSize -IsActive -DriveLetter W | Format-Volume -FileSystem ntfs -NewFileSystemLabel "Windows 10" -Verbose -ErrorAction Stop
				$Drive = (Get-Volume | Where-Object { $_.FileSystemLabel -eq 'Windows 10' })
				$Drive = $Drive.DriveLetter + ":\"
				Write-Verbose "OS volume is '$Drive'"
			}
		}
	}
	
	#Apply Image to disk
	Write-Verbose -Message "Image is being deployed from $SourceImage to $($Drive)"
	Start-Process -FilePath "dism.exe" -ArgumentList "/Apply-Image /ImageFile:$SourceImage /Index:1 /ApplyDir:$($Drive)" -Wait -NoNewWindow -ErrorAction Stop
	
	#Show disk layout for debugging purposes
	Write-Verbose "Disk Layout $(Get-Partition -Disk $Disk | Out-String)"
	
	#Make drive bootable
	if ($EFI)
	{
		$Drive = (Get-Volume | Where-Object { $_.FileSystemLabel -eq 'Windows 10' })
		$Drive = $Drive.DriveLetter + ":\Windows"
		
		Write-Verbose "Creating a new BCD store"
		Start-Process "bcdboot.exe" -ArgumentList "$Drive" -NoNewWindow -Wait -ErrorAction Stop
	}
	else
	{
		Write-Verbose -Message "Writing boot record"
		Start-Process -FilePath "bcdboot.exe" -ArgumentList "W:\Windows /s S:" -Wait -NoNewWindow -ErrorAction Stop
	}
	
	if ($Force -or $Apply)
	{
		Write-Verbose -Message "Rebooting computer"
		Start-Process -FilePath "wpeutil" -ArgumentList "reboot" -Wait -NoNewWindow -ErrorAction SilentlyContinue
	}
}
　
<#
	.SYNOPSIS
		Retrieves hard drive information.
	
	.DESCRIPTION
		Retrieves hard drive information, by enumerating all fixed hard drives
		on the specified computer.
	
	.PARAMETER Comp
		The computer to query.
	
	.EXAMPLE
		PS C:\> Get-DriveInfo -Comp $Computer1
#>
function Get-DriveInfo
{
	Param ($Comp,
		[int]$DriveType)
	
	Try
	{
		$data = (Get-WmiObject -Class Win32_Volume -Filter "DriveType=$DriveType" -ErrorAction Stop)
		Foreach ($drive in $data)
		{
			#format size and freespace
			$Size = "{0:N2}" -f ($drive.capacity/1GB)
			$Freespace = "{0:N2}" -f ($drive.Freespace/1GB)
			#Define a hashtable to be used for property names and values
			$hash = @{
				Computername = $drive.SystemName
				Drive = $drive.Name
				FreeSpace = $Freespace
				Label = $drive.label
				Size = $Size
			}
			#create a custom object from the hash table
			$obj = New-Object -TypeName PSObject -Property $hash
			#Add a type name to the object
			$obj.PSObject.TypeNames.Insert(0, 'System.DiskInfo')
			$obj
		} #foreach
		#clear $data for next computer
		Remove-Variable -Name data
	} #Try
	Catch
	{
		#create an error message
		$msg = "Failed to get volume information from $Comp.
                $($_.Exception.Message)"
		Write-Error -Message $msg
	}
}
　
<#
	.SYNOPSIS
		Creates a simple text based menu.
	
	.DESCRIPTION
		Creates a simple text based menu, stored as a hashtable and returns a string.
	
	.PARAMETER MenuTitle
		Menu title of type string.
	
	.PARAMETER MenuEntries
		Semi-colon delimited list of entries of type hashtable.
	
	.EXAMPLE
		PS C:\> ShowMenu -MenuTitle "Choose your favorite Band" -MenuEntries @{"sl"="Slayer";"me"="Metallica"}
	
	.NOTES
		Simple Textbased Powershell Menu
		Author : Michael Albert
		E-Mail : info@michlstechblog.info
		License: none, feel free to modify
#>
function ShowMenu([System.String]$MenuTitle, [System.Collections.Hashtable]$MenuEntries)
{
	# Orginal Konsolenfarben zwischenspeichern
	[System.Int16]$iSavedBackgroundColor = [System.Console]::BackgroundColor
	[System.Int16]$iSavedForegroundColor = [System.Console]::ForegroundColor
	# Menu Colors
	# inverse fore- and backgroundcolor 
	[System.Int16]$iMenuForeGroundColor = $iSavedForegroundColor
	[System.Int16]$iMenuBackGroundColor = $iSavedBackgroundColor
	[System.Int16]$iMenuBackGroundColorSelectedLine = $iMenuForeGroundColor
	[System.Int16]$iMenuForeGroundColorSelectedLine = $iMenuBackGroundColor
	# Alternative, colors
	#[System.Int16]$iMenuBackGroundColor=0
	#[System.Int16]$iMenuForeGroundColor=7
	#[System.Int16]$iMenuBackGroundColorSelectedLine=10
	# Init
	[System.Int16]$iMenuStartLineAbsolute = 0
	[System.Int16]$iMenuLoopCount = 0
	[System.Int16]$iMenuSelectLine = 1
	[System.Int16]$iMenuEntries = $MenuEntries.Count
	[Hashtable]$hMenu = @{ };
	[Hashtable]$hMenuHotKeyList = @{ };
	[Hashtable]$hMenuHotKeyListReverse = @{ };
	
	$MenuEntries = ConvertTo-OrderedDictionary -Hash $MenuEntries
	
	[System.Int16]$iMenuHotKeyChar = 0
	[System.String]$sValidChars = ""
	[System.Console]::WriteLine(" " + $MenuTitle)
	# Für die eindeutige Zuordnung Nummer -> Key
	$iMenuLoopCount = 1
	# Start Hotkeys mit "1"!
	$iMenuHotKeyChar = 49
	foreach ($sKey in $MenuEntries.Keys)
	{
		$hMenu.Add([System.Int16]$iMenuLoopCount, [System.String]$sKey)
		# Hotkey zuordnung zum Menueintrag
		$hMenuHotKeyList.Add([System.Int16]$iMenuLoopCount, [System.Convert]::ToChar($iMenuHotKeyChar))
		$hMenuHotKeyListReverse.Add([System.Convert]::ToChar($iMenuHotKeyChar), [System.Int16]$iMenuLoopCount)
		$sValidChars += [System.Convert]::ToChar($iMenuHotKeyChar)
		$iMenuLoopCount++
		$iMenuHotKeyChar++
		# Weiter mit Kleinbuchstaben
		if ($iMenuHotKeyChar -eq 58) { $iMenuHotKeyChar = 97 }
		# Weiter mit Großbuchstaben
		elseif ($iMenuHotKeyChar -eq 123) { $iMenuHotKeyChar = 65 }
		# Jetzt aber ende
		elseif ($iMenuHotKeyChar -eq 91)
		{
			Write-Error " Menu too big!"
			exit (99)
		}
	}
	# Remember Menu start
	[System.Int16]$iBufferFullOffset = 0
	$iMenuStartLineAbsolute = [System.Console]::CursorTop
	do
	{
		####### Draw Menu  #######
		[System.Console]::CursorTop = ($iMenuStartLineAbsolute - $iBufferFullOffset)
		for ($iMenuLoopCount = 1; $iMenuLoopCount -le $iMenuEntries; $iMenuLoopCount++)
		{
			[System.Console]::Write("`r")
			[System.String]$sPreMenuline = ""
			$sPreMenuline = "  " + $hMenuHotKeyList[[System.Int16]$iMenuLoopCount]
			$sPreMenuline += ": "
			if ($iMenuLoopCount -eq $iMenuSelectLine)
			{
				[System.Console]::BackgroundColor = $iMenuBackGroundColorSelectedLine
				[System.Console]::ForegroundColor = $iMenuForeGroundColorSelectedLine
			}
			if ($MenuEntries.Item([System.String]$hMenu.Item($iMenuLoopCount)).Length -gt 0)
			{
				[System.Console]::Write($sPreMenuline + $MenuEntries.Item([System.String]$hMenu.Item($iMenuLoopCount)))
			}
			else
			{
				[System.Console]::Write($sPreMenuline + $hMenu.Item($iMenuLoopCount))
			}
			[System.Console]::BackgroundColor = $iMenuBackGroundColor
			[System.Console]::ForegroundColor = $iMenuForeGroundColor
			[System.Console]::WriteLine("")
		}
		[System.Console]::BackgroundColor = $iMenuBackGroundColor
		[System.Console]::ForegroundColor = $iMenuForeGroundColor
		[System.Console]::Write("  Your choice: ")
		if (($iMenuStartLineAbsolute + $iMenuLoopCount) -gt [System.Console]::BufferHeight)
		{
			$iBufferFullOffset = ($iMenuStartLineAbsolute + $iMenuLoopCount) - [System.Console]::BufferHeight
		}
		####### End Menu #######
		####### Read Kex from Console 
		$oInputChar = [System.Console]::ReadKey($true)
		# Down Arrow?
		if ([System.Int16]$oInputChar.Key -eq [System.ConsoleKey]::DownArrow)
		{
			if ($iMenuSelectLine -lt $iMenuEntries)
			{
				$iMenuSelectLine++
			}
		}
		# Up Arrow
		elseif ([System.Int16]$oInputChar.Key -eq [System.ConsoleKey]::UpArrow)
		{
			if ($iMenuSelectLine -gt 1)
			{
				$iMenuSelectLine--
			}
		}
		elseif ([System.Char]::IsLetterOrDigit($oInputChar.KeyChar))
		{
			[System.Console]::Write($oInputChar.KeyChar.ToString())
		}
		[System.Console]::BackgroundColor = $iMenuBackGroundColor
		[System.Console]::ForegroundColor = $iMenuForeGroundColor
	}
	while (([System.Int16]$oInputChar.Key -ne [System.ConsoleKey]::Enter) -and ($sValidChars.IndexOf($oInputChar.KeyChar) -eq -1))
	
	# reset colors
	[System.Console]::ForegroundColor = $iSavedForegroundColor
	[System.Console]::BackgroundColor = $iSavedBackgroundColor
	if ($oInputChar.Key -eq [System.ConsoleKey]::Enter)
	{
		[System.Console]::Writeline($hMenuHotKeyList[$iMenuSelectLine])
		return ([System.String]$hMenu.Item($iMenuSelectLine))
	}
	else
	{
		[System.Console]::Writeline("")
		return ($hMenu[$hMenuHotKeyListReverse[$oInputChar.KeyChar]])
	}
}
　
$Storage = (Get-DriveInfo -Comp $env:COMPUTERNAME -DriveType 3)
$USB = (Get-DriveInfo -Comp $env:COMPUTERNAME -DriveType 2)
$Drive = $Storage | ForEach-Object { $_.Drive }
$TargetLabel = $USB | Where-Object { $_.Label -eq "Images" }
$SourceLabel = $Storage | Where-Object { $_.Label -eq "Windows 10" }
if ($null -eq $SourceLabel)
{
	$SourceLabel = $Storage | Where-Object { $_.Label -eq "Windows 7" }
}
$SystemLabel = $Storage | Where-Object { $_.Label -eq "SYSTEM" }
$SourceDrive = $SourceLabel.Drive
$ImageDrive = $TargetLabel.Drive
$SystemDrive = $SystemLabel.Drive
$ImageFileName = "Win10.wim"
$Win7FileName = "Win7.wim"
$ImagePath = (Join-Path -Path $ImageDrive -ChildPath "Images\$ImageFileName")
$Win7ImagePath = (Join-Path -Path $ImageDrive -ChildPath "Images\$Win7FileName")
　
Write-Verbose -Message "Image path is $ImagePath"
　
$PEFirmwareType = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name PEFirmwareType
if ($PEFirmwareType -eq 1)
{
	Write-Verbose "Computer is booted in BIOS mode"
	$EFI = $false
}
elseif ($PEFirmwareType -eq 2)
{
	Write-Verbose "Computer is booted in UEFI mode"
	$EFI = $true
}
　
if ($EFI)
{
	DeployImage -SourceImage $ImagePath -Force -EFI
	break
}
　
if ($Apply)
{
	DeployImage -SourceImage $ImagePath -Force
	break
}
　
if ($Capture)
{
	CaptureImage -SourceDrive $SourceDrive -ImageDestination $ImagePath -Force
	break
}
　
Do
{
	$Choice = (ShowMenu -MenuTitle "Select imaging operation" -MenuEntries @{ "di" = "Deploy Image"; "di7" = "Deploy Image - Win7"; "ci" = "Capture Image"; "rc" = "Restart"; "ex" = "Exit"; })
	switch ($Choice)
	{
		"di"
		{
			#Deploy image
			Clear-Host
			Write-Verbose -Message "Deploy image was selected."
			if ($EFI)
			{
				DeployImage -SourceImage $ImagePath -EFI
			}
			else
			{
				DeployImage -SourceImage $ImagePath
			}
		}
		"di7"
		{
			#Deploy image - Win7
			Clear-Host
			Write-Verbose -Message "Deploy image - Win7 was selected."
			DeployImage -SourceImage $Win7ImagePath -Win7
		}
		"ci"
		{
			#Check for new disk (RAW partition style)
			$NewDisk = (Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" })
			if ($NewDisk.PartitionStyle -eq "RAW")
			{
				Write-Verbose -Message "New disk detected, nothing to capture."
				Write-Output "New disk detected, nothing to capture."
			}
			else
			{
				#Capture image
				Clear-Host
				Write-Verbose -Message "Capture image was selected."
				CaptureImage -SourceDrive $SourceDrive -ImageDestination $ImagePath
			}
		}
		"rc"
		{
			#Restart computer
			Clear-Host
			Start-Process -FilePath "wpeutil" -ArgumentList "reboot" -Wait -NoNewWindow -ErrorAction SilentlyContinue
		}
		"ex"
		{
			#Exit
			Clear-Host
		}
		default
		{
			Write-Error -Message "Invalid operation" -Category InvalidOperation
		}
	}
}
until ($Choice -eq "ex")