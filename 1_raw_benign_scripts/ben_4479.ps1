[IPAddress]$IP_wsl = (Get-NetIPAddress  -InterfaceAlias "vEthernet (WSL)" -AddressFamily "IPv4" | Select-Object IPAddress).ipaddress
$PrefixLength_wsl = (Get-NetIPAddress  -InterfaceAlias "vEthernet (WSL)" -AddressFamily "IPv4" | Select-Object PrefixLength).prefixlength
$idx_vpn = (Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Check Point"}  | Select-Object ifIndex).ifIndex

Function CIDRToNetMask {
    [CmdletBinding()]
    Param(
      [ValidateRange(0,32)]
      [int16]$PrefixLength=0
    )
    $bitString=('1' * $PrefixLength).PadRight(32,'0')
  
    $strBuilder=New-Object -TypeName Text.StringBuilder
  
    for($i=0;$i -lt 32;$i+=8){
      $8bitString=$bitString.Substring($i,8)
      [void]$strBuilder.Append("$([Convert]::ToInt32($8bitString,2)).")
    }
  
    return $strBuilder.ToString().TrimEnd('.')
  }

[IPAddress]$NetMask =  CIDRToNetMask($PrefixLength_wsl)
  
$NetAddress_wsl = [ipaddress]($IP_wsl.Address -band $NetMask.Address)

$routes = Get-NetRoute -AddressFamily IPv4 -InterfaceIndex $idx_vpn
foreach ($route in $routes) {
    $dst_address = [ipaddress]$route.DestinationPrefix.split('/')[0]
    $netaddress_dst = [ipaddress]($dst_address.Address -band $NetMask.Address)
    if ($netaddress_dst.IPAddressToString -eq $NetAddress_wsl.IPAddressToString) {
       Remove-NetRoute -InputObject $route  -Confirm:$false
    }
}