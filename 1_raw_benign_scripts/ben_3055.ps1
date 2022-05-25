$PortName = "IP_141.218.90.17"
$PortIP = "141.218.90.17"
$DriverName = "KONICA MINOLTA C754SeriesPCL SP"
$DriverLocation = "\c754_c754e_c654_c654e_pcl6_win64_v312ssd03_en_add\KOFYSJ1_.inf"

##Leave This code commented out unless you are removing old drivers with the same name
#net stop spooler
#net start spooler
#rundll32 printui.dll PrintUIEntry /dl /q /n $DriverName
#rundll32 printui.dll,PrintUIEntry /dd  /m $DriverName



cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -d -r $PortName
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r $PortName -h $PortIP -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /u /b $DriverName /f $DriverLocation /r $PortName /m $DriverName