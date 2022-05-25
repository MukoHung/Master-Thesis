# This script can be used to generate a ca-cert.crt file that can be used by
# Unix-based utilities like curl, git, ...
#
# It allows you to synchronize the root certificates (CA) based on the
# certificates installed in your Windows certification stores. You can also
# get a list from Mozilla, but I think it's convenient to have the same CA
# certificates in all tools.
#
# Some examples on how to use this script:
#
#   CreateCaCert.ps1 -StoreLocation CurrentUser
#   CreateCaCert.ps1 -StoreLocation LocalMachine | Out-File -Encoding utf8 ca-cert.crt
#
# Written by Ramon de Klein <mail@ramondeklein.nl>

[CmdletBinding()]
Param(
    [ValidateSet(
        [System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser,
        [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine)]
    [string]
    $StoreLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser
)

$maxLineLength = 77

# Open the store
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store ([System.Security.Cryptography.X509Certificates.StoreName]::AuthRoot, $StoreLocation)
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly);

# Write header
Write-Output "# Root certificates ($StoreLocation) generated at $(Get-Date)"

# Write all certificates
Foreach ($certificate in $store.Certificates)
{
    # Start with an empty line
    Write-Output ""

    # Convert the certificate to a BASE64 encoded string
    $certString = [Convert]::ToBase64String($certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert));

    # Write the actual certificate
    Write-Output "# Friendly name: $($certificate.FriendlyName)"
    Write-Output "# Issuer:        $($certificate.Issuer)"
    Write-Output "# Expiration:    $($certificate.GetExpirationDateString())"
    Write-Output "# Serial:        $($certificate.SerialNumber)"
    Write-Output "# Thumbprint:    $($certificate.Thumbprint)"
    Write-Output "-----BEGIN CERTIFICATE-----"
    For ($i = 0; $i -lt $certString.Length; $i += $maxLineLength)
    {
        Write-Output $certString.Substring($i, [Math]::Min($maxLineLength, $certString.Length - $i))
    }
    Write-Output "-----END CERTIFICATE-----"
}
