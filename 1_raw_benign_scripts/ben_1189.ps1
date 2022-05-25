[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [String]$Hostname,

    [Parameter(Mandatory = $True)]
    [String]$Domain,

    [Parameter(Mandatory = $True)]
    [String]$IP
)

Function Get-SafeString($value) {
    if ($value -eq $null) {
      Write-Output ''
    } else {
      Write-Output $value.ToString()
    }
  }

Function Invoke-DNSRecord($Hostname, $Domain, $IP) {
        write-host "Hostname is $Hostname"
        write-host "Domain is $Domain"
        write-host "IP Address is $IP"

    $props = @{
        'Hostname' = Get-SafeString $Hostname
        'Domain' = Get-SafeString $Domain
        'IP' = Get-SafeString $IP
    }

    $Object = New-Object PSObject -Property $props

    Write-Host "$Object"

    Add-DnsServerResourceRecordA -name $Object.Hostname -ZoneName $Object.Domain -AllowUpdateAny -IPv4Address $Object.IP -TimeToLive 300
}

Invoke-DNSRecord -Hostname $Hostname -Domain $Domain -IP $IP