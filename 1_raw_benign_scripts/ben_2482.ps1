# msbuild.ps1 
[CmdletBinding(PositionalBinding = $false)] 
param ( 
    [ValidateSet('Build', 'Clean', 'Rebuild')] 
    [string] 
    $Target = 'Build', 

    [ValidateSet('Release', 'Debug')] 
    [string] 
    $Configuration = 'Release', 

    [ValidateSet('Mixed Platforms', 'Any CPU', 'x64', 'x86')] 
    [string] $Platform = 'Mixed Platforms', 

    [Parameter(ValueFromRemainingArguments = $true)] 
    [Alias('Args')] 
    [string[]] $ArgumentList 
) 

$MSBuildCmd = $( 
    Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions\4.0 | 
    Select-Object -ExpandProperty MSBuildToolsPath | 
    Join-Path -ChildPath MSBuild.exe 
) 

$MSBuildArgs = @( 
    , '/fl' 
    , '/flp:PerformanceSummary;Verbosity=normal' 
    , '/v:normal' 
    , '/tv:4.0' 
    , "/p:Configuration=${Configuration}" 
    , "/p:Platform=${Platform}" 
    , "/t:${Target}" 
) 

& $MSBuildCmd $MSBuildArgs $ArgumentList 