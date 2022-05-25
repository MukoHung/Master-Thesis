#region Attack validations
wmic /node:169.254.37.139 /user:Administrator /password:badpassword process call create notepad.exe

Invoke-WmiMethod -ComputerName 169.254.37.139 -Credential Administrator -Class Win32_Process -Name Create -ArgumentList notepad.exe 

$CimSession = New-CimSession -ComputerName 169.254.37.139 -Credential Administrator
Invoke-CimMethod -CimSession $CimSession -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = 'notepad.exe' } 
$CimSession | Remove-CimSession

winrm --% invoke Create wmicimv2/Win32_Process @{CommandLine="notepad.exe"} -remote:169.254.37.139 -username:Administrator -password:badpassword
#endregion

#region Demo #1: Identify the provider DLL that implements Win32_Process Create
$Class = [WmiClass] 'root/cimv2:Win32_Process'

$ProviderName = $Class.Qualifiers['Provider'].Value
# Provider name: CIMWin32

$ProviderCLSID = Get-CimInstance -ClassName __Provider -Filter "Name = '$ProviderName'" | Select -ExpandProperty CLSID
# Provider CLSID: {d63a5850-8f16-11cf-9f47-00aa00bf345c}

Get-ItemPropertyValue -Path "Registry::HKEY_CLASSES_ROOT\CLSID\$ProviderCLSID\InProcServer32" -Name '(default)'
# Provider DLL: C:\WINDOWS\system32\wbem\cimwin32.dll
#endregion


#region Demo #2: Identify code that potentially writes to the Microsoft-Windows-WMI-Activity ETW provider
filter ConvertTo-String {
<#
.SYNOPSIS

Converts the bytes of a file to a string.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause
Required Dependencies: None
Optional Dependencies: None

.DESCRIPTION

ConvertTo-String converts the bytes of a file to a string that has a
1-to-1 mapping back to the file's original bytes. ConvertTo-String is
useful for performing binary regular expressions.

.PARAMETER Path

Specifies the path to the file to convert.

.EXAMPLE

PS C:\>$BinaryString = ConvertTo-String C:\Windows\SysWow64\kernel32.dll
PS C:\>$HotpatchableRegex = [Regex] '[\xCC\x90]{5}\x8B\xFF'
PS C:\>$HotpatchableRegex.Matches($BinaryString)

Description
-----------
Converts kernel32.dll into a string. A binary regular expression is
then performed on the string searching for a hotpatchable code
sequence - i.e. 5 nop/int3 followed by a mov edi, edi instruction.

.NOTES

The intent of ConvertTo-String is not to replicate the functionality
of strings.exe, rather it is intended to be used when
performing regular expressions on binary data.
#>

    [OutputType([String])]
    Param (
        [Parameter( Mandatory = $True,
                    Position = 0,
                    ValueFromPipeline = $True )]
        [ValidateScript({-not (Test-Path $_ -PathType Container)})]
        [String]
        $Path
    )

    $FileStream = New-Object -TypeName IO.FileStream -ArgumentList (Resolve-Path $Path), 'Open', 'Read'

    # Note: Codepage 28591 returns a 1-to-1 char to byte mapping
    $Encoding = [Text.Encoding]::GetEncoding(28591)
    
    $StreamReader = New-Object IO.StreamReader($FileStream, $Encoding)

    $BinaryText = $StreamReader.ReadToEnd()

    $StreamReader.Close()
    $FileStream.Close()

    Write-Output $BinaryText
}

# Microsoft-Windows-WMI-Activity ETW Provider GUID
# This can be obtained by running the following: logman.exe query providers
$ProviderGUID = [Guid] '{1418EF04-B0B4-4623-BF7E-D74AB47BBDAA}'
$ProviderGUIDRegexString = ($ProviderGUID.ToByteArray() | ForEach-Object { "\x$($_.ToString('X2'))" }) -join ''
# \x04\xEF\x18\x14\xB4\xB0\x23\x46\xBF\x7E\xD7\x4A\xB4\x7B\xBD\xAA
$ProviderGUIDRegex = [Regex] $ProviderGUIDRegexString

<# 
   Identify all PEs in System32 that contain the ETW provider GUID byte pattern
   and display the offsets of the byte pattern. If the byte pattern is found,
   you can take the index and convert it to a virtual address and jump right to
   it in IDA. ConvertTo-String is used to convert a byte array into a string such
   that there is a one-to-one byte to character correspondance, enabling binary
   regex searching.
