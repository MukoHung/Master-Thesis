function global:aspcomp()
{
	$dir = Join-Path $solutionScriptsContainer "..\Your.Web.Project" -Resolve
	$bin = Join-Path $dir "bin"
	$compiler = Join-Path $([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) "aspnet_compiler.exe"
		
	& $compiler -p $dir -v $bin
}