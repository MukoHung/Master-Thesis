logman --% start dotNetTrace -p Microsoft-Windows-DotNETRuntime (JitKeyword,NGenKeyword,InteropKeyword,LoaderKeyword) win:Informational -o dotNetTrace.etl -ets

# Do your evil .NET thing now. In this example, I executed the Microsoft.Workflow.Compiler.exe bypass

# logman stop dotNetTrace -ets

# This is the process ID of the process I want to capture. In this case, Microsoft.Workflow.Compiler.exe
# I got the process ID by running a procmon trace
$TargetProcessId = 8256

$WorkflowCompilerEvents = Get-WinEvent -Path .\dotNetTrace.etl -Oldest -FilterXPath "*[System[Execution[@ProcessID=$TargetProcessId]]]"

# Group events by event ID
$EventIDGrouping = $WorkflowCompilerEvents | Sort Id | Group Id

# Event ID 143 corresponds to the following ETW provider keyword: JitKeyword, NGenKeyword
$MethodLoadVerboseEvents = $EventIDGrouping | ? { $_.Name -eq '143' }

$MethodsCalled = $MethodLoadVerboseEvents.Group | % {
    $Namespace = $_.Properties[6].Value
    $Method = $_.Properties[7].Value
    $MethodComponent0 = $_.Properties[8].Value.Split('(')[0].TrimEnd()
    $MethodComponent1 = $_.Properties[8].Value.Split('(')[1]

    "$($MethodComponent0) $($Namespace)$($Method)($($MethodComponent1)"
}

# Event ID 88 corresponds to the following ETW provider keyword: InteropKeyword
$ILStubStubGeneratedEvents = $EventIDGrouping | ? { $_.Name -eq '88' }

$MarshaledNativeMethods = $ILStubStubGeneratedEvents.Group | % {
    $Namespace = $_.Properties[5].Value
    $Method = $_.Properties[6].Value
    $ReturnVal = $_.Properties[7].Value.Split('(')[0].TrimEnd()
    $Signature = $_.Properties[7].Value.Split('(')[1]

    "$($ReturnVal) $($Namespace).$($Method)($($Signature)"
}

# Event ID 151 corresponds to the following ETW provider keyword: LoaderKeyword
$LoaderDomainModuleLoadEvents = $EventIDGrouping | ? { $_.Name -eq '151' }

$ModuleLoads = $LoaderDomainModuleLoadEvents.Group | % {
    $_.Properties[5].Value
}

# Event ID 154 corresponds to the following ETW provider keyword: LoaderKeyword
$LoaderAssemblyLoadEvents = $EventIDGrouping | ? { $_.Name -eq '154' }

$AssemblyLoads = $LoaderAssemblyLoadEvents.Group | % {
    $_.Properties[4].Value
}

# Event ID 157 corresponds to the following ETW provider keyword: LoaderKeyword
$LoaderAppDomainUnloadEvents = $EventIDGrouping | ? { $_.Name -eq '157' }

$AppDomainUnloadLoads = $LoaderAppDomainUnloadEvents.Group | % {
    $_.Properties[2].Value
}

# Event ID 187 corresponds to the following ETW provider keyword: LoaderKeyword
$RuntimeStartEvents = $EventIDGrouping | ? { $_.Name -eq '187' }

$CommandLines = $RuntimeStartEvents.Group | % {
    $_.Properties[12].Value
}

$DotNetEvents = [PSCustomObject] @{
    ProcessID = $TargetProcessId
    CommandLine = $CommandLines
    AppDomainsLoaded = $AppDomainUnloadLoads
    AssembliesLoaded = $AssemblyLoads
    ModulesLoaded = $ModuleLoads
    ManagedMethodsCalled = $MethodsCalled
    PInvokeMethodsCalled = $MarshaledNativeMethods
}
