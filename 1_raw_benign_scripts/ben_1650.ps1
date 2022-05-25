# Get settings to enter on the Identity Provider (IdP) to allow authentication to Service Provider (SP)
function Get-IdP-Settings-From-SP($Metadata) {
    [xml]$SPMetadata = $Metadata
    $SPAssertionConsumerServiceURL = $SPMetadata.EntityDescriptor.SPSSODescriptor.AssertionConsumerService |
    ? {$_.Binding -eq "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"} |
    % {$_.Location}
    $SPIssuerURI = $SPMetadata.EntityDescriptor.entityID
    $SPSignatureCertificate = $SPMetadata.EntityDescriptor.SPSSODescriptor.KeyDescriptor |
    ? {$_.use -eq "signing"} |
    Select-Object -Last 1 |
    % {$_.KeyInfo.X509Data.X509Certificate}
    Write-Host "SP Issuer URI: $SPIssuerURI"
    Write-Host "SP Assertion Consumer Service URL: $SPAssertionConsumerServiceURL"
    Write-Host "SP Signature Certificate:"
    Write-Host $SPSignatureCertificate
}
