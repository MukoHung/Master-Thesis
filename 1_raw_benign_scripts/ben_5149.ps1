<#
.Synopsis
	Checks for the existence of the given command, and adds if missing and a source is defined.

.Description
	Use-Command checks to see if a command exists by the name given.

	If the command does not exist, but the path is valid, an alias is created.

	Otherwise, if one of several installation methods is provided, an installation attempt is made before aliasing.

.Parameter Name
	The name of the command to test.

.Parameter Path
	The full path of the command, if installed.
	Accepts wildcards, as supported by Resolve-Path.

.Parameter ChocolateyPackage
	The name of the Chocolatey package to install if the command is missing.

.Parameter DotNetTool
	The name of the .NET global tool to install if the command is missing.

.Parameter NugetPackage
	The name of the NuGet package to install if the command is missing.

.Parameter NodePackage
	The name of the Node NPM package to install if the command is missing.

.Parameter Version
	The specific package version to install.

.Parameter InstallDir
	The directory to install NuGet or Node packages to.
	Node will create and use a "node_modules" folder under this one.
	Default is C:\Tools

.Parameter WindowsInstaller
	The location (file or URL) of an MSI package to install if the command is missing.

.Parameter InstallLevel
	The INSTALLLEVEL to pass to Windows Installer.
	Default is 32767

.Parameter ExecutableInstaller
	The location (file or URL) of an .exe installer to use if the command is missing.

.Parameter InstallerParameters
	Parameters to pass to the .exe installer.

.Parameter ExecutePowerShell
	The URL or file path of a PowerShell script to download and execute to install the command if it is missing.

.Parameter DownloadZip
	The URL to download a .zip file containing the command if it is missing.

.Parameter DownloadUrl
	The URL to download the command from if it is missing.

.Parameter Message
	A message to display, rather than attempting to install a missing command.

.Parameter Fail
	Throw an exception rather than attempt to install a missing command.

.Component
	System.IO.Compression.FileSystem

.Link
	Find-NewestFile.ps1

.Link
	Resolve-Path

.Link
	https://chocolatey.org/

.Link
	https://docs.microsoft.com/dotnet/core/tools/global-tools

.Link
	https://www.nuget.org/

.Link
	https://www.npmjs.com/

.Link
	https://technet.microsoft.com/library/bb490936.aspx

.Link
	http://www.iheartpowershell.com/2013/05/powershell-supportsshouldprocess-worst.html

.Example
	Use-Command.ps1 nuget $ToolsDir\NuGet\nuget.exe -url https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

	This example downloads and aliases nuget, if missing.

.Example
	Use-Command.ps1 npm 'C:\Program Files\nodejs\npm.cmd' -cinst nodejs

	This example downloads and silently installs node if npm is missing.

.Example
	Use-Command.ps1 Get-ADUser $null -WindowsFeature RSAT-AD-PowerShell

	This example downloads and installs the RSAT-AD-PowerShell module if missing.
#>

#requires -Version 2
#requires -Modules Microsoft.PowerShell.Utility
[CmdletBinding(SupportsShouldProcess=$true)][OutputType([void])] Param(
[Parameter(Position=0,Mandatory=$true)][string] $Name,
[Parameter(Position=1,Mandatory=$true)][string] $Path,
[Parameter(ParameterSetName='WindowsFeature')][Alias('WinFeature')][string] $WindowsFeature,
[Parameter(ParameterSetName='ChocolateyPackage')][Alias('ChocoPackage','chocopkg','cinst')][string] $ChocolateyPackage,
[Parameter(ParameterSetName='DotNetTool')][Alias('DotNetGlobalTool','dotnet')][string] $DotNetTool,
[Parameter(ParameterSetName='NugetPackage')][Alias('nupkg')][string] $NugetPackage,
[Parameter(ParameterSetName='NodePackage')][Alias('npm')][string] $NodePackage,
[Parameter(ParameterSetName='ChocolateyPackage')]
[Parameter(ParameterSetName='NugetPackage')]
[Parameter(ParameterSetName='NodePackage')]
[ValidatePattern('\A\S+\z')][string] $Version,
[Parameter(ParameterSetName='NugetPackage')]
[Parameter(ParameterSetName='NodePackage')]
[Alias('dir')][string] $InstallDir = 'C:\Tools',
[Parameter(ParameterSetName='WindowsInstaller')]
[Alias('msi')][uri] $WindowsInstaller,
[Parameter(ParameterSetName='WindowsInstaller')]
[int] $InstallLevel = 32767,
[Parameter(ParameterSetName='ExecutableInstaller')]
[Alias('exe')][uri] $ExecutableInstaller,
[Parameter(ParameterSetName='ExecutableInstaller')]
[Alias('params')][string[]] $InstallerParameters = @(),
[Parameter(ParameterSetName='ExecutePS')][Alias('iex')][uri] $ExecutePowerShell,
[Parameter(ParameterSetName='DownloadZip')][Alias('zip')][uri] $DownloadZip,
[Parameter(ParameterSetName='DownloadUrl')][Alias('url')][uri] $DownloadUrl,
[Parameter(ParameterSetName='WarnOnly')]
[Alias('msg')][string] $Message,
[Parameter(ParameterSetName='Fail')]
[switch] $Fail
)
function Set-ResolvedAlias([Parameter(Position=0)][string]$Name,[Parameter(Position=1)][string]$Path)
{ Set-Alias $Name (Resolve-Path $Path -EA SilentlyContinue |% Path |Find-NewestFile.ps1 |% FullName) -Scope Global }
Get-Command $Name -EA SilentlyContinue -EV cmerr |Out-Null
if(!$cmerr) { Write-Verbose "$Name command found." ; return }
if($Path -and (Test-Path $Path)) { Set-ResolvedAlias $Name $Path ; return }

