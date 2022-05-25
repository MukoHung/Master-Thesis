<#
This Script Loads ADSI Based Get-AdUser() function/cmd-let if the ActiveDirectory Module Not found.
NOTE : <<Book Snap from PowerShell in Depth -- Don Jones
When you start loading up a bunch of modules or PSSnapins, it’s obviously possible
for two of them to contain commands having the same name. So what happens?
By default, when you run a command, PowerShell runs the last version of that command
that was loaded into memory  —that is, whichever one was loaded most recently.
#>
if (Get-Module -ListAvailable -Name ActiveDirectory){
	Write-Host "Loading ActiveDirectory module"
	Import-Module ActiveDirectory
	Add-Content $strLogFile "ActiveDirectory PS1 module Found & loaded"
} else {
	Write-Host "No ActiveDirectory module, define Get-ADUser"
	Add-Content $strLogFile "No ActiveDirectory PS1 module, define Get-ADUser"
	
	function Get-ADUser([String]$ObjectSid, [String]$Properties)#, [String]$Server)
	{
		$Searcher = New-Object DirectoryServices.DirectorySearcher
		$Searcher.Filter = ('(&(objectCategory=person)(ObjectSid={0}))' -f $ObjectSid)
		$Searcher.SearchRoot = 'LDAP://DC=something,DC=com'
		$r = $Searcher.FindAll()
		# check if user exist in AD and is unique (should not be a problem since user is logged in. But we never know...)
		if(!$r -or $r.Count -eq 0){
			Throw New-Object System.FormatException "AD_NO_ACCOUNT: user '$ObjectSid' has no standard AD account"
		}
		if($r.Count -and $r.Count -gt 1){
			Throw New-Object System.FormatException "AD_MULTIPLE_ACCOUNT: Multiple standard AD account found for user '$ObjectSid'."
		}
		return [adsi]$r[0].path
	}
}