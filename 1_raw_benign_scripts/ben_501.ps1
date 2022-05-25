<#
	Basic build tasks for SharePoint (or other projects) - using 7zip and GacUtil
	
	$framework = '4.0x64'
	 . .\scripts\build-tasks.ps1


	properties { 
	  $project = "Sites"
	  
	  $environment = ""   # handed in commmand line  
	  $revision = "0"     # handed in commmand line
	  $version = "1.0.0." # problem with version as substitution at this level
	 
	  $platform = "x64"
	  $config = "Release"
	  
	  $base_dir  = resolve-path .
	  $configuration = "bin\$platform\$config"

	  $lib_dir = "$base_dir\lib"
	  $tools_dir = "$base_dir\tools"
	  $test_dir = "$base_dir\src\$project\$configuration"
	  $release_dir = "$base_dir\CodeToDeploy\Releases"
	  $extract_dir = "$base_dir\CodeToDeploy\Deploy"
	  $buildartifacts_dir = "$build_dir\CodeToDeploy\Publish"
		
	  $binaries_root = "$base_dir\src\Ui"
	  $wsp_root = "$binaries_root\bin\$config"
	  
	  $sln_file = "$base_dir\src\$project.sln"
	  $wsp_proj = "$base_dir\src\$project\UI-$project.csproj"

	} 

	Task Compile {
		exec { msbuild $sln_file /t:build "/p:Configuration=$config" "/p:Platform=$platform" }
	}

	Task PackageWsp {
		exec { msbuild $wsp_proj /t:package "/p:Configuration=$config" "/p:Platform=$platform" "/p:OutDir=$wsp_root\" } "Error msbuild $wsp_proj /t:package p:Configuration=$config /p:Platform=$platform /p:OutDir=$wsp_root\"
	}

	Task Version -Description "Version the assemblies" {
		Update-AssemblyInfoFiles $version$revision $assemblyinfo_excludes
	}

	Task Version-Reset -Description "Returns the version of the assemblies to 1.0.0.0" {
		Reset-AssemblyInfoFiles
	}

	Task Publish -Description "Copies the necessary files into the publishing folder" {
		Clobber-Directory $buildartifacts_dir
		CopyTo-Directory $base_dir\here.cmd     								$buildartifacts_dir
		CopyTo-Directory $base_dir\scripts\deploy\default.ps1  					$buildartifacts_dir
		CopyTo-Directory $base_dir\scripts\deploy\Install.bat 					$buildartifacts_dir	
		CopyTo-Directory $base_dir\scripts\deploy\Migrate.bat 					$buildartifacts_dir	
		CopyTo-Directory $base_dir\scripts\psake.psm1          					$buildartifacts_dir\scripts
		CopyTo-Directory $base_dir\scripts\sharepoint-tasks.ps1					$buildartifacts_dir\scripts
		CopyTo-Directory $base_dir\scripts\build-tasks.ps1						$buildartifacts_dir\scripts
		CopyTo-Directory $base_dir\scripts\migrations-tasks.ps1					$buildartifacts_dir\scripts
		
		CopyTo-Directory $wsp_root\Infrastructure.dll							$buildartifacts_dir\lib\migratordotnet
		CopyTo-Directory $wsp_root\Domain.dll 		   							$buildartifacts_dir\lib\migratordotnet
		CopyTo-Directory $wsp_root\$project.dll 		   						$buildartifacts_dir\lib\migratordotnet
		CopyTo-Directory $lib_dir\migratordotnet\*							   	$buildartifacts_dir\lib\migratordotnet

		CopyTo-Directory $lib_dir\wsp\*                   		    			$buildartifacts_dir\wsp
		CopyTo-Directory $wsp_root\$solution                   					$buildartifacts_dir\wsp
		Create-VersionFile 														$buildartifacts_dir\$version$revision
	}

	Task Extract -Description "Unzips the packing zip archive" {
		Extract-Zip $release_dir\$project-$version$revision.zip $extract_dir
	}

	Task Zip -Description "Unzips the packing zip archive" {
		Create-Zip $release_dir\$project-$version$revision.zip $buildartifacts_dir
	}

	Task Deploy -Description "Runs the Install.bat file under the deploy user credentials" {
		exec { cd $extract_dir; dir; runas /savecred /user:$site_owner "$extract_dir\Install.bat $extract_dir $application $environment" }  "If this command fails, through command line do this: runas /savecred /user:$site_owner cmd -  and rerun -> this will save the creds "
	}

	Task Gac -Description "Add all assemblies to GAC" {
		AddTo-Gac $wsp_root $project
	}

	Task Gac-Uninstall -Description "Remove all assemblies from the GAC" {
		Clean-Gac $wsp_root $project
	}	
	
#>

$7z_exe = ".\lib\7z\7z.exe"
$gac_exe = "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\x64\gacutil.exe"

function Writeable-AssemblyInfoFile($filename){
	sp $filename IsReadOnly $false
}

function ReadOnly-AssemblyInfoFile($filename){
	sp $filename IsReadOnly $true
}

function CopyTo-Directory($files, $dir){
	Create-Directory $dir
	cp $files $dir -recurse -container
}

function Clobber-Directory($dir){
	if (Test-Path -path $dir) { rmdir $dir -recurse -force }
}

function Create-Directory($dir){
	if (!(Test-Path -path $dir)) { new-item $dir -force -type directory}
}

function Create-VersionFile($file){
    New-Item $file -type file
}

function Create-Zip($file, $dir, $7z){

    if ($7z -eq $null) { $7z = $7z_exe }
	if (Test-Path -path $file) { remove-item $file }
	Create-Directory $dir
	exec { & $7z a -tzip $file $dir\* } 
}

function Extract-Zip($file, $extract_dir, $7z){
  if ($7z -eq $null) { $7z = $7z_exe }
  Clobber-Directory $extract_dir
  Create-Directory $extract_dir
  exec { & $7z x $file -aoa "-o$extract_dir"} 
}

function Clean-Gac($dir, $include, $gac){
   if ($gac -eq $null) { $gac = $gac_exe }
   get-childitem $dir -filter *.$include*.dll | % {
 		exec { & $gac /u $_.basename }
	}
}

function AddTo-Gac($dir, $include, $gac){
   if ($gac -eq $null) { $gac = $gac_exe }
   get-childitem $dir -filter *.$include*.dll | % {
		exec { & $gac /i $_.fullname }
	}
}

function Update-AssemblyInfoFiles ([string] $version, [System.Array] $excludes = $null, $make_writeable = $false) {

#-------------------------------------------------------------------------------
# Update version numbers of AssemblyInfo.cs
# adapted from: http://www.luisrocha.net/2009/11/setting-assembly-version-with-windows.html
#-------------------------------------------------------------------------------

	if ($version -notmatch "[0-9]+(\.([0-9]+|\*)){1,3}") {
		Write-Error "Version number incorrect format: $version"
	}
	
	$versionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	$versionAssembly = 'AssemblyVersion("' + $version + '")';
	$versionFilePattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	$versionAssemblyFile = 'AssemblyFileVersion("' + $version + '")';

	Get-ChildItem -r -filter AssemblyInfo.cs | % {
		$filename = $_.fullname
		
		$update_assembly_and_file = $true
		
		# set an exclude flag where only AssemblyFileVersion is set
		if ($excludes -ne $null)
			{ $excludes | % { if ($filename -match $_) { $update_assembly_and_file = $false	} } }
		

		# We are using a source control (TFS) that requires to check-out files before 
		# modifying them. We don't want checkins so we'll just toggle
		# the file as writeable/readable	
	
		if ($make_writable) { Writeable-AssemblyInfoFile($filename) }

		# see http://stackoverflow.com/questions/3057673/powershell-locking-file
		# I am getting really funky locking issues. 
		# The code block below should be:
		#     (get-content $filename) | % {$_ -replace $versionPattern, $version } | set-content $filename

		$tmp = ($file + ".tmp")
		if (test-path ($tmp)) { remove-item $tmp }

		if ($update_assembly_and_file) {
			(get-content $filename) | % {$_ -replace $versionFilePattern, $versionAssemblyFile } | % {$_ -replace $versionPattern, $versionAssembly }  > $tmp
			write-host Updating file AssemblyInfo and AssemblyFileInfo: $filename --> $versionAssembly / $versionAssemblyFile
		} else {
			(get-content $filename) | % {$_ -replace $versionFilePattern, $versionAssemblyFile } > $tmp
			write-host Updating file AssemblyInfo only: $filename --> $versionAssemblyFile
		}

		if (test-path ($filename)) { remove-item $filename }
		move-item $tmp $filename -force	

		if ($make_writable) { ReadOnly-AssemblyInfoFile($filename) }		

	}
}
function Reset-AssemblyInfoFiles(){
	Update-AssemblyInfoFiles ("1.0.0.0")
}
