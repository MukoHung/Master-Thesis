$com = New-Object System.IO.Ports.SerialPort "COM4", 9600, ([System.IO.Ports.Parity]::None)

$com.DtrEnable = $true
$com.RtsEnable = $true
$com.Handshake=[System.IO.Ports.Handshake]::None
$com.NewLine = "`r"
$com.Encoding=[System.Text.Encoding]::GetEncoding("UTF-8")

$com.Open()
$com.Write($args[0])
$com.Close()
