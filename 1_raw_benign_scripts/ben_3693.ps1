Param ($DnsName)

$Cert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName $DnsName -Verbose
$Password = ConvertTo-SecureString -String $DnsName -Force -AsPlainText -Verbose

Export-Certificate -Cert $Cert -FilePath .\$DnsName.cer -Verbose
Export-PfxCertificate -Cert $Cert -FilePath .\$DnsName.pfx -Password $Password -Verbose

$CertThumbprint = $Cert.Thumbprint

Enable-PSRemoting -Force -Verbose
Set-Item WSMan:\localhost\Client\TrustedHosts * -Force -Verbose
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $CertThumbprint -Force -Verbose
Restart-Service WinRM -Verbose

New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "WinRMHTTPSIn" -Profile Any -LocalPort 5986 -Protocol TCP -Verbose