switch($PSCmdlet.ParameterSetName)
{
	WindowsFeature
	{
		if(!(Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue))
		{ throw "Install-WindowsFeature not found, unable to install $WindowsFeature." }
		if($PSCmdlet.ShouldProcess($WindowsFeature,'install Windows feature'))
		{
			Install-WindowsFeature $WindowsFeature
		}
		else { Write-Warning "Installation of $WindowsFeature was cancelled." }
	}

	ChocolateyPackage
	{
		if(!(Get-Command cinst -ErrorAction SilentlyContinue))
		{ throw "Chocolatey installer ""cinst"" not found, unable to install $ChocolateyPackage." }
		if($PSCmdlet.ShouldProcess($ChocolateyPackage,'Chocolatey install'))
		{
			if($Version) {cinst $ChocolateyPackage -y --version=$Version}
			else {cinst $ChocolateyPackage -y}
			if($ChocolateyPackage -eq 'dot') {Write-Warning "You must run 'dot -c' as admin before Graphviz will work"}
			Set-ResolvedAlias $Name $Path
		}
		else { Write-Warning "Installation of $ChocolateyPackage was cancelled." }
	}

	DotNetTool
	{
		Use-Command.ps1 dotnet $env:ProgramFiles\dotnet\dotnet.exe -cinst dotnet
		if(!(Get-Command dotnet -ErrorAction SilentlyContinue))
		{ throw "dotnet not found, unable to install $DotNetTool." }
		if($PSCmdlet.ShouldProcess($DotNetTool,'install .NET global tool')) {dotnet tool install -g $DotNetTool}
		else { Write-Warning "Installation of $DotNetTool was cancelled." }
	}

	NugetPackage
	{
		Use-Command.ps1 nuget $env:ChocolateyInstall\bin\nuget.exe -cinst NuGet.CommandLine
		if(!(Get-Command nuget -ErrorAction SilentlyContinue))
		{ throw "NuGet not found, unable to install $NugetPackage." }
		if($PSCmdlet.ShouldProcess("$NugetPackage in $InstallDir",'NuGet install'))
		{
			if($Version) {nuget install $NugetPackage -x -o $InstallDir -Version $Version -NonInteractive}
			else {nuget install $NugetPackage -x -o $InstallDir -NonInteractive}
			Set-ResolvedAlias $Name $Path
		}
		else { Write-Warning "Installation of $NugetPackage was cancelled." }
	}

	NodePackage
	{
		Use-Command.ps1 npm $env:ProgramFiles\nodejs\npm.cmd -cinst nodejs
		if(!(Get-Command npm -ErrorAction SilentlyContinue))
		{ throw "Npm not found, unable to install $NodePackage." }
		if(!(Test-Path "$env:USERPROFILE\AppData\Roaming\npm" -PathType Container))
		{ mkdir "$env:USERPROFILE\AppData\Roaming\npm" |Out-Null }
		if($PSCmdlet.ShouldProcess("$NodePackage in $InstallDir",'npm install'))
		{
			pushd $InstallDir
			if($Version) {npm install $NodePackage@$Version}
			else {npm install $NodePackage}
			popd
			Set-ResolvedAlias $Name $Path
		}
		else { Write-Warning "Installation of $NodePackage was cancelled." }
	}

	WindowsInstaller
	{
		if(!(Get-Command msiexec -ErrorAction SilentlyContinue))
		{ throw "Windows installer (msiexec) not found, unable to install $WindowsInstaller." }
		$file = $WindowsInstaller.Segments[$WindowsInstaller.Segments.Length-1]
		if($PSCmdlet.ShouldProcess("$file (INSTALLLEVEL=$InstallLevel)",'Windows install'))
		{
			$msi =
				if($WindowsInstaller.IsUnc)
				{ Copy-Item $WindowsInstaller $env:TEMP; "$env:TEMP\$file" }
				elseif($WindowsInstaller.IsFile)
				{ [string]$WindowsInstaller }
				else
				{ (New-Object System.Net.WebClient).DownloadFile($WindowsInstaller,"$env:TEMP\$file"); "$env:TEMP\$file" }
			msiexec /i $msi /passive /qb INSTALLLEVEL=$InstallLevel
			while(!(Test-Path $Path) -and $PSCmdlet.ShouldContinue(
				"The file $Path was still not found. Continue waiting for installation?","Await Installation")) { Start-Sleep 5 }
			if(Test-Path $Path) { Set-ResolvedAlias $Name $Path }
		}
		else { Write-Warning "Installation of $WindowsInstaller was cancelled." }
	}

	ExecutableInstaller
	{
		$file = $ExecutableInstaller.Segments[$ExecutableInstaller.Segments.Length-1]
		if($PSCmdlet.ShouldProcess("$file $InstallerParameters",'execute installer'))
		{
			$exe =
				if($ExecutableInstaller.IsUnc)
				{ Copy-Item $ExecutableInstaller.OriginalString $env:TEMP; "$env:TEMP\$file" }
				elseif($ExecutableInstaller.IsFile)
				{ [string]$ExecutableInstaller }
				else
				{ (New-Object System.Net.WebClient).DownloadFile($ExecutableInstaller,"$env:TEMP\$file"); "$env:TEMP\$file" }
			Start-Process $exe $InstallerParameters -NoNewWindow -Wait
			while(!(Test-Path $Path) -and $PSCmdlet.ShouldContinue(
				"The file $Path was still not found. Continue waiting for installation?","Await Installation")) { Start-Sleep 5 }
			if(Test-Path $Path) { Set-ResolvedAlias $Name $Path }
		}
		else { Write-Warning "Installation of $ExecutableInstaller was cancelled." }
	}

	ExecutePowerShell
	{
		if($PSCmdlet.ShouldProcess($ExecutePowerShell,"execute PowerShell script"))
		{
			switch($ExecutePowerShell.Scheme)
			{
				file    { Invoke-Expression (gc $ExecutePowerShell.OriginalString -raw) }
				default { Invoke-Expression ((new-object net.webclient).DownloadString($ExecutePowerShell)) }
			}
		}
		else { Write-Warning "Execution of $ExecutePowerShell was cancelled." }
	}

	DownloadZip
	{
		$dir = Split-Path $Path
		if($PSCmdlet.ShouldProcess("$DownloadZip to $dir",'download/unzip'))
		{
			$filename = [IO.Path]::GetFileName($DownloadZip.LocalPath)
			if (!(Test-Path $dir -PathType Container)) { mkdir $dir |Out-Null }
			$zippath = Join-Path $env:TEMP $filename
			Write-Verbose "Downloading $DownloadZip to $path"
			Invoke-WebRequest $DownloadZip -OutFile $zippath
			try{[void][IO.Compression.ZipFile]}catch{Add-Type -AN System.IO.Compression.FileSystem}
			Write-Verbose "Copying zipped items from $zippath to $dir"
			[IO.Compression.ZipFile]::ExtractToDirectory($zippath,$dir)
			Set-ResolvedAlias $Name $Path
		}
		else { Write-Warning "Download/unzip of $Name was cancelled." }
	}

	DownloadUrl
	{
		if($PSCmdlet.ShouldProcess("$DownloadUrl to $Path",'download'))
		{
			$dir = Split-Path $Path
			if (!(Test-Path $dir -PathType Container)) { mkdir $dir |Out-Null }
			Invoke-WebRequest $DownloadUrl -OutFile $Path
			Set-ResolvedAlias $Name $Path
		}
		else { Write-Warning "Download of $Name was cancelled." }
	}

	WarnOnly
	{
		Write-Warning $Message
	}

	Fail
	{
		throw "$Name command not found!"
	}
}
