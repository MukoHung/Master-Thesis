<# 
Author: Bob@BobHodges.net
Date: Aug 11th, 2015
Updated: Dec 6th, 2018
Description: Replaces default notepad.exe with Notepad++ executable in system folders.
#> 

# Optional - Installs the latest version of Notepad++ from Chocolatey repo.
# Install-Package -Name NotePadPlusPlus -Force

# Close Notepad++ or Notepad if either are running.
Get-process notepad,notepad++ -ErrorAction 0 | Stop-Process -Force

# Paths to default notepad.exe
$Notepads = "$($env:systemroot)\Notepad.exe","$($env:systemroot)\System32\Notepad.exe","$($env:systemroot)\SysWOW64\Notepad.exe"

# Path to default notepad++.exe and SciLexer.dll.
Try 
{
	$NotepadPlus = Resolve-Path "$($env:systemdrive)\Program Files*\Notepad++\notepad++.exe"
	$NotepadPlusDLL = Resolve-Path "$($env:systemdrive)\Program Files*\Notepad++\SciLexer.dll"
}
# Exits the script if Notepad++ is not found. 
Catch
{
	Write-Output "You must install NotePad++ to use this script."
	Write-Output "https://notepad-plus-plus.org/download"
	Pause
	Exit
}

# Registry keys for Notepad++ 7.5.9 and above
$RegNppPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"
$RegName = "Debugger"
$RegValue = "`"$NotepadPlus`" -notepadStyleCmdline -z"

# Function to take ownership of the notepad files.
Function Set-Ownership($file)
{
	# The takeown.exe file should already exist in Win7 - Win10 
	try { & takeown /f $file }
	catch { Write-Output "Failed to take ownership of $file" }
}

# This function gives us permission to change the notepad.exe files.
Function Set-Permissions($file)
{
	$ACL = Get-Acl $file
	$AccessRule= New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "Allow")
	$ACL.SetAccessRule($AccessRule)
	$ACL | Set-Acl $file
}

# Loops through each notepad path.
Foreach($Notepad in $Notepads)
{
	# Checks for the required paths before attempting changes.
	if (!$(Test-Path $Notepad) -or !$(Test-Path $NotepadPlus)){continue}
	
	# Takes ownership of the file, then changes the NTFS permissions to allow us to rename it. 
	Set-Ownership $Notepad
	Set-Permissions $Notepad
	
	Write-Output "Replacing Notepad file: $Notepad `r`n"
	Rename-Item -Path $Notepad -NewName "Notepad.exe.bak" -ErrorAction SilentlyContinue
	
	# Copies the NotePad++ file and the dependant DLL file to the current path. 
	Copy-Item -Path $NotepadPlus -Destination $Notepad
	Copy-Item -Path $NotepadPlusDLL -Destination $(Split-Path $Notepad -Parent)
}

# Get Notepad++ version information. If version 7.59 or above, apply registry patch. 
[decimal]$NppVersion = (Get-Item $notepadplus).versioninfo.fileversion

if ($NppVersion -ge '7.59')
{
	Write-Output "NotePad++ version $nppVersion is above 7.58: Applying registry patch."
	Try 
	{ 
		# Checks to see if the registry key exists before making a registry property and value.
		if (Test-Path $regNppPath)
		{ 
			# The registry key exists, so we create a registry property and value.
			New-ItemProperty -Path $regNppPath -Name $regName -Value $RegValue -PropertyType String -Force | Out-Null
		}
		# Registry path doesn't exist, so it needs to be created. 
		else
		{
			# The registry key doesn't exist, so we create the registry key prior to creating the property.
			New-Item -Path $regNppPath -Force | Out-Null
			New-ItemProperty -Path $regNppPath -Name $regName -Value $RegValue -PropertyType String -Force | Out-Null
		}
	}
	Catch { Write-Output "Failed to apply registry patch"}
}
else 
{
	# Since Notepad++ is below 7.59, the registry patch should not exist. 
	# This checks to see if the registry patch exists, and if so it removes it. 
	$regPatchInstalStatus = Get-ItemProperty -Path $regNppPath -Name $RegName -ErrorAction 0
	if ($regPatchInstalStatus)
	{
		Write-Output "Removing incompatible registry patch `r`n$regNppPath."
		Try { Remove-ItemProperty -Path $regNppPath -Name $regName -Force | Out-Null }
		Catch { Write-Output "Failed to remove registry patch"}
	}
}
# Run Notepad++ once to avoid XML error.
& $NotepadPlus