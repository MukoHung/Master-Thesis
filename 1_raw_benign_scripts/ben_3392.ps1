param([string]$scriptPath)

$packages = Join-Path $PSScriptRoot ".tools"
$allLibPath = Join-Path $packages "lib\netstandard*\*.dll"
$libPath = Join-Path $packages "lib\Microsoft.CodeAnalysis.CSharp.Scripting.dll"

$librariesToLoad = @(
    'System.Collections.Immutable/1.3.1',
    'System.Reflection.Metadata/1.4.1',
    'Microsoft.CodeAnalysis.Analyzers',
    'Microsoft.CodeAnalysis.Common',
    'Microsoft.CodeAnalysis.CSharp',
    'Microsoft.CodeAnalysis.Scripting.Common',
    'Microsoft.CodeAnalysis.CSharp.Scripting'
);

if (!(Test-Path $packages)) {
    mkdir $packages | Out-Null

    $librariesToLoad | % {
        $file = Join-Path $packages "$($_.Split('/')[0]).zip"
        if (!(Test-Path $file)) {
            Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/$_" -OutFile $file
        }
        Expand-Archive $file -DestinationPath $packages -Force
    }

    Copy-Item $allLibPath (Join-Path $packages "lib") -Force
}

$imm_col = [System.Reflection.Assembly]::LoadFrom((Join-Path $packages "lib\System.Collections.Immutable.dll"))

$onAssemblyResolveEventHandler = [System.ResolveEventHandler] {
    param($sender, $e)
    if ($e.Name.StartsWith("System.Collections.Immutable")) {
        return $imm_col
    }
    foreach($assembly in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
        if ($assembly.FullName -eq $e.Name) {
          return $assembly
        }
    }
    return $null
}
[System.AppDomain]::CurrentDomain.add_AssemblyResolve($onAssemblyResolveEventHandler)

Add-Type -Path (Join-Path $packages "lib\System.Reflection.Metadata.dll")
Add-Type -Path $libPath

$script = Get-Content $scriptPath
$result = [Microsoft.CodeAnalysis.CSharp.Scripting.CSharpScript]::EvaluateAsync($script).Result;

[System.AppDomain]::CurrentDomain.remove_AssemblyResolve($onAssemblyResolveEventHandler)