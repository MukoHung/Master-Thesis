# Credit due to www.reddit.com/user/Zendainc
#
# What this does:
#   Finds out if CryptoLocker has infected pc's on the network by looking for a registery in the HKEY_USER hive. Maybe able to use for terminal servers too.
#   If you find it:
#      Go to the machine and extract the registry [HKEY_CURRENT_USER\Software\CryptoLocker\Files]. This gives you a list of files that have been encrypted.
#      Use combo fix to clean it
#      Recover files that have been affected from backups.
#
# How to use this script:
#    Create a file called C:\listofcomputers.txt with a list of pc names
#    You need to be an administrator on the pc's
#    Remote Registry service needs to be running on the PC
#
# Output:
#   Computer name, Status
#   Status Values
#         Null  - Machine is not available
#         True  - Machine has the register entry we are looking for
#         False - Changes are we are safe.
#
#
# Tested on:
#    Windows 7
#
# To Clean up an Exported list of Computers
# 	Find: (^.+?)\s.*$
#	Replace With: \1
#
#	This will keep all characters until the first white space

$Type = [Microsoft.Win32.RegistryHive]::Users

$ComputerNames = Get-content C:\listofcomputers.txt
foreach($ComputerName in $ComputerNames)
{
	$Status = $null #if machine is not available
	if(Test-Connection $ComputerName -Quiet)
	{
		$Status = $false
		$SubKeyNames = $null
		$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Type, $ComputerName)
		$subKeys = $regKey.GetSubKeyNames()
		
		$subKeys | %{
			$key = "$_\software"
			
			Try
			{
				$regSubKey = $regKey.OpenSubKey($key)
				$SubKeyNames = $regSubKey.GetSubKeyNames()
				if($SubKeyNames -match "CryptoLocker")
				{
					$Status = $true
				}
			}
			
			Catch{}
		}
	}
	
	$log = New-Object PSObject -Property @{
		ComputerName = $ComputerName
		if($Status == )
		Status = $Status
	}
	

	$log
}