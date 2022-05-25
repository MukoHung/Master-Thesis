function Test-MSWorkflowCompilerDetection {
    [CmdletBinding()]
    param (
        [String]
        [ValidateNotNullOrEmpty()]
        $Arg1FileName = 'Test.xml',

        [String]
        [ValidateNotNullOrEmpty()]
        $Arg2FileName = 'Results.xml',

        [String]
        [ValidateNotNullOrEmpty()]
        $PayloadPath = 'Payload.xoml',

        [Switch]
        $PackageInXoml,

        [String]
        [ValidateSet('CSharp', 'VB')]
        $PayloadLanguage = 'CSharp',

        [String]
        [ValidateNotNullOrEmpty()]
        $WorkflowCompilerDestinationPath,

        [String]
        [ValidateNotNullOrEmpty()]
        $StdoutFilePath = 'stdout.txt',

        [String]
        [ValidateNotNullOrEmpty()]
        $StderrFilePath = 'stderr.txt'
    )

    $CSharpPayload = @'
public class Foo : SequentialWorkflowActivity {
    public Foo() {
        Console.WriteLine("FOOO!!!!");
    }
}
'@

    $VBDotNetPayload = @'
Class Foo : Inherits SequentialWorkflowActivity
    Public Sub New()
        Console.WriteLine("FOOO!!!!")
    End Sub
End Class
'@

    $XOMLTemplate = @'
<SequentialWorkflowActivity x:Class="MyWorkflow" x:Name="MyWorkflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow">
    <CodeActivity x:Name="codeActivity1" />
    <x:Code><![CDATA[
INSERTPAYLOADHERE
    ]]></x:Code>
</SequentialWorkflowActivity>
'@

    # Split out payload path path and filename
    $PartialPath = Split-Path -Path $PayloadPath -Parent
    $Filename = Split-Path -Path $PayloadPath -Leaf
    if (($PartialPath -eq '') -or ($PartialPath -eq '.')) {
        # A relative path was supplied. Expand the current working directory.
        $PayloadFullPath = Join-Path -Path $PWD.Path -ChildPath $Filename
    } else {
        # A full path was supplied
        $PayloadFullPath = Join-Path -Path $PartialPath -ChildPath $Filename
    }

    # Split out CompilerInput path and filename
    $PartialPath = Split-Path -Path $Arg1FileName -Parent
    $Filename = Split-Path -Path $Arg1FileName -Leaf
    if (($PartialPath -eq '') -or ($PartialPath -eq '.')) {
        # A relative path was supplied. Expand the current working directory.
        $CompilerInputOptionsPath = Join-Path -Path $PWD.Path -ChildPath $Filename
    } else {
        # A full path was supplied
        $CompilerInputOptionsPath = Join-Path -Path $PartialPath -ChildPath $Filename
    }

    # Split out payload compilation results path and filename
    $PartialPath = Split-Path -Path $Arg2FileName -Parent
    $Filename = Split-Path -Path $Arg2FileName -Leaf
    if (($PartialPath -eq '') -or ($PartialPath -eq '.')) {
        # A relative path was supplied. Expand the current working directory.
        $PayloadCompilationResultsPath = Join-Path -Path $PWD.Path -ChildPath $Filename
    } else {
        # A full path was supplied
        $PayloadCompilationResultsPath = Join-Path -Path $PartialPath -ChildPath $Filename
    }

    $CompilerInputTemplate = @"
<?xml version="1.0" encoding="utf-8"?>
<CompilerInput xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.datacontract.org/2004/07/Microsoft.Workflow.Compiler">
  <files xmlns:d2p1="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
    <d2p1:string>$($PayloadFullPath)</d2p1:string>
  </files>
  <parameters xmlns:d2p1="http://schemas.datacontract.org/2004/07/System.Workflow.ComponentModel.Compiler">
    <assemblyNames xmlns:d3p1="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler" />
    <compilerOptions i:nil="true" xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler" />
    <coreAssemblyFileName xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler"></coreAssemblyFileName>
    <embeddedResources xmlns:d3p1="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler" />
    <evidence xmlns:d3p1="http://schemas.datacontract.org/2004/07/System.Security.Policy" i:nil="true" xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler" />
    <generateExecutable xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler">false</generateExecutable>
    <generateInMemory xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler">true</generateInMemory>
    <includeDebugInformation xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler">false</includeDebugInformation>
    <linkedResources xmlns:d3p1="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler" />
    <mainClass i:nil="true" xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler" />
    <outputName xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler"></outputName>
    <tempFiles i:nil="true" xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler" />
    <treatWarningsAsErrors xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler">false</treatWarningsAsErrors>
    <warningLevel xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler">-1</warningLevel>
    <win32Resource i:nil="true" xmlns="http://schemas.datacontract.org/2004/07/System.CodeDom.Compiler" />
    <d2p1:checkTypes>false</d2p1:checkTypes>
    <d2p1:compileWithNoCode>false</d2p1:compileWithNoCode>
    <d2p1:compilerOptions i:nil="true" />
    <d2p1:generateCCU>false</d2p1:generateCCU>
    <d2p1:languageToUse>$($PayloadLanguage)</d2p1:languageToUse>
    <d2p1:libraryPaths xmlns:d3p1="http://schemas.microsoft.com/2003/10/Serialization/Arrays" i:nil="true" />
    <d2p1:localAssembly xmlns:d3p1="http://schemas.datacontract.org/2004/07/System.Reflection" i:nil="true" />
    <d2p1:mtInfo i:nil="true" />
    <d2p1:userCodeCCUs xmlns:d3p1="http://schemas.datacontract.org/2004/07/System.CodeDom" i:nil="true" />
  </parameters>
</CompilerInput>
"@

#region Pre-test environmental checks
    # Obtain the standard path to Microsoft.Workflow.Compiler.exe so that it can:
    #   1) Be invoked from the standard path/filename
    #   2) Be copied to a non-standard path/filename
    $WorkflowCompilerPath = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() + 'Microsoft.Workflow.Compiler.exe'

    # Validate that the EXE exists prior to attempting detection tests.
    if (-not (Get-Command $WorkflowCompilerPath -ErrorAction SilentlyContinue)) {
        Write-Error @"
Microsoft.Workflow.Compiler.exe is not present in the following path: $WorkflowCompilerPath
Microsoft.Workflow.Compiler.exe must exist in order to conduct detection tests.
"@
        return
    }

    if ($PackageInXoml -and (-not $PayloadPath.EndsWith('.xoml'))) {
        Write-Error "The payload filename must have a .xoml file extension when the XOML payload type is specified."
        return
    }

    if ($WorkflowCompilerDestinationPath -and (-not (Test-Path -Path (Split-Path -Path $WorkflowCompilerDestinationPath -Parent)))) {
        Write-Error 'The specified workflow compiler destination path does not exist. Ensure the directory exists before attempting to copy Microsoft.Workflow.Compiler.exe to it.'
        return
    }
#endregion

    switch ($PayloadLanguage) {
        'CSharp' {
            if ($PackageInXoml) {
                $PayloadContent = $CSharpPayload
            } else {
                $PayloadContent = @"
using System;
using System.Workflow.Activities;

$CSharpPayload
"@
            }
        }

        'VB' {
            if ($PackageInXoml) {
                $PayloadContent = $VBDotNetPayload
            } else {
                $PayloadContent = @"
Imports System
Imports System.Workflow.Activities

$VBDotNetPayload
"@
            }
        }
    }

    # Copy Microsoft.Workflow.Compiler.exe to a non-standard path/filename.
    if ($WorkflowCompilerDestinationPath) {
        $CopiedWorkflowCompiler = Copy-Item -Path $WorkflowCompilerPath -Destination $WorkflowCompilerDestinationPath -Force -PassThru
        $WorkflowCompilerPath = $CopiedWorkflowCompiler.FullName
    }

    if ($PackageInXoml) {
        $Payload = $XOMLTemplate.Replace('INSERTPAYLOADHERE', $PayloadContent)
    } else {
        $Payload = $PayloadContent
    }

    # Write the payload to disk
    Out-File -InputObject $Payload -Encoding ascii -FilePath $PayloadFullPath -Force
    $PayloadFile = Get-Item -Path $PayloadFullPath

    # Write the CompilerInput options to disk
    Out-File -InputObject $CompilerInputTemplate -Encoding ascii -FilePath $CompilerInputOptionsPath -Force
    $CompilerInputContent = Get-Item -Path $CompilerInputOptionsPath

    $CommandLineInvocation = "`"$WorkflowCompilerPath`" `"$CompilerInputOptionsPath`" `"$PayloadCompilationResultsPath`""

    $ProcessArguments = @{
        FilePath = $WorkflowCompilerPath
        ArgumentList = @("`"$CompilerInputOptionsPath`"", "`"$PayloadCompilationResultsPath`"")
        RedirectStandardOutput = $StdoutFilePath
        RedirectStandardError = $StderrFilePath
        NoNewWindow = $True
        Wait = $True
    }

    $Result = Start-Process @ProcessArguments

    if ((Get-Item -Path $StdoutFilePath)) {
        $StdoutContents = Get-Content $StdoutFilePath -Raw -ErrorAction SilentlyContinue
        $ExpectedStdout = $False

        if ($StdoutContents.Trim() -eq 'FOOO!!!!') { $ExpectedStdout = $True }
    }

    $PayloadCompilationResults = Get-Item -Path $PayloadCompilationResultsPath

    # Output results for independant evaluation
    # e.g. you could write Pester tests to validate detections against what
    # Test-MSWorkflowCompilerDetection generated/executed.
    [PSCustomObject] @{
        CommandLine = $CommandLineInvocation
        WorkflowCompilerPath = (Get-Item -Path $WorkflowCompilerPath)
        CompilerInputPath = $CompilerInputContent
        CompilerInputContents = ($CompilerInputContent | Get-Content -Raw -ErrorAction SilentlyContinue)
        PayloadPath = $PayloadFile
        PayloadContent = ($PayloadFile | Get-Content -Raw -ErrorAction SilentlyContinue)
        ExpectedStdout = $ExpectedStdout
        StdoutContents = $StdoutContents
        CompilationResultsPath = $PayloadCompilationResults
        CompilationResultsContent = ($PayloadCompilationResults | Get-Content -Raw -ErrorAction SilentlyContinue)
    }


#region Cleanup
    if ($CopiedWorkflowCompiler) { $CopiedWorkflowCompiler | Remove-Item }
    if ($PayloadFile) { $PayloadFile | Remove-Item }
    if ($CompilerInputContent) { $CompilerInputContent | Remove-Item }
    if ($PayloadCompilationResults) { $PayloadCompilationResults | Remove-Item }
    Remove-Item -Path $StdoutFilePath -ErrorAction SilentlyContinue
    Remove-Item -Path $StderrFilePath -ErrorAction SilentlyContinue
#endregion
}



<# Test components that will form the basis for test permutations:
    * Microsoft.Workflow.Compiler.exe path - standard vs. non-standard
    * Microsoft.Workflow.Compiler.exe filename - "Microsoft.Workflow.Compiler.exe" versus anything else
    * Payload language: C# vs. VB.NET - i.e. the only two supported languages
    * Payload packaging: .xoml vs. direct payload w/ arbitrary file extension.

    Test parameters that are out of my control in this script:
    * Usage of different versions of Microsoft.Workflow.Compiler.exe - i.e. different file hashes
      * Please, for the love of God, do not build detections based on blacklisted file hashes.
        An attacker can generate an infinite number of file hash variants without invalidating the signature.
#>

# These test suites are begging for Pester tests. :)
# Additional improvements: generate random filenames (or don't be tempted to build detections off static filenames)

#region Test suite #1: Microsoft.Workflow.Compiler.exe executes from its expected path/filename
$TestSuite1Results = @(
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage CSharp),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage CSharp),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage VB),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage VB),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath payload.txt -PayloadLanguage CSharp),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath payload.txt -PayloadLanguage CSharp),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath payload.txt -PayloadLanguage VB),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath payload.txt -PayloadLanguage VB)
)

