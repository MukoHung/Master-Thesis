function CreatePrinterPort { 
$server=$Printserver
$port = ([WMICLASS]“\\.\ROOT\cimv2:Win32_TCPIPPrinterPort”).createInstance() 
$port.Name=$Portname
$port.SNMPEnabled=$false 
$port.Protocol=1 
$port.HostAddress=$Portname
$port.Put() 
}

function CreatePrinter { 
$server=$Printserver
$print=([WMICLASS]“\\.\ROOT\cimv2:Win32_Printer”).createInstance() 
$print.drivername=$Driver
$print.PortName = $Portname 
$print.Shared = $true 
$print.Published = $false 
$print.Sharename = $Sharename
$print.Location = $Location
$print.Comment =  $Comment 
$print.DeviceID = $Printername  
$print.Put() 
}


$Printserver=$env:COMPUTERNAME
$Portname = $args[0]
$IPAddress = $Portname
$Driver=$args[1]
$Sharename=$args[2]
$Printername=$Sharename
$Location='Test'
$Comment='Test'

CreatePrinterPort
CreatePrinter 
