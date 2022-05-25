function Get-DnsLulz {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )

    $TheIP = $IPAddress.Split('.')

    for ($x=1; $x -le 3; $x++) {
      $NewIP = $NewIP + $TheIP[-$x] + '.'
    }

    $NewIP += $TheIP[-4]
    
    try{
      [System.Net.Dns]::GetHostByAddress($NewIP)
    } 
    catch [System.Net.Sockets.SocketException] {
      Write-Error -Message 'Host is not found stupid. You might want to use nslookup!'
    }

    
    <#    
    .SYNOPSIS
        Reverses IP Address and looks up it's DNS
    .DESCRIPTION
        This function takes in an IP address, reverses it and looks up the address in DNS.
    .EXAMPLE
        PS> Get-Lulz -IPAddress '10.1.10.1"
            Get-DnsLulz : Host is not found stupid. You might want to use nslookup!
            At line:1 char:1
            + Get-DnsLulz 10.1.1.1
            + ~~~~~~~~~~~~~~~~~~~~
            + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
            + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Get-DnsLulz
 
    .LINK
        www.mwjcomputing.com
    .NOTES
        This was written as a joke. It shouldn't be used in production.
    #>

}

New-Alias -Name 'nsloolup' -Value 'Get-DnsLulz' -Description 'All the DNS Lulz' -Force