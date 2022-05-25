# Volatility DEMO
# Powershell script
# si@foi.hr
# Image env: Win8SP1x86 on VirtualBox machine
# GIST: https://gist.github.com/capJavert/fd962d7f56ae3aa890ec36d208b8e351

# get general image info
python C:\volatility\vol.py -f C:/Users/IEUser/Desktop/IE11WIN8_1-20170318-152658.raw imageinfo | Out-File txt/imageinfo.txt
# get KDBG debugging structure for windows kernel
python C:\volatility\vol.py --profile=Win8SP1x86 -f C:/Users/IEUser/Desktop/IE11WIN8_1-20170318-152658.raw kdbgscan | Out-File txt/kdbscan.txt
# get list of processes
python C:\volatility\vol.py --profile=Win8SP1x86 -f C:/Users/IEUser/Desktop/IE11WIN8_1-20170318-152658.raw pslist | Out-File txt/pslist.txt
# get tree styled list of processes
python C:\volatility\vol.py --profile=Win8SP1x86 -f C:/Users/IEUser/Desktop/IE11WIN8_1-20170318-152658.raw pstree | Out-File txt/pstree.txt
# get memory map for explorer.exe process PID 4144 (from pslist)
python C:\volatility\vol.py --profile=Win8SP1x86 -f C:/Users/IEUser/Desktop/IE11WIN8_1-20170318-152658.raw -p 4144 memmap | Out-File txt/memmap.txt
# get .dmp memory dump for explorer.exe process PID 4144
python C:\volatility\vol.py --profile=Win8SP1x86 -f C:/Users/IEUser/Desktop/IE11WIN8_1-20170318-152658.raw -p 4144 memdump -D txt/ | Out-File txt/memdump.txt
# get list for all process that hanged in memory
python C:\volatility\vol.py --profile=Win8SP1x86 -f C:/Users/IEUser/Desktop/IE11WIN8_1-20170318-152658.raw psscan | Out-File txt/psscan.txt
# get list of DLL processes
python C:\volatility\vol.py --profile=Win8SP1x86 -f C:/Users/IEUser/Desktop/IE11WIN8_1-20170318-152658.raw dlllist | Out-File txt/dlllist.txt
# get list of processes with SID owners
python C:\volatility\vol.py --profile=Win8SP1x86 -f C:/Users/IEUser/Desktop/IE11WIN8_1-20170318-152658.raw getsids | Out-File getsids.txt
# get information for image version
python C:\volatility\vol.py --plugins=contrib/plugins --profile=Win8SP1x86 -f C:/Users/IEUser/Desktop/IE11WIN8_1-20170318-152658.raw verinfo | Out-File txt/verinfo.txt