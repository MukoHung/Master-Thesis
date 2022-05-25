#  CA Generation
# {hex}30030101FF => ASN.1 BasicConstraints: CA:TRUE
# $asn1=([System.Security.Cryptography.X509Certificates.X509BasicConstraintsExtension]::new($true, $flase, 0,$true)).RawData
# $asn1 | Format-Hex -Encoding Ascii
 
$ca_params =@{ 
   "Type"              = "Custom";
   "Subject"           = "CN=Local CA";
   "FriendlyName"      = "Local CA";
   "KeyAlgorithm"      = "RSA";
   "KeyLength"         = 2048;
   "KeyUsage"          = "CertSign";
   "TextExtension"     = @("2.5.29.19={critical}{hex}30030101FF");
   "NotAfter"          = ((Get-Date).AddYears(10)); 
   "CertStoreLocation" = "Cert:\CurrentUser\My";
}
 
$root=New-SelfSignedCertificate @ca_params 
$root.ToString()

# Certificate generation
$cert_params =@{ 
   "Signer"            = $root;
   "Type"              = "CodeSigningCert";
   "Subject"           = "CN=Code Signer";
   "FriendlyName"      = "Code Signer";
   "KeyAlgorithm"      = "RSA";
   "KeyLength"         = 2048;
   "KeyUsage"          = "DigitalSignature";
   "NotAfter"          = ((Get-Date).AddYears(10)); 
   "CertStoreLocation" = "Cert:\CurrentUser\My";
}

$code=New-SelfSignedCertificate @cert_params
$code.ToString()
 
# tmp file
$ca_file = [System.IO.Path]::GetTempFileName()

# Export CA cert to trusted root
Export-Certificate -Type CERT -Cert $root -FilePath $ca_file -Force
# This require interactive confirmation by user
Import-Certificate -CertStoreLocation Cert:\CurrentUser\Root -FilePath $ca_file
 
# Export signer cert to trusted publishers
Export-Certificate -Type CERT -Cert $code -FilePath $ca_file -Force
Import-Certificate -CertStoreLocation Cert:\CurrentUser\TrustedPublisher -FilePath $ca_file
# clean up
Remove-Item $ca_file
 
# $code=(Get-ChildItem cert:\CurrentUser\my -CodeSigningCert)[0]
 
# sample script
'Write-Host "Hello, World!"' >.\sign_me.ps1

# Change execution policy for Windows client computers
# https:/go.microsoft.com/fwlink/?LinkID=135170
Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope CurrentUser -Force
 
# Default policy 
# Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser  -Force
 
Set-AuthenticodeSignature .\sign_me.ps1 $code
 
 # run sample script
.\sign_me.ps1