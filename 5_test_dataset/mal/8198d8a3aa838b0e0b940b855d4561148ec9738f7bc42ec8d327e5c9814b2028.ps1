# Author: Matthew Graeber (@mattifestation)

$Epoch = Get-Date '01/01/1970'

# Conversion trick taken from https://blogs.technet.microsoft.com/heyscriptingguy/2017/02/01/powertip-convert-from-utc-to-my-local-time-zone/
$StrCurrentTimeZone = (Get-WmiObject Win32_timezone).StandardName
$TZ = [TimeZoneInfo]::FindSystemTimeZoneById($StrCurrentTimeZone)

# Parse out all the LogonGUID fields for sysmon ProcessCreate events
Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-Sysmon/Operational'; Id = 1 } | ForEach-Object {
    $LogonGUID = [Guid] $_.Properties[11].Value
    $LogonGUIDBytes = $LogonGUID.ToByteArray()

    # Machine GUID is retrieved from HKLM\SOFTWARE\Microsoft\Cryptography - MachineGuid
    $TruncatedMachineGuidBytes = New-Object -TypeName Byte[](16)
    [Array]::Copy($LogonGUIDBytes, 0, $TruncatedMachineGuidBytes, 0, 4)
    $TruncatedMachineGuid = [Guid] $TruncatedMachineGuidBytes

    # Retrieved by calling LsaGetLogonSessionData in sysmon.exe and pulling SECURITY_LOGON_SESSION_DATA.LogonTime
    $LogonSessionElapsed = [BitConverter]::ToInt32($LogonGUIDBytes, 4)

    $LogonTime = [TimeZoneInfo]::ConvertTimeFromUtc($Epoch.AddSeconds($LogonSessionElapsed), $TZ)

    # 0x20000000 is masked onto this GUID presumably to indicate that this is a logon GUID
    $GUIDMaskType = $SysmonGUIDMasks[[Int32]([BitConverter]::ToInt32($LogonGUIDBytes, 8) -band 0x20000000)]

    # Retrieved by calling LsaGetLogonSessionData in sysmon.exe and pulling SECURITY_LOGON_SESSION_DATA.LogonId
    $LogonIDHigh = ([BitConverter]::ToUInt32($LogonGUIDBytes, 8) -band 3758096383).ToString('X8') # (0xDFFFFFFF)
    $LogonIDLow = [BitConverter]::ToUInt32($LogonGUIDBytes, 12).ToString('X8')

    $LogonID = "0x$LogonIDHigh$LogonIDLow"

    [PSCustomObject] @{
        LogonGUID = $LogonGUID
        # Recovered portion follows
        GUIDType = $GUIDMaskType
        TruncatedMachineGuid = $TruncatedMachineGuid
        LogonTime = $LogonTime
        LogonID = $LogonID
    }
}

# Parse out all the ProcessGUID fields for sysmon ProcessCreate events
# Note: the same logic applies to ParentProcessGUID
Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-Sysmon/Operational'; Id = 1 } | ForEach-Object {
    $ProcessGUID = $_.Properties[1].Value
    $GuidBytes = $ProcessGUID.ToByteArray()

    # Machine GUID is retrieved from HKLM\SOFTWARE\Microsoft\Cryptography - MachineGuid
    $TruncatedMachineGuidBytes = New-Object -TypeName Byte[](16)
    [Array]::Copy($GuidBytes, 0, $TruncatedMachineGuidBytes, 0, 4)
    $TruncatedMachineGuid = [Guid] $TruncatedMachineGuidBytes

    # Process creation time is retrieved from ZwQueryInformationProcess (ProcessTimes - 4) in SysmonDrv which returns a KERNEL_USER_TIMES struct.
    # KERNEL_USER_TIMES.CreateTime is used for this value.
    $ProcessStartTime = [TimeZoneInfo]::ConvertTimeFromUtc($Epoch.AddSeconds([BitConverter]::ToInt32($GuidBytes, 4)), $TZ)

    # 0x10000000 is masked onto this GUID presumably to indicate that this is a process GUID
    $GUIDMaskType = $SysmonGUIDMasks[[BitConverter]::ToInt32($GuidBytes, 8)]

    # The token ID is retrieved with ZwQueryInformationToken (TokenStatistics - 10) in SysmonDrv which returns a TOKEN_STATISTICS struct.
    # TOKEN_STATISTICS.TokenId.LowPart is used for this value
    $ProcessTokenID = [BitConverter]::ToUInt32($GuidBytes, 12)

    [PSCustomObject] @{
        ProcessGUID = $ProcessGUID
        # Recovered portion follows
        GUIDType = $GUIDMaskType
        TruncatedMachineGuid = $TruncatedMachineGuid
        ProcessStartTime = $ProcessStartTime
        ProcessTokenID = "0x$($ProcessTokenID.ToString('X8'))"
    }
}
