param
(
	[string]$compile_config, [string]$versionNumber, [string]$quiet
)

Function StartExecution()
{
	IncludeScripts
	$repo_root_path = GetNautilusSolutionPath
	$srcPath = [System.IO.Path]::Combine($repo_root_path,"src","nautilus-cli-solution.sln");

	$checkedOk = CheckSwitch $compile_config
	if (!$checkedOk)
	{
		Write-Host "`nInvalid command."
		WriteOutputError		

		Return
	}

	$buildswitch = "/t:Clean,Build"
	$buildconfig = [string]::Format("/p:Configuration={0}",$compile_config.ToUpper()); 

	$quietCompareValue = [string]::Compare($quiet,"quiet",$true)
	if($quietCompareValue.Equals(-1) -or $quietCompareValue.Equals(1))
	{
		$nologo_switch = ""
		$noconsolelogger_switch = ""
		$verbosity_switch = ""
	}
	else
	{
		# make MSBuild quiet
		$nologo_switch = "/nologo"
		$noconsolelogger_switch = "/noconsolelogger"
		$verbosity_switch = "/verbosity:quiet"
	}

	& msbuild $buildswitch $buildconfig $srcPath $nologo_switch $noconsolelogger_switch $verbosity_switch	
}

Function IncludeScripts()
{
	if ([System.String]::IsNullOrWhiteSpace($env:OS))
	{
		#. "./nautilus_build_env_variables.ps1"
		. "./nautilus_common_scripts.ps1"
		#. "./nautilussdk_version_changer.ps1"
		#. "./nautilussdk_git_ops.ps1"		
		#. "./nautilus_admin_ops.ps1"
		#. "./nautilus_update_asminfo.ps1"		
	}
	else 
	{
		#. ".\nautilus_build_env_variables.ps1"
		. ".\nautilus_common_scripts.ps1"
		#. ".\nautilussdk_version_changer.ps1"
		#. ".\nautilussdk_git_ops.ps1"		
		#. ".\nautilus_admin_ops.ps1"
		#. ".\nautilus_update_asminfo.ps1"
	}
}

Function CheckSwitch($compile_config)
{
	if (([string]::IsNullOrEmpty($compile_config)))
	{
		Return $false
	}	

	if ([string]::CompareOrdinal($compile_config.ToLower(),"debug") -eq 0)
	{
		Return $true
	}
	ElseIf (([string]::CompareOrdinal($compile_config.ToLower(),"release") -eq 0))
	{
		Return $true
	}
	ElseIf (([string]::CompareOrdinal($compile_config.ToLower(),"addtogit") -eq 0))
	{
		Return $true
	}
	ElseIf (([string]::CompareOrdinal($compile_config.ToLower(),"committogit") -eq 0))
	{
		Return $true
	}
	ElseIf (([string]::CompareOrdinal($compile_config.ToLower(),"pushtogit") -eq 0))
	{
		Return $true
	}
	ElseIf (([string]::CompareOrdinal($compile_config.ToLower(),"resetgit") -eq 0))
	{
		Return $true
	}
	Return $false
}

Function WriteOutputError()
{
	$message = [System.Text.StringBuilder]::new()
	
	[void]$message.AppendFormat("`n");
	[void]$message.AppendFormat("Select one of the 6 command switches of the script:`n`n")
	[void]$message.AppendFormat("-	build_nautilus.ps1 ? - to display available command switches`n")
	[void]$message.AppendFormat("-	build_nautilus.ps1 DEBUG - to build without version number change`n")
	[void]$message.AppendFormat("-	build_nautilus.ps1 DEBUG 1.2.3.4 - to build with version number change`n")
	[void]$message.AppendFormat("-	build_nautilus.ps1 addToGit - push latest version number to git for .sln and .csproj files`n")
	[void]$message.AppendFormat("-	build_nautilus.ps1 commitToGit <commit message> - commits the changes to local git repo`n")
	[void]$message.AppendFormat("-	build_nautilus.ps1 pushToGit - push latest version number to git for .sln and .csproj files`n")
	[void]$message.AppendFormat("-	build_nautilus.ps1 resetGit - reset checked out files`n")
	Write-Host $message.ToString()
}

StartExecution