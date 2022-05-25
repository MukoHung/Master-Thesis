== patch3800sw.ps1 ==

Requires perl.exe to be in the same folder or in the environment PATH (for generating checksum)!

Patch firmware .img files used for Netgear WNDR3800 routers to work with Netgear WNDR3800SW
The SW model routers are specfic to SureWest Communications (ISP from northern CA)
The routers are identical, but require a different header on the .img file. This should work with any
.img file that works with a WNDR3800, including DD-WRT, OpenWRT, and the Netgear factory firmware

-- Example Command (PowerShell):
PS C:\Temp> .\patch3800sw.ps1 "C:\users\adam\Downloads\openwrt-ar71xx-generic-wndr3800-squashfs-factory(2).img" "C:\temp\test333.img"

-- Example Result:

===========================================================
PATCHING INPUT FILE FOR SUREWEST NETGEAR WNDR3800SW ROUTERS
===========================================================
-Reading input file
-Removing existing checksum byte
-Patching first 128 bytes of file with WNDR3800SW signature
-Attempting to generate new checksum byte
-Perl.exe found, generating and executing script
 * Append checksum  =>  file : C:\Users\adam\AppData\Local\Temp\tmp5794.tmp,  len : 0x340084, checksum : 0x63
-Finished
-New file - C:\temp\test333.img
-Patched and ready to flash on WNDR3800SW (if there weren't any errors)