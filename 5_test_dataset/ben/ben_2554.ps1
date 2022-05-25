# Configuring GPU-PV on Hyper-V

This works on a Windows Pro 10 version 2004 or newer machine, confirmed to function with nVidia GPUs and recent AMD GPUs. Intel should work as well, but why do you want that?

I am not in any way responsible for working this out, that credit goes to [Nimoa at cfx.re](https://forum.cfx.re/t/running-fivem-in-a-hyper-v-vm-with-full-gpu-performance-for-testing-gpu-partitioning/1281205) and [reddit users on r/hyperv](https://www.reddit.com/r/HyperV/comments/huy09l/gpupv_in_hyperv_with_windows_10/)

1. Make sure you have Hyper-V enabled (no way!) - there's a list of other features below that you *might* need, enable those if it doesn't work.
1. Create a new VM using `New-GPUPVirtualMachine.ps1` below and install Windows 10 on it.
1. Gather driver files for your guest using one of the two methods below:

## Using the driver gathering script (recommended)

Download the `New-GPUPDriverPackage.ps1` script from this gist, it will gather the various files for you - it must be run as admin, make sure you either specify a destination path or run it from the folder you'd like the .zip created in.

1. Run the script on your host, in an admin PowerShell session. It will create `GPUPDriverPackage-[date].zip` in the current directory, or a path specified with `-Destination <path>`.
2. Copy the .zip to your guest VM and extract it.
3. Copy the contents of the extracted `GPUPDriverPackage` folder into `C:\Windows\` on the guest VM
4. Reboot the guest,  and enjoy your hardware acceleration!

This has been tested on nVidia, AMD, and Intel GPU drivers.  
(Most Intel iGPUs have support for GPU-P, though I've not tested for Quick Sync Video support in guests yet)

## Gathering driver files manually

This only covers nVidia drivers, but the process is very similar for Intel and AMD.

1. On your host system:
    1. Browse to ``C:\Windows\system32\DriverStore\FileRepository``
    2. Find the ``nvdispsi.inf_amd64_<guid>`` and/or ``nvltsi.inf_amd64_<guid>`` folders, and copy them to a temporary folder
    3. View driver details in device manager on your host, and copy all the files you see listed in `System32` or `SysWOW64` into matching folders inside your temporary folder.
2. On your guest system:
    1. Browse to ``C:\Windows\system32\HostDriverStore\FileRepository``  
       (You will likely need to create the ``HostDriverStore`` and ``FileRepository`` directories)
    2. Copy the two driver folders you collected from your host to this path.
    3. Copy ``nvapi64.dll`` (and the other  to ``C:\Windows\system32\`` on the guest as well
3. Shut down the guest VM, 
4. Make sure the VM's checkpoints are disabled, and automatic stop action is set to 'Turn Off'  
   (The VM creation script covers this, but never hurts to be sure)
5. Boot your VM, and enjoy your hardware acceleration!

----
Windows features that must be enabled:
* Hyper-V
* Windows Subsystem for Linux*
* Virtual Machine Platform

\* WSL/WSL2 is probably not necessary, but this functionality is present in Windows 10 to allow for CUDA support in WSL2, so it's probably a good idea to turn it on.
