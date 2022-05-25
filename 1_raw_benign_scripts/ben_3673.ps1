# This code is released to the Public Domain.
# Alternatively, you can use one of the following licenses: Unlicense OR CC0-1.0 OR WTFPL OR MIT-0 OR BSD-3-Clause

param(
    [Parameter(Mandatory=$True,Position=1)]
    [string] $server,
    [string] $iface = "Wi-Fi",  # EDIT AS NEEDED
    [string] $dns_service = "dnscrypt-proxy"  # EDIT AS NEEDED
)

switch ( $server )
{
    "dhcp"    { }
    "office"  { $server = 'ENTER YOUR OFFICE DNS SERVER HERE' }  # EDIT AS NEEDED
    "local"   { $server = '127.0.0.1' }
    default   { Write-Error "Unknown option '$sel'; choose one of 'office' or 'local' or 'dhcp'!"; exit }
}

if ($server -eq '127.0.0.1') {
    Write-Output "Ensuring service '$dns_service' is running"
    Start-Service $dns_service
}

Write-Output "Setting DNS for $iface to $server ..."
if ($server -eq "dhcp") {
    Set-DnsClientServerAddress -InterfaceAlias $iface -ResetServerAddresses
} else {
    Set-DnsClientServerAddress -InterfaceAlias $iface -ServerAddresses $server
}

# "2" (uint16) is the actual ID for the "IPv4" address family
# You can verify using this command:
# Get-DnsClientServerAddress | where InterfaceAlias -eq "Wi-Fi" | Select-Object -Property AddressFamily,ServerAddresses
Get-DnsClientServerAddress | where {$_.InterfaceAlias -eq $iface -and $_.AddressFamily -eq 2}
