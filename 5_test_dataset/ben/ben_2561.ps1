[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$ModuleName,
    [Parameter(Mandatory)]
    [Alias('OutputPath')]
    [string]$DestinationPath,

    [switch]$NoBinaryProject,
    [switch]$NoScriptProject,
    [switch]$NoFormatFile,
    [switch]$NoTypesFile,
    [switch]$NoPesterTests,
    [switch]$NoXUnitTests
)
process {
    $DestinationPath ??= '.'
    $ProjectRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath((Join-Path $DestinationPath $ModuleName))
    if ((Test-Path $ProjectRoot) -and (Get-ChildItem $ProjectRoot -Force)) {
        Write-Error "The project cannot be built at '$ProjectRoot' because the path is an existing directory that is not empty."
        return
    }
    if ($ModuleName.Contains('''')) {
        Write-Error "The module name must not contain the apostraphe character (')."
        return
    }
    $Reason = [System.Management.Automation.ShouldProcessReason]::None
    $ShouldProcess = $PSCmdlet.ShouldProcess("Creating module project at path '$ProjectRoot'.", "Create module project at path '$ProjectRoot'?", 'Create module project', [ref]$Reason)
    if (!$ShouldProcess -and $Reason -ne [System.Management.Automation.ShouldProcessReason]::WhatIf) {
        return
    }
    if ($ShouldProcess) {
        $WhatIfPreference = $false
        $ConfirmPreference = $false
    }
    New-Item -ItemType Directory -Path $ProjectRoot 1>$null
    if ($ShouldProcess) { Write-Verbose ((dotnet new sln --name $ModuleName --output $ProjectRoot) -join "`n") }
    $SlnPath = Join-Path $ProjectRoot "$ModuleName.sln"
    if (!$NoBinaryProject) {
        $BinaryProjectPath = Join-Path $ProjectRoot 'src' $ModuleName
        $XUnitProjectPath = Join-Path $ProjectRoot 'src' "$ModuleName.Tests"
        if ($ShouldProcess) {
            Write-Verbose ((dotnet new classlib --name $ModuleName --output $BinaryProjectPath) -join "`n")
            Write-Verbose ((dotnet sln $SlnPath add $BinaryProjectPath) -join "`n")
            Write-Verbose ((dotnet add $BinaryProjectPath package System.Management.Automation) -join "`n")
            $csprojFilePath = Join-Path $BinaryProjectPath "$ModuleName.csproj"
            [xml]$xml = Get-Content $csprojFilePath
            $xml.project.itemgroup.PackageReference
            | Where-Object Include -eq 'System.Management.Automation'
            | ForEach-Object { $_.SetAttribute('PrivateAssets', 'all') }
            $xml.Save($csprojFilePath)
            if (!$NoXUnitTests) {
                Write-Verbose ((dotnet new xunit --name "$ModuleName.Tests" --output $XUnitProjectPath) -join "`n")
                Write-Verbose ((dotnet sln $SlnPath add $XUnitProjectPath) -join "`n")
                Write-Verbose ((dotnet add $XUnitProjectPath reference $BinaryProjectPath) -join "`n")
            }
        }
    }
    $ScriptProjectPath = Join-Path $ProjectRoot 'src' 'PowerShell'
    if (!$NoScriptProject) {
        $PublicFunctionsPath = Join-Path $ScriptProjectPath 'Public'
        $PrivateFunctionsPath = Join-Path $ScriptProjectPath 'Private'
        $PSClassesPath = Join-Path $ScriptProjectPath 'Classes'
        New-Item -ItemType Directory -Path $ScriptProjectPath, $PublicFunctionsPath, $PrivateFunctionsPath, $PSClassesPath 1>$null
    }
    if (!$NoFormatFile) {
        if (!(Test-Path $ScriptProjectPath)) { New-Item $ScriptProjectPath -ItemType Directory }
        New-Item -Path (Join-Path $ProjectRoot 'src' 'PowerShell' "$ModuleName.format.ps1xml") -Value @'
<?xml version="1.0"?>
<Configuration>
</Configuration>
'@ 1>$null
    }
    if (!$NoTypesFile) {
        if (!(Test-Path $ScriptProjectPath)) { New-Item $ScriptProjectPath -ItemType Directory 1>$null }
        New-Item -Path (Join-Path $ProjectRoot 'src' 'PowerShell' "$ModuleName.types.ps1xml") -Value @'
<?xml version="1.0"?>
<Types>
</Types>
'@ 1>$null
    }
    if (!$NoPesterTests) {
        $PesterTestsPath = Join-Path $ProjectRoot 'Tests'
        $PesterModuleTests = Join-Path $PesterTestsPath "$ModuleName-Global.Tests.ps1"
        New-Item -ItemType Directory -Path $PesterTestsPath 1>$null
        New-Item -Path $PesterModuleTests -Value (@"
using module ../../Build/$ModuleName
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Pester has special variable scope behavior')]
param()

Describe '$ModuleName' {
    BeforeAll {
    }
    Context 'Command <Command>' -ForEach @(
        Get-Command -Module '$ModuleName'
"@ + @'
        | ForEach-Object {
            @{ Command = $_ }
        }
    ) {
        # Check that the command has a defined RemotingCapability
        It 'defines RemotingCapability' {
            if ($Command.CommandType -eq 'Function') {
                [System.Management.Automation.Language.FunctionDefinitionAst]$Ast = $Command.ScriptBlock.Ast
                [System.Management.Automation.Language.AttributeAst]$Attribute = $Ast.Body.ParamBlock.Attributes.Where{$_.TypeName.GetReflectionType() -eq [CmdletBinding]} | Select-Object -First 1
                $RemotingCapability = @($Attribute.NamedArguments.Where{$_.ArgumentName -eq 'RemotingCapability'})
                $RemotingCapability | Should -HaveCount 1
            }
            elseif ($Command.CommandType -eq 'Cmdlet') {
                [System.Reflection.CustomAttributeData]$Attribute = $Command.ImplementingType.GetCustomAttributesData().Where{$_.AttributeType -eq [System.Management.Automation.CmdletAttribute]} | Select-Object -First 1
                $RemotingCapability = @($Attribute.NamedArguments.Where{$_.MemberName -eq 'RemotingCapability'})
                $RemotingCapability | Should -HaveCount 1
            }
        }

        # Check that the command has a defined OutputType
        It 'defines OutputType' {
            if ($Command.CommandType -eq 'Function') {
                [System.Management.Automation.Language.FunctionDefinitionAst]$Ast = $Command.ScriptBlock.Ast
                [System.Management.Automation.Language.AttributeAst]$Attribute = $Ast.Body.ParamBlock.Attributes.Where{$_.TypeName.GetReflectionType() -eq [OutputType]} | Select-Object -First 1
                $RemotingCapability | Should -HaveCount 1
            }
            elseif ($Command.CommandType -eq 'Cmdlet') {
                [System.Reflection.CustomAttributeData]$Attribute = $Command.ImplementingType.GetCustomAttributesData().Where{$_.AttributeType -eq [OutputType]} | Select-Object -First 1
                $RemotingCapability | Should -HaveCount 1
            }
        }

        It 'has a default parameter set' {
            if ($Command.ParameterSets.Count -gt 1) {
                $Command.DefaultParameterSet | Should -Not -BeNullOrEmpty -Because 'commands must define a default parameter set'
                $Command.ParameterSets.Name | Should -Contain $Command.DefaultParameterSet -Because 'the default parameter set must be an actual parameter set'
            }
        }
        # Check that a default parameter set is defined if a parameter set exists
        It 'has completions for <Parameter.Name>' -ForEach @(
            $ignore = @([System.Management.Automation.Cmdlet]::CommonParameters + [System.Management.Automation.Cmdlet]::OptionalCommonParameters)
            $Command.Parameters.Values
            | Where-Object {
                $_.Name -notin $ignore -and
                $_.Name -notlike '*path' -and
                $_.ParameterType -notlike [switch] -and
                !$_.ParameterType.IsAssignableTo([Enum])
            }
            | ForEach-Object {
                @{ Parameter = $_ }
            }
        ) {
            $Completer = $Parameter.Attributes
            | Where-Object {
                $_ -is [ValidateSet] -or
                $_ -is [ArgumentCompletions] -or
                $_ -is [ArgumentCompleter] -or
                $_ -is [System.Management.Automation.ArgumentCompleterFactoryAttribute] -or
                ($_.GetType().Name -like '*PathTo*' -and $_ -is [System.Management.Automation.ArgumentTransformationAttribute])
            }
            $Completer | Should -Not -BeNullOrEmpty -Because 'parameters should offer relevant argument completion'
        }
    }
}
'@) 1>$null
    }

    $DocumentationRoot = Join-Path $ProjectRoot 'src' 'Documentation'
    New-Item -ItemType Directory -Path $DocumentationRoot 1>$null
    if ($ShouldProcess) { New-MarkdownAboutHelp -OutputFolder $DocumentationRoot -AboutName $ModuleName }

    # Create build components
    $BuildRoot = Join-Path $ProjectRoot 'Build'
    New-Item -ItemType Directory -Path $BuildRoot 1>$null
    New-Item -Path (Join-Path $BuildRoot 'Build.ps1') -Value @'
#requires -Module PlatyPS
#requires -Module PSSharp.ModuleFactory

[CmdletBinding()]
param()

process {
    Push-Location -StackName 'Build.ps1'
    try {
        Set-Location (Split-Path $PSScriptRoot -Parent)
        $Data = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'Build.psd1')
        $Manifest = $Data['Manifest']
        [version]$Version = ($Data['Version'] -as [version]) ?? '1.0.0'
        $ModuleName = $Data['ModuleName']
        $OutputRoot = Join-Path $PSScriptRoot $Data['OutputFolder']
        $OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath((Join-Path $OutputRoot $ModuleName $Version))
        if (!(Test-Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath
        }
        [System.Collections.Generic.List[string]]$NestedModules = @()
        $AddRangeParameters = @{
            MemberType = 'ScriptMethod'
            Name = 'AddRange'
            Value = { param([string[]]$values) foreach ($val in $values) { [void]$this.Add($val) } }
            PassThru = $true
        }
        function newhashset { ,[System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase) }
        $RequiredAssemblies = Add-Member -InputObject (newhashset) @AddRangeParameters
        $FormatsToProcess = Add-Member -InputObject (newhashset) @AddRangeParameters
        $TypesToProcess = Add-Member -InputObject (newhashset) @AddRangeParameters
        $FunctionsToExport = Add-Member -InputObject (newhashset) @AddRangeParameters
        $AliasesToExport = Add-Member -InputObject (newhashset) @AddRangeParameters
        $CmdletsToExport = Add-Member -InputObject (newhashset) @AddRangeParameters
        $RequiredModules = [System.Collections.Generic.List[object]]::new()

        [version]$PowerShellVersion = $null

        # Build binary modules
        $GetExportedCommandsScript = {
            Set-Location $using:OutputPath
            $m = Import-Module "./$using:binaryProject.dll" -PassThru
            if (!$m) { Write-Error "Failed to import binary module '$using:binaryproject.dll' to remote sesion for command identification." }
            @($m.ExportedCmdlets.Values; $m.ExportedAliases.Values) | Select-Object -Property Name, @{L='CommandType';E={$_.CommandType.ToString()}}
        }
        foreach ($binaryProject in $Data['BinaryProjectPaths'].Keys) {
            $binaryProjectPath = $Data['BinaryProjectPaths'][$binaryProject]
            Write-Verbose "Building binary module '$BinaryProject' from path '$binaryProjectPath'."
            [void]$NestedModules.Add("$binaryProject.dll")
            [void]$RequiredAssemblies.Add("$binaryProject.dll")
            if ($Data['SetAssemblyVersionOnBuild']) {
                dotnet publish $binaryProjectPath --output $OutputPath /p:Version="$Version" /p:AssemblyFileVersion="$Version" /p:AssemblyVersion="$Version"
            }
            else {
                dotnet publish $binaryProjectPath --output $OutputPath
            }

            $cmdletAlias = Start-Job -ScriptBlock $GetExportedCommandsScript | Receive-Job -Wait -AutoRemoveJob
            $CmdletsToExport.AddRange($cmdletAlias.Where{$_.CommandType -eq 'Cmdlet'}.Name)
            $AliasesToExport.AddRange($cmdletAlias.Where{$_.CommandType -eq 'Alias'}.Name)
        }

        # Build script modules
        $ExcludeFiles = if ($Data['ScriptFilesToExclude']) { Get-Item -Path $Data['ScriptFilesToExclude'] -ErrorAction Ignore } else { @() }
        foreach ($scriptProject in $Data['ScriptModuleProjectPaths'].Keys) {
            $scriptProjectPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Data['ScriptModuleProjectPaths'][$scriptProject])
            if (!(Test-Path $ScriptProjectPath)) {
                Write-Warning "No files were identified for script module project $scriptProject at path '$scriptProjectPath'."
                continue;
            }
            $ScriptProjectFiles = Get-ChildItem -Path $scriptProjectPath -Include '*.ps1', '*.psm1' -Recurse
            | Where-Object { $_.FullName -notin $ExcludeFiles.FullName }

            if ($Data['CompileScriptModules']) {
                Write-Verbose "Building script module '$scriptProject' from path '$scriptProjectPath'."
                $ScriptModuleData = $ScriptProjectFiles
                | Build-ScriptModule -DestinationPath (Join-Path $OutputPath "$scriptProject.psm1")

                if ($ScriptModuleData) {
                    # Only add the file if it was created
                    [void]$NestedModules.Add("$scriptProject.psm1")
                }

                $RequiredAssemblies.AddRange($ScriptModuleData.RequiredAssemblies)
                if ($ScriptModuleData.RequiredModules) {
                    $RequiredModules.AddRange($ScriptModuleData.RequiredModules)
                }
                if ($RequiredPSEditions -and ($RequiredPSEditions -ne $ScriptModuleData.RequiredPSEditions)) {
                    Write-Error 'Conflicting PSEdition requirements.'
                }
                elseif (!$RequiredPSEditions) {
                    $RequiredPSEditions = $ScriptModuleData.RequiredPSEditions
                }
                if ($ScriptModuleData.PowerShellVersion -and (($PowerShellVersion ?? '1.0') -lt $ScriptModuleData.PowerShellVersion)) {
                    $PowerShellVersion = $ScriptModuleData.PowerShellVersion
                }
                if ($ScriptModuleData.IsElevationRequired) {
                    $IsElevationRequired = $true
                }
            }
            else {
                Write-Verbose "Copying script module components for '$scriptProject' from path '$scriptProjectPath'."
                Write-Warning "When script files are not compiled, all aliases are exported and requirements from script modules are not included in the manifest."
                [void]$AliasesToExport.Add('*')
                $scriptProjectOutputRoot = Join-Path $OutputPath $scriptProject
                if (!(Test-Path $ScriptProjectOutputRoot)) {
                    New-Item -ItemType Directory -Path $scriptProjectOutputRoot
                }
                $copyTargets = $ScriptProjectFiles
                | ForEach-Object {
                    $copyTarget = [PSCustomObject]@{
                        From = $_.FullName
                        To = $_.FullName.Replace($scriptProjectPath, $scriptProjectOutputRoot, [StringComparison]::OrdinalIgnoreCase)
                        ShouldCopy = $true
                    }
                    $copyTargetDir = Split-Path $copyTarget.To -Parent
                    if (!(Test-Path $copyTargetDir)) {
                        New-Item -ItemType Directory -Path $copyTargetDir 1>$null
                    }
                    if ((Test-Path $copyTarget.To) -and ([System.IO.File]::GetLastWriteTime($copyTarget.To) -ge $_.LastWriteTime)) {
                        $copyTarget.ShouldCopy = $false
                    }
                    $copyTarget
                }
                $copyTargets | Where-Object ShouldCopy | Copy-Item -Path {$_.From} -Destination {$_.To}
                [string[]]$scriptProjectOutput = $copyTargets.To
                | ForEach-Object {
                    $_.Replace($outputPath, '', [StringComparison]::OrdinalIgnoreCase).Trim('/\')
                }
                if ($scriptProjectOutput) {
                    $nestedModules.AddRange($scriptProjectOutput)
                }
            }

            # Non-compiled script files
            $TypeFiles = Get-ChildItem $scriptProjectPath -Include '*.types.ps1xml' -Recurse
            | Where-Object { $_.FullName -notin $ExcludeFiles.FullName }
            $FormatFiles = Get-ChildItem $scriptProjectPath -Include '*.format.ps1xml' -Recurse
            | Where-Object { $_.FullName -notin $ExcludeFiles.FullName }
            $OutputTypeFiles = $TypeFiles | Copy-Item -Destination {Join-Path $OutputPath $_.Name} -PassThru
            $OutputFormatFiles = $FormatFiles | Copy-Item -Destination {Join-Path $OutputPath $_.Name} -PassThru
            $TypesToProcess.AddRange($OutputTypeFiles.Name)
            $FormatsToProcess.AddRange($OutputFormatFiles.Name)

            # Identify functions to export from the module
            $PublicFunctionsDir = Join-Path $scriptProjectPath 'Public'
            if (Test-Path $PublicFunctionsDir) {
                $FunctionNames = @(Get-ChildItem $PublicFunctionsDir -Recurse -File
                | Where-Object Name -like '*-*.ps*'
                | Select-Object -ExpandProperty BaseName)
                $FunctionsToExport.AddRange($FunctionNames)
                if ($ScriptModuleData) {
                    foreach ($FunctionName in $FunctionNames) {
                        if ($ScriptModuleData.Aliases.ContainsKey($FunctionName)) {
                            $AliasesToExport.AddRange($ScriptModuleData.Aliases[$FunctionName])
                        }
                    }
                }
            }
        }

        # Build documentation
        foreach ($helpFileSource in $Data['DocumentationPaths']) {
            Write-Verbose "Building help files from source '$helpFileSource'."
            New-ExternalHelp -OutputPath $OutputPath -Path $helpFileSource -Force
        }

        # Copy explicit copy files from the manifest
        foreach ($copyFile in $Data['IncludeFiles']) {
            if ($copyFile -is [string]) {
                $To = Join-Path $OutputPath (Split-Path $copyFile -Leaf)

                Copy-Item -Path $copyFile -Destination $To
            }
            elseif ($copyFile -is [hashtable]) {
                $From = $copyFile['From'] ?? $copyFile['Path'] ?? $copyFile['FilePath'] ?? $copyFile['Source']
                $To = $copyFile['To'] ?? $copyFile['Output'] ?? $copyFile['Destination']
                if (!$From -or !$To) {
                    Write-Error "The hashtable input $copyFile is invalid. The value must contain a From and To key to indicate the where the file exists relative to the project directory and where it should be placed relative to the output path."
                }
                else{
                    Copy-Item -Path $From -Destination $To
                }
            }
            else {
                Write-Error "Cannot process IncludeFile '$copyFile' of type $(${copyFile}?.GetType() ?? "(null)"). Data type not handled."
            }
        }

        function TrimPath {
            param(
                [Parameter(ValueFromPipelineByPropertyName)]
                [Alias('FullName')]
                [string[]]$FilePath
            )
            process {
                foreach ($fp in $FilePath) {
                    $fp.Replace($OutputPath, '', [StringComparison]::OrdinalIgnoreCase).Trim('/\')
                }
            }
        }
        $MaybeSetValueParameters = @{
            InputObject = $Manifest
            MemberType  = 'ScriptMethod'
            Name        = 'MaybeSetValue'
            Value       = {
                param([string]$key, [object]$value)

                if (!$this.ContainsKey($key)) {
                    $this[$key] = $value
                }
                # return $this[$key]
            }
        }
        Add-Member @MaybeSetValueParameters
        # Build manifest
        $Manifest['Path'] = Join-Path $OutputPath "$ModuleName.psd1"
        $Manifest['FileList'] = Get-ChildItem -Path $OutputPath -Recurse | TrimPath
        $Manifest['ModuleVersion'] = $Version
        $Manifest.MaybeSetValue('TypesToProcess', $TypesToProcess)
        $Manifest.MaybeSetValue('FormatsToProcess', $FormatsToProcess)
        $Manifest.MaybeSetValue('FunctionsToExport', $FunctionsToExport)
        $Manifest.MaybeSetValue('CmdletsToExport', $CmdletsToExport)
        $Manifest.MaybeSetValue('AliasesToExport', $AliasesToExport)
        if ($PowerShellVersion) {
            $Manifest['PowerShellVersion'] = ($Manifest['PowerShellVersion'] ?? '1.0.0') -gt $PowerShellVersion ? $Manifest['PowerShellVersion'] : $PowerShellVersion
        }
        if ($CompatiblePSEditions) {
            if ($Manifest.ContainsKey('CompatiblePSEditions')) {
                if (![System.Linq.Enumerable]::SequenceEqual([string[]]@($Manifest['CompatiblePSEditions']), [string[]]@($CompatiblePSEditions)), [StringComparer]::OrdinalIgnoreCase) {
                    Write-Error "The CompatiblePSEditions specified in the script module files does not match the CompatiblePSEditions in the build.psd1 manifest section."
                }
            }
            else {
                $Manifest['CompatiblePSEditions'] = $CompatiblePSEditions
            }
        }
        $Manifest['NestedModules'] = $NestedModules | Where-Object { $_ -ne $Manifest['RootModule'] }
        if (!$Manifest.ContainsKey('RequiredAssemblies')) {
            $AssembliesFromOutput = Get-ChildItem -Path $OutputPath -Recurse -Include '*.dll' | TrimPath
            $RequiredAssemblies.AddRange($AssembliesFromOutput)
            $Manifest['RequiredAssemblies'] = $RequiredAssemblies
        }
        else {
            $RequiredAssemblies.AddRange($Manifest['RequiredAssemblies'])
            $Manifest['RequiredAssemblies'] = $RequiredAssemblies
        }
        New-ModuleManifest @Manifest
    }
    finally {
        Pop-Location -StackName 'Build.ps1'
    }
}

'@ 1>$null
    New-Item -Path (Join-Path $BuildRoot 'Build.psd1') -Value @"
@{
    # Use this file to customize actions for the build.ps1 script that runs when you build the module

    # Relative path from `$PSScriptRoot to where the output should be built
    # The module name and version will be appended to this directory, i.e. '.' will build at '`$PSScriptRoot\MyModule\1.0'
    'OutputFolder' = '.'
    # The name of the module to build, which will be used in the build output path and when naming generated
    # components such as the script module file.
    'ModuleName' = '$ModuleName'
    # The version to build. Will be used in the manifest and in the build output path.
    'Version' = '1.0.0'
    # True to set the AssemblyVersion and AssemblyFileVersion of binary projects to the version specified above
    # before building the file(s).
    'SetAssemblyVersionOnBuild' = `$true
    'CompileScriptModules' = `$true

    'IncludeFiles' = @(
        # One or more paths relative to the directory of this file indicating files that should be copied into the
        # module output. By default, only types.ps1xml and format.ps1xml files will be copied directly. The binary
        # project will be published into the output folder, script .ps1 and .psm1 files within the src/PowerShell
        # directory will be compiled into the output folder as '$ModuleName.psm1', .cdxml files within
        # src/PowerShell/cdxml will be copied directly.
        # Files in this list will be placed at './Resources/`${FileName}' in the module during build.
    )
    # Paths to binary projects to build using dotnet build. Hashtable of project name to project path.
    'BinaryProjectPaths' = @{
        '$ModuleName' = 'src/$ModuleName'
    }
    # Script modules to build. Hashtable of script module name to directories containing the script files.
    'ScriptModuleProjectPaths' = @{
        '$ModuleName' = 'src/PowerShell'
    }
    # Paths to exclude from script module build
    'ScriptFilesToExclude' = @()

    # Paths from which PlatyPS docs should be generated
    'DocumentationPaths' = @(
        'src/Documentation'
    )

    'Manifest' = @{
        'CompanyName' = 'PSSharp'
        'Author' = 'Caleb Frederickson'
        'LicenseUri' = 'https://opensource.org/licenses/MIT'
        'Copyright' = 'Copyright 2021 Caleb Frederickson'
        'ProjectUri' = 'https://github.com/Stroniax/$ModuleName'
        # 'Description' = ''
        # 'ReleaseNotes' = ''
        # 'Prerelease' = ''
        # 'ScriptsToProcess' = @()
        # 'ProcessorArchitecture' = ''
        # 'ClrVersion' = ''
        # 'DotNetFrameworkVersion' = ''
        # 'PowerShellHostName' = ''
        # 'PowerShellHostVersion' = ''
        # 'RequiredModules' = @()
        # 'ModuleList' = @()
        # 'DscResourcesToExport' = @()
        # 'PrivateData' = @{}
        # 'Tags' = @()
        # 'IconUri' = ''
        # 'RequireLicenseAcceptance' = `$false
        # 'ExternalModuleDependencies' = @()
        # 'HelpInfoUri' = ''
        # 'DefaultCommandPrefix' = ''
        # 'VariablesToExport' = @()

        # The members below may be manually overridden but values will be auto-generated by default.

        # Generated using New-Guid.
        # 'Guid' = '$(New-Guid)'

        # Assemblies will be imported into a private session and enumerated to populate this field.
        # 'CmdletsToExport' = @()

        # Files in the src/PowerShell/Functions/Public folder will be used to identify public functions.
        # 'FunctionsToExport' = @()

        # Aliases using the [Alias()] attribute will be used to populate this field.
        # 'AliasesToExport' = @()

        # This field will be populated from all *.types.ps1xml files in the output at the end of the build.
        # 'TypesToProcess' = @()

        # This field will be populated from all *.format.ps1xml files in the output at the end of the build.
        # 'FormatsToProcess' = @()

        # This field will not be included; the module type will be 'Manifest' and modules (such as the
        # script module and binary modules) will be listed under 'NestedModules'.
        # RootModule = '$ModuleName$($NoBinaryProject ? '.psm1' : '.dll')'

        # Generated from '#Requires -Version' statements in script files
        # 'PowerShellVersion' = '7.2.0'

        # Generated from all dll files in the output folder at the end of the build, and '#Requires -Assembly'
        # statements in script files.
        # Manual override will list the files required instead of including all in the output folder, but
        # assemblies indicated by #Requires -Assembly in script modules files will still be appended to this
        # list.
        # 'RequiredAssemblies' = @()

        # Generated from '#Requires -PSEdition' statements in script files. If overridden, cannot conflict
        # with a PSEdition in a script file.
        # 'CompatiblePSEditions' = @()

        # The following will be generated during the build process. Overriding the value here will be ignored.
        # ModuleVersion         - from the Version parameter of the root hashtable defined in this file
        # FileList              - from all contents of the output directory
    }
}
"@ 1>$null

    # Create VSCode components
    $VSCodeRoot = Join-Path $ProjectRoot '.vscode'
    New-Item -Path $VSCodeRoot -ItemType Directory 1>$null
    New-Item -Path (Join-Path $VSCodeRoot 'launch.json') -Value @"
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "PowerShell",
            "type": "coreclr",
            "request": "launch",
            "program": "pwsh",
            "args": [
                "-NoExit",
                "-NoProfile",
                "-Command",
                "Import-Module '`${workspaceFolder}/build/$ModuleName'"
            ],
            // "preLaunchTask": "build",
            "console": "externalTerminal",
            "cwd": "`${workspaceFolder}",
        },
        {
            "name": "Windows PowerShell",
            "type": "clr",
            "request": "launch",
            "program": "powershell",
            "args": [
                "-NoExit",
                "-NoProfile",
                "-Command",
                "Import-Module '`${workspaceFolder}/build/$ModuleName'"
            ],
            "preLaunchTask": "build",
            "console": "externalTerminal",
            "cwd": "`${workspaceFolder}"
        },
        {
            "name": ".NET Core Attach",
            "type": "coreclr",
            "request": "attach"
        }
    ]
}
"@ 1>$null
    New-Item -Path (Join-Path $VSCodeRoot 'tasks.json') -Value @"
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "type": "shell",
            "detail": "Builds the PowerShell module",
            "command": "pwsh",
            "args": [
                "-File",
                "`${workspaceFolder}/build/build.ps1"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            // "problemMatcher": "`$msCompile"
        },
        {
            "label": "pester tests",
            "type": "shell",
            "detail": "Test PowerShell execution using Pester.",
            "command": "pwsh",
            "args": [
                "-Command",
                { 
                    "quoting": "weak",
                    "value": "Import-Module '`${workspaceFolder}/build/$ModuleName'; Import-Module Pester -MinimumVersion 5.0; Invoke-Pester -Configuration @{Run=@{Path='`${workspaceFolder}/tests/'};Output=@{Verbosity='Detailed'}}"
                },
            ],
            "dependsOn": "build",
            "group": "test",
            "problemMatcher": "`$pester"
        },
        {
            "label": "xunit tests",
            "detail": "Test C# execution using XUnit.",
            "type": "shell",
            "command": "dotnet",
            "args": [
                "test",
                "`${workspaceFolder}/src/$ModuleName.Tests"
            ],
            "dependsOn": "build",
            "group":  "test",
            "problemMatcher": "`$msCompile"
        },
        {
            "label": "all tests",
            "detail": "Runs Pester and XUnit tests",
            "type": "shell",
            "group": {
                "kind": "test",
                "isDefault": true
            },
            "dependsOn": [
                "build",
                "xunit tests",
                "pester tests"
            ]
        },
        {
            "label": "clean",
            "detail": "Removes the build output of the module.",
            "type": "shell",
            "command": "pwsh",
            "args": [
                "-Command",
                "Remove-Item -Force -Recurse -Path `${workspaceFolder}/build/$ModuleName"
            ]
        }
    ]
}
"@ 1>$null
    if ($ShouldProcess) {
        Get-ChildItem -Path $ProjectRoot -Recurse
    }
}