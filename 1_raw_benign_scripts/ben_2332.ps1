$p= (frida-ps | Select-String -Pattern xxx.exe) -split ' '  -imatch 0
frida -p $p