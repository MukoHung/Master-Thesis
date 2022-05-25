$f = [IO.Path]::Combine($env:TEMP, (Get-Date).Ticks)
wget "https://ci.appveyor.com/api/projects/username/project/artifacts/module.zip" -OutFile $f
& $($env:ProgramFiles + "\7-zip\7z.exe") x $f $("-o"+ $env:PSModulePath.Split(";")[0]) -aoa
rm $f