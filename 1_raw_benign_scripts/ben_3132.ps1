Properties {
	$baseDir = Resolve-Path .
	$project = Split-Path $baseDir -Leaf
	$artifactDir = "$baseDir\Build\Packages"
	$version = "1.0.1"
}

Task Default -Depends Build
Task Clean {
	if (Test-Path "$baseDir\build") {
		Remove-Item "$baseDir\Build" -Recurse -Force -ErrorAction Stop
	}
}
Task RestorePackages {
	Exec { .\.nuget\NuGet restore -PackagesDirectory .\packages }
}
Task UpdateAssemblyInfo {
	(Get-ChildItem -Path $baseDir -Filter AssemblyInfo.cs -Recurse) |
		Foreach-Object {
			(Get-Content $_.FullName) |
				Foreach-Object {
					$_ -replace 'AssemblyVersion.+$',"AssemblyVersion(`"$version`")]" `
					-replace 'AssemblyFileVersion.+$',"AssemblyFileVersion(`"$version`")]"
			} |
			Out-File $_.FullName
		}
}
Task Build -Depends Clean,RestorePackages,UpdateAssemblyInfo {
	Exec { msbuild "$project.sln" /p:Configuration=Release /t:"Clean,Build" }
}
Task Package -Depends Build {
	if (!(Test-Path($artifactDir))) {
		New-Item -ItemType Directory -Force -Path $artifactDir | Out-Null 
	}
	Exec { .\.nuget\NuGet pack $baseDir\$project\$project.csproj -OutputDirectory $artifactDir -Properties Configuration=Release -Version $version }
}
Task Publish -Depends Package {
	Exec { .\.nuget\NuGet push "$artifactDir\$project.$version.nupkg" }
}