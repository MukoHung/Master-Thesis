get-childitem . -include *.sln -recurse | foreach ($_) { nuget restore $_.FullName -verbosity detailed}
get-childitem . -include *.png -recurse | foreach ($_) { pngout "$_"}