# Validate that everything returned properly
$TestSuite1Results | ? { -not $_.ExpectedStdout }
#endregion

#region Test suite #2: Microsoft.Workflow.Compiler.exe executing with its standard filename but executing within a non-standard path (current working directory)
$WorkflowCompilerPath = @{ WorkflowCompilerDestinationPath = "$PWD\Microsoft.Workflow.Compiler.exe" }

$TestSuite2Results = @(
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage CSharp @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage CSharp @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage VB @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage VB @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath payload.txt -PayloadLanguage CSharp @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath payload.txt -PayloadLanguage CSharp @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath payload.txt -PayloadLanguage VB @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath payload.txt -PayloadLanguage VB @WorkflowCompilerPath)
)

# Validate that everything returned properly
$TestSuite2Results | ? { -not $_.ExpectedStdout }
#endregion

#region Test suite #3: Microsoft.Workflow.Compiler.exe executing with a non-standard path and filename
$WorkflowCompilerPath = @{ WorkflowCompilerDestinationPath = "$PWD\foo.exe" }

$TestSuite3Results = @(
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage CSharp @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage CSharp @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage VB @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath foo.xoml -PackageInXoml -PayloadLanguage VB @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath payload.txt -PayloadLanguage CSharp @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath payload.txt -PayloadLanguage CSharp @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.xml -Arg2FileName results.xml -PayloadPath payload.txt -PayloadLanguage VB @WorkflowCompilerPath),
    (Test-MSWorkflowCompilerDetection -Arg1FileName test.txt -Arg2FileName results.txt -PayloadPath payload.txt -PayloadLanguage VB @WorkflowCompilerPath)
)

# Validate that everything returned properly
$TestSuite3Results | ? { -not $_.ExpectedStdout }
#endregion