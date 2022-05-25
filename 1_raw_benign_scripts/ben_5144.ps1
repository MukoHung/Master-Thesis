param()

# update powershell 5 profile script

if ($IsWindows)
{	
	if (!(test-path -path "$home\Documents\WindowsPowerShell"))
	{
		new-item -itemtype Directory "$home\Documents\WindowsPowerShell"
	}

	if (test-path -path "~\Documents\WindowsPowerShell\Profile.ps1" -pathtype leaf)
	{
		remove-item "~\Documents\WindowsPowerShell\Profile.ps1"
	}

	copy-item -path .\Profile.ps1 -destination "~\Documents\WindowsPowerShell\Profile.ps1"
}

# update powershell core profile script

if (test-path -path $profile -pathtype leaf)
{
	remove-item $profile
}
else
{
	new-item $profile -force
	remove-item $profile
}

copy-item -path .\Microsoft.PowerShell_profile.ps1 -destination $profile
