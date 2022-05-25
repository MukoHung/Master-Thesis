param
(
    [string]$Hostname = $env:COMPUTERNAME
)
try
{
    $ErrorActionPreference = 'Stop';
    $CertificateThumbprint = (New-SelfSignedCertificate -DnsName $Hostname -CertStoreLocation Cert:\LocalMachine\My).Thumbprint;
    New-WSManInstance -ResourceURI 'winrm/config/listener' -SelectorSet @{Address='*';Transport='https'} -ValueSet @{Hostname=$Hostname;CertificateThumbprint=$CertificateThumbprint}
}
catch
{
    throw $_;
}
