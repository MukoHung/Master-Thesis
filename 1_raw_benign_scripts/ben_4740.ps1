<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)

.Description
	TASKS AND REQUIREMENTS
	Run tests and compare results with expected
		- Assert-SameFile.ps1 https://www.powershellgallery.com/packages/Assert-SameFile
		- Invoke-PowerShell.ps1 https://www.powershellgallery.com/packages/Invoke-PowerShell
	Make help in PowerShell XML format
		- Helps.ps1 https://www.nuget.org/packages/Helps
	Convert markdown files to HTML
		- pandoc https://github.com/jgm/pandoc/releases
	Push to GitHub with a tag
		- git
	Make and push the NuGet package
		- NuGet
	Clean the project directory
#>

# Build script parameters
param(
	[switch]$NoTestDiff
)

# Ensure IB works in the strict mode.
Set-StrictMode -Version Latest

# Synopsis: Convert markdown files to HTML.
# <http://johnmacfarlane.net/pandoc/>
task markdown {
	function Convert-Markdown($Name) {pandoc.exe --standalone --from=gfm "--output=$Name.htm" "--metadata=pagetitle=$Name" "$Name.md"}
	exec { Convert-Markdown README }
}

# Synopsis: Remove temp files.
task clean {
	remove z, *\z, *\z.*, README.htm, Invoke-Build.*.nupkg, Tests\New-VSCodeTask\.vscode\tasks.json
	remove ib\bin, ib\obj, ib\ib.*.nupkg
}

# Synopsis: Build the PowerShell help file.
# <https://github.com/nightroman/Helps>
task help {
	. Helps.ps1
	Convert-Helps InvokeBuild-Help.ps1 InvokeBuild-Help.xml
}

# Synopsis: Set $script:Version from Release-Notes.
task version {
	($script:Version = switch -Regex -File Release-Notes.md {'##\s+v(\d+\.\d+\.\d+)' {$Matches[1]; break}})
	assert $script:Version
}

# Synopsis: Make the module folder.
task module version, markdown, help, {
	remove z

	# copy the module folder
	$dir = "$BuildRoot\z\InvokeBuild"
	Copy-Item InvokeBuild $dir -Recurse

	# copy files without Invoke-Build.ps1
	Copy-Item -Destination $dir $(
		'Build-Checkpoint.ps1'
		'Build-Parallel.ps1'
		'InvokeBuild-Help.xml'
		'Resolve-MSBuild.ps1'
		'Show-TaskHelp.ps1'
		'README.htm'
		'LICENSE'
	)

	# copy Invoke-Build.ps1 with version comment
	$line, $text = Get-Content Invoke-Build.ps1
	equals $line '<#'
	$(
		"<# Invoke-Build $script:Version"
		$text
	) | Set-Content $dir\Invoke-Build.ps1

	# make manifest
	Set-Content "$dir\InvokeBuild.psd1" @"
@{
	ModuleVersion = '$script:Version'
	ModuleToProcess = 'InvokeBuild.psm1'
	GUID = 'a0319025-5f1f-47f0-ae8d-9c7e151a5aae'
	Author = 'Roman Kuzmin'
	CompanyName = 'Roman Kuzmin'
	Copyright = '(c) Roman Kuzmin'
	Description = 'Build and test automation in PowerShell'
	PowerShellVersion = '2.0'
	AliasesToExport = 'Invoke-Build', 'Build-Checkpoint', 'Build-Parallel'
	PrivateData = @{
		PSData = @{
			Tags = 'Build', 'Test', 'Automation'
			ProjectUri = 'https://github.com/nightroman/Invoke-Build'
			LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'
			IconUri = 'https://raw.githubusercontent.com/nightroman/Invoke-Build/master/ib.png'
			ReleaseNotes = 'https://github.com/nightroman/Invoke-Build/blob/master/Release-Notes.md'
		}
	}
}
"@
}

