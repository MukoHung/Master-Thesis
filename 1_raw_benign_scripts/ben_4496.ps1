
function Send-Packet([string]$MacAddress){
  try {
    ## Create UDP client instance
    $UdpClient = New-Object Net.Sockets.UdpClient

    ## Define Broadcast Address as IP Endpoint
    $remoteip  = [System.Net.IPAddress]::Parse("192.168.178.255")
    $IPEndPoint = New-Object Net.IPEndPoint $remoteip, 9
    echo $IPEndPoint

    ## Construct physical address instance for the MAC address of the machine (string to byte array)
    $MAC = [Net.NetworkInformation.PhysicalAddress]::Parse($MacAddress.ToUpper())

    ## Construct the Magic Packet frame
    $Packet = [Byte[]](,0xFF*6)+($MAC.GetAddressBytes()*16)

    ## Broadcast UDP packets to the Broadcast 
    $UdpClient.Send($Packet, $Packet.Length, $IPEndPoint) | Out-Null
    $UdpClient.Close()
    }
  catch {
  $UdpClient.Dispose()
  $Error | Write-Error;
  }
}

## call function with MacAddress
Send-Packet 2CFDA1B89B2D
