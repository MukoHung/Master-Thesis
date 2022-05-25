#requires -RunAsAdministrator
<#
    .Synopsis
        Creates (or alters) a "code" command for opening Visual Studio Code (or VS Code Insiders)
    .Description
        Recreates the "code.cmd"" batch file command that starts Visual Studio Code (or VS Code Insiders)
        1. Adds logic to make it open in the current folder if you don't pass parameters.
        2. Makes "code" work as a command in Windows 10 Explorer's address bar.
#>
[CmdletBinding()]
param(
    # The path to the VS Code\bin folder
    [string[]]$Path = $(get-command code*.cmd -Type Application | Select -Expand Path)
)

if(!(Test-Path $Path) -or !$Path.EndsWith(".cmd")) {
    throw "Can't find the '$Path' or code.cmd (or code-insiders.cmd)"
}

$OnlyInsider = $Path -notmatch "code.cmd"

function Set-Wrapper {
    [CmdletBinding()]
    param(
        [string]$BatchPath,

        [string]$ExePath
    )

    $ScriptPath = [IO.Path]::ChangeExtension($BatchPath, ".ps1")

    Set-Content $BatchPath ('@echo off'                                                                          + "`n" +
                            'setlocal'                                                                           + "`n" +
                            'set VSCODE_DEV='                                                                    + "`n" +
                            'set ELECTRON_RUN_AS_NODE=1'                                                         + "`n" +
                                                                                                                   "`n" +
                            'if [%1]==[] goto openfolder'                                                        + "`n" +
                            'call "' + $ExePath + '" "%~dp0..\resources\app\out\cli.js" %*'                      + "`n" +
                            'goto :eof'                                                                          + "`n" +
                                                                                                                   "`n" +
                            ':openfolder'                                                                        + "`n" +
                            'call "' + $ExePath + '" "%~dp0..\resources\app\out\cli.js" "%cd%"'                  + "`n" +
                            'endlocal'                                                                           + "`n")

    Set-Content $ScriptPath ('[CmdletBinding()]'                                                                 + "`n" +
                             'param('                                                                            + "`n" +
                             '    [Parameter(ValueFromPipeline)]'                                                + "`n" +
                             '    [String[]]$Path = $($Pwd.Path)'                                                + "`n" +
                             ')'                                                                                 + "`n" +
                             'process {'                                                                         + "`n" +
                             '    ${ENV:VSCODE_DEV} = ""'                                                        + "`n" +
                             '    ${ENV:ELECTRON_RUN_AS_NODE} = 1'                                               + "`n" +
                                                                                                                   "`n" +
                             '    foreach($file in $Path) {'                                                     + "`n" +
                             '        &"' + $ExePath +'" "$PSScriptRoot\..\resources\app\out\cli.js" $file'      + "`n" +
                             '    }'                                                                             + "`n" +
                                                                                                                   "`n" +
                             '    rm Env:\VSCODE_DEV, ENV:ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue'    + "`n" +
                             '}'                                                                                 + "`n")
}


# We need to get the exe to tell if this is "Code" or "Code - Insiders"
foreach ($CodePath in $Path) {
    $CodeExe = $CodePath  | Split-Path | Split-Path | Get-ChildItem -Filter "code*.exe"

    # Create a registry entry so it'll work in Explorer (doesn't help shells)
    foreach($file in $CodeExe) {
        $null = mkdir "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$($CodeExe.Name)" -Force
        Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$($CodeExe.Name)" "(default)" $CodePath
    }

    Set-Wrapper $CodePath $CodeExe.FullName

    # Regardless of whether it's "Code-Insiders" or "Code" we  create the `code` command
    if($OnlyInsider) {
        $null = mkdir "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Code.exe" -Force
        Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Code.exe" "(default)" $CodePath

        $CodePath = $CodePath -replace "code-insiders","code"
        Set-Wrapper $CodePath $CodeExe.FullName
    }
}