#>
$ProviderMatches = ls C:\Windows\System32\* -Include '*.dll', '*.sys', '*.exe' |
    Where-Object { (ConvertTo-String -Path $_.FullName) -match $ProviderGUIDRegexString } |
        ForEach-Object {
            $RegexMatches = $ProviderGUIDRegex.Matches((ConvertTo-String -Path $_.FullName))

            [PSCustomObject] @{
                FileName = $_.FullName
                Matches = $RegexMatches
            }
        }

<#
Matches on the following files:

* C:\Windows\System32\aitstatic.exe
* C:\Windows\System32\miutils.dll
* C:\Windows\System32\wbemcomn.dll

Now we need to identify the file offset so that we can then identify the VA and track it down in IDA
#>
#endregion


#region Demo #3: Identify potential event log events generated after executing WMI "lateral movement"

# Log the time prior to executing the action.
# This will be used as parth of an event log XPath filter.
$DateTimeBefore = [Xml.XmlConvert]::ToString((Get-Date).ToUniversalTime())

#region Perform your attack here
$CreateArgs = @{
    Namespace = 'root/cimv2'
    ClassName = 'Win32_Process'
    MethodName = 'Create'
    Arguments = @{ CommandLine = 'notepad.exe' }
}

Invoke-CimMethod @CreateArgs
#endregion

Start-Sleep -Seconds 5

# Iterate over every event log that has populated events and
# has events that were generated after we noted the time.
$Events = Get-WinEvent -ListLog * | Where-Object { $_.RecordCount -gt 0 } | ForEach-Object {
    Get-WinEvent -LogName $_.LogName -FilterXPath "*[System[TimeCreated[@SystemTime >= '$DateTimeBefore']]]" -ErrorAction Ignore
}

#endregion


#region Demo #4: Capture Microsoft-Windows-WMI-Activity ETW trace

logman start WMITrace -p Microsoft-Windows-WMI-Activity 0xFFFFFFFFFFFFFFFF 0xFF -o WMITrace.etl -ets

#region Perform your attack here
$CreateArgs = @{
    Namespace = 'root/cimv2'
    ClassName = 'Win32_Process'
    MethodName = 'Create'
    Arguments = @{ CommandLine = 'notepad.exe' }
}

Invoke-CimMethod @CreateArgs
#endregion

logman stop WMITrace -ets
tracerpt WMITrace.etl -o WMITrace.evtx -of EVTX -lr

# Interesting, relevant event IDs: 11, 12, 22, 23

Get-WinEvent -Path .\WMITrace.evtx -FilterXPath "*[System[EventID=11 or EventID=12 or EventID=22 or EventID=23 and EventID!=0]]"
#endregion


#region Demo #5: Win32_Process class cloning evasion test - i.e. attempt to evade event ID 23
$Class = [WmiClass] 'Win32_Process'
$NewClass = $Class.Derive('Win32_Not_A_Process')
# Persist the new class to the WMI repository
$NewClass.Put()

# Microsoft-Windows-WMI-Activity/Trace keyword value: 0x8000000000000000
# We're not interested in Microsoft-Windows-WMI-Activity/Debug events
logman start WMITrace -p Microsoft-Windows-WMI-Activity 0x8000000000000000 0xFF -o WMITrace2.etl -ets

#region Perform your attack here
$CreateArgs = @{
    Namespace = 'root/cimv2'
    ClassName = 'Win32_Not_A_Process'
    MethodName = 'Create'
    Arguments = @{ CommandLine = 'notepad.exe' }
}

Invoke-CimMethod @CreateArgs
#endregion

logman stop WMITrace -ets
tracerpt WMITrace2.etl -o WMITrace2.evtx -of EVTX -lr

Get-WinEvent -Path .\WMITrace2.evtx -FilterXPath "*[System[EventID=11 or EventID=12 or EventID=22 or EventID=23 and EventID!=0]]"

# Our evasion attempt appears to have failed because event ID 23 was still captured.
#endregion


#region Demo #6: Capture a WPP trace for WMI-related functionality
# The WPP provider GUID for wbemcomn.dll and wbemcore.dll: 1ff6b227-2ca7-40f9-9a66-980eadaa602e
# This demo requires the Windows SDK to be installed
logman start WMIWPPTrace -p "{1ff6b227-2ca7-40f9-9a66-980eadaa602e}" 7 0xFF -ets -mode 0x8100 -rt
"C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x86\tracelog.exe" -start WMIWPPTrace -guid #1FF6B227-2CA7-40f9-9A66-980EADAA602E -rt -level 5 -flag 0x7
"C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x86\tracefmt.exe" -rt WMIWPPTrace -displayonly
logman stop WMIWPPTrace -ets
#endregion