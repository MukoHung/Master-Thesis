$coverageFile = $(get-ChildItem -Path .\TestResults -Recurse -Include *coverage)[0]
$xmlCoverageFile = ".\TestResults\vstest.coveragexml"

Add-Type -path "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\PrivateAssemblies\Microsoft.VisualStudio.Coverage.Analysis.dll"

[string[]] $executablePaths = @($coverageFile)
[string[]] $symbolPaths = @()

$info = [Microsoft.VisualStudio.Coverage.Analysis.CoverageInfo]::CreateFromFile($coverageFile, $executablePaths, $symbolPaths);
$data = $info.BuildDataSet()

$data.WriteXml($xmlCoverageFile)