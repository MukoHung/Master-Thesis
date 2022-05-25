# Create new self signed cert with SAN
$cert = New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\My -DnsName localhost
$thumbprint = $cert.Thumbprint

# Add self-signed cert to trusted roots
Export-Certificate -Cert $cert -FilePath .\root.crt
Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root -FilePath .\root.crt
Remove-Item .\root.crt

# Get current configurations
$netsh = netsh http show sslcert
$configs = @();
$next = @{};
for($i = 4; $i -lt $netsh.length; $i++) {
    if ($netsh[$i].Trim() -eq '') {
        $configs += $next;
        $next = @{};
    }
    else {
        $parts = $netsh[$i]-split ' : ';
        $next.Add($parts[0].Trim(), $parts[1].Trim());
    }
}

# Delete and add cert config for each local configuration
$local = $configs | Where-Object { $_["IP:Port"] -like "0.0.0.0:*" };
$local |% {
    $ip = $_['IP:Port']
    $id = $_['Application ID']
    Invoke-Expression "netsh http delete sslcert ipport='$ip'"
    Invoke-Expression "netsh http add sslcert ipport='$ip' appid='$id' certhash='$thumbprint'"
};