# Synopsis: Make the NuGet package.
task nuget module, {
	# rename the folder
	Rename-Item z\InvokeBuild tools

	# summary and description
	$text = @'
Invoke-Build is a build and test automation tool which invokes tasks defined in
PowerShell v2.0+ scripts. It is similar to psake but arguably easier to use and
more powerful. It is complete, bug free, well covered by tests.
'@

	# icon
	Copy-Item ib.png z

	# manifest
	Set-Content z\Package.nuspec @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
	<metadata>
		<id>Invoke-Build</id>
		<version>$script:Version</version>
		<authors>Roman Kuzmin</authors>
		<owners>Roman Kuzmin</owners>
		<projectUrl>https://github.com/nightroman/Invoke-Build</projectUrl>
		<icon>ib.png</icon>
		<license type="expression">Apache-2.0</license>
		<requireLicenseAcceptance>false</requireLicenseAcceptance>
		<summary>$text</summary>
		<description>$text</description>
		<tags>Build Automation PowerShell</tags>
		<releaseNotes>https://github.com/nightroman/Invoke-Build/blob/master/Release-Notes.md</releaseNotes>
		<developmentDependency>true</developmentDependency>
	</metadata>
</package>
"@

	# package
	exec { nuget pack z\Package.nuspec -NoDefaultExcludes -NoPackageAnalysis }
}

# Synopsis: Push with a version tag.
task pushRelease version, {
	$changes = exec { git status --short }
	assert (!$changes) "Please, commit changes."

	exec { git push }
	exec { git tag -a "v$script:Version" -m "v$script:Version" }
	exec { git push origin "v$script:Version" }
}

# Synopsis: Push NuGet package.
task pushNuGet nuget, {
	if (!($NuGetApiKey = property NuGetApiKey '')) { $NuGetApiKey = Read-Host NuGetApiKey }
	exec { nuget push "Invoke-Build.$script:Version.nupkg" -Source nuget.org -ApiKey $NuGetApiKey }
}

# Synopsis: Push PSGallery package.
task pushPSGallery module, {
	if (!($PSGalleryApiKey = property PSGalleryApiKey '')) { $PSGalleryApiKey = Read-Host NuGetApiKey }
	Publish-Module -Path z/InvokeBuild -NuGetApiKey $PSGalleryApiKey
}

# Synopsis: Calls tests infinitely. NOTE: normal scripts do not use ${*}.
task loop {
	for() {
		${*}.Tasks.Clear()
		${*}.Errors.Clear()
		${*}.Warnings.Clear()
		Invoke-Build . Tests\.build.ps1
	}
}

# Synopsis: Test and check expected output.
# Requires PowerShelf/Assert-SameFile.ps1
task test5 {
	assert ($PSVersionTable['Platform'] -ne 'Unix') 'WSL: cd Tests; ib'

	#! v7 may use different view
	$script:ErrorView = 'NormalView'

	# invoke tests, get output and result
	$output = Invoke-Build . Tests\.build.ps1 -Result result -Summary | Out-String -Width:200
	if ($NoTestDiff) {return}

	# process and save the output
	$resultPath = "$BuildRoot\Invoke-Build-Test.log"
	$samplePath = "$HOME\data\Invoke-Build-Test.$($PSVersionTable.PSVersion.Major).log"
	$output = $output -replace '\d\d:\d\d:\d\d(?:\.\d+)?( )? *', '00:00:00.0000000$1'
	[System.IO.File]::WriteAllText($resultPath, $output, [System.Text.Encoding]::UTF8)

	# compare outputs
	Assert-SameFile $samplePath $resultPath $env:MERGE
	Remove-Item $resultPath
}

# Synopsis: Test with PS Core.
task test7 {
	$diff = if ($NoTestDiff) {'-NoTestDiff'}
	exec {pwsh -NoProfile -Command Invoke-Build test5 $diff}
}

# Synopsis: Gets dependencies (call by v5+).
task boot {
	Save-Script Invoke-PowerShell -Path . -Force
}

# Synopsis: Test versions.
task test test5, test7

# Synopsis: The default task: make, test, clean.
task . help, test, clean
