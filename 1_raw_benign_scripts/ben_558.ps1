function Main
{
    # File containing a MAC device list
    $filename = './c4_lan/c4_lan_list.txt'
    # The variables above may vary according to your input

    $ip = Get-IPAddress
    $broadcast = Get-BroadcastAddress $ip
    
    Send-WOL-FromFile $filename $broadcast -Verbose
}

function MainShort
{
    $broadcast = '192.168.1.151'
    Send-WOL-Once -mac '11:22:33:44:55:66' -ip $broadcast -Verbose
}

function Get-BroadcastAddress
{
    param
    (
        [Parameter(Mandatory = $True)]
        $IPAddress,
        $SubnetMask = '255.255.255.0'
    )

    filter Convert-IP2Decimal
    {
        ([IPAddress][String]([IPAddress]$_)).Address
    }

    filter Convert-Decimal2IP
    {
        ([System.Net.IPAddress]$_).IPAddressToString
    }

    [UInt32]$ip = $IPAddress | Convert-IP2Decimal
    [UInt32]$subnet = $SubnetMask | Convert-IP2Decimal
    [UInt32]$broadcast = $ip -band $subnet

    return $broadcast -bor -bnot$subnet | Convert-Decimal2IP
}

function Get-IPAddress
{
    return (Get-NetIPAddress |
            Where-Object { $_.AddressState -eq 'Preferred' -and $_.ValidLifetime -lt '24:00:00' }
    ).IPAddress | findstr [0-9].\.
    # Expr below doesn't seem to be optimized, and therefore commented out
    #$ip = (Get-NetIPConfiguration |  Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -ne "Disconnected" }).IPv4Address.IPAddress
}

function Send-WOL-FromFile
{
    <#
  .SYNOPSIS
    Read a text file with a list of MAC addresses, then send WOL for each MAC
  .PARAMETER file
   The text file to read that contains MAC addresses
  .PARAMETER ip
   The subnet IP address with targeted WOL devices
  .EXAMPLE
   Send-WOL-FromFile -file './MAC-List.txt' -ip '192.168.8.255'
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$file,
        [Parameter(Mandatory = $false, Position = 2)]
        [string]$ip = '255.255.255.255'
    )
    $broadcast = [Net.IPAddress]::Parse($ip)
    $MACAdresses = Get-Content $file
    $pkgAmount = $MACAdresses.Length

    Write-Verbose "Magic packages ($pkgAmount) have been sent to $broadcast"

    foreach ($MACAdress in $MACAdresses)
    {
        Send-WOL-Once -mac $MACAdress -ip $broadcast -port 9
    }
}

function Send-WOL-Once
{
    <#
  .SYNOPSIS  
    Send a WOL packet to a broadcast address
  .PARAMETER mac
   The MAC address of the device that need to wake up
  .PARAMETER ip
   The broadcast IP address where the WOL packet will be sent to
  .EXAMPLE 
   Send-WOL-Once -mac '00:11:32:21:2D:11' -ip '192.168.8.255' 
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]$mac,
        [Parameter(Mandatory = $True)]
        [string]$ip,
        [int]$port = 9
    )

    $mac = (($mac.replace(':', '')).replace('-', '')).replace('.', '')
    $target = 0, 2, 4, 6, 8, 10 | % { [convert]::ToByte($mac.substring($_, 2), 16) }
    $packet = (,[byte]255 * 6) + ($target * 16)

    # Debug log
    #Write-Verbose "Packet to be sent:`n`r$packet"
    Write-Verbose "MAC: $mac"
    #$packet -join " " | Out-File -FilePath './input/pkg_byte.txt' -Encoding unicode

    $UDPclient = new-Object System.Net.Sockets.UdpClient
    $UDPclient.Connect($ip, $port)
    [void]$UDPclient.Send($packet, 102)
}

MainShort