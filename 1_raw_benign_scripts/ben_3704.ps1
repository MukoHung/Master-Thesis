function Set-WinStoreSetting {
    param (
     [Parameter(Mandatory=$true, Position=0)][string]$PackageName,
     [Parameter(Mandatory=$true, Position=1)][string]$SettingName,
     [Parameter(Mandatory=$true, Position=2)][string]$SettingValue
    )

	$settingsFile = [IO.Path]::Combine($env:LOCALAPPDATA, 'Packages', $PackageName, 'Settings\settings.dat')
	
	# temporary paths
	$regFile = ".\settings.reg"
	$registryImportLocation = "HKLM\_TMP"
	
	reg load $registryImportLocation $settingsFile
	reg export $registryImportLocation $regFile
	
	$fileContents = Get-Content $regFile

	$settingNamePrefix = """$SettingName""="
	$finalContents = @()
	$processing = $false
	Foreach ($line in $fileContents)
	{
		If (-Not ($processing))
		{
			# scanning for first line of the value
			If ($line.StartsWith($settingNamePrefix))
			{
				# found - switch mode and start reading the old value 
				$processing = $true
				$oldValue = $line.Replace($settingNamePrefix, "")
			}
			Else
			{
				# not found yet - copy to output
				$finalContents += $line
			}
		}
		Else
		{
			# non-first lines have leading spaces
			$oldValue += $line.TrimStart(" ")
		}

		If ($processing)
		{
			# scanning for last line of the value
			If ($oldValue.EndsWith("\"))
			{
				# strip trailing backslash; the value continues
				$oldValue = $oldValue.TrimEnd("\")
			}
			Else
			{
				# no backslash; the value is complete
				
				# extract type and timestamp from old value
				$match = $oldValue -match '(.*:)(.*)'
				$valueType = $matches[1]
				$timestamp = $matches[2].Substring($matches[2].Length - 23)
		
				# serialize the new value
				$utfEncoded = [System.Text.Encoding]::Unicode.GetBytes($SettingValue)
				Foreach ($byte in $utfEncoded)
				{
					$serializedValue += [System.Convert]::ToString($byte, 16).PadLeft(2, "0") + ","
				}
				# append null terminator
				$serializedValue += "00,00,"
				
				$newValue = $valueType + $serializedValue + $timestamp
				$finalContents += "$settingNamePrefix$newValue"
				$processing = $false
			}
		}
	}

	$finalContents | Out-File $regFile
	
	reg import $regFile
	reg unload $registryImportLocation
	
	Remove-Item $regFile
}