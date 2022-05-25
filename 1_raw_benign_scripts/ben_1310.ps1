# There is no facility to replace passwords in RDCMan once they are stored. The only way is to create a new custom credential.
# If you open your *.rdg file in a text editor, locate the stored <password>, you can then decrypt it using this script.
# This script can also encrypt a plain text password in rdg format which can be used to overwrite an existing one in the xml.
Add-Type -AssemblyName System.Security;

Function EncryptPassword {
    [CmdletBinding()]
    param([String]$PlainText = $null)

    # convert to RDCMan format: (null terminated chars)
    $withPadding = @()
    foreach($char in $PlainText.ToCharArray()) {
        $withPadding += [int]$char
        $withPadding += 0
    }

    # encrypt with DPAPI (current user)
    $encrypted = [Security.Cryptography.ProtectedData]::Protect($withPadding, $null, 'CurrentUser')
    return $base64 = [Convert]::ToBase64String($encrypted)
}

Function DecryptPassword {
    [CmdletBinding()]
    param([String]$EncodedPasswordString = $null)
    
    $decoded = [Convert]::FromBase64String($EncodedPasswordString)
    $decryptedBytes = [Security.Cryptography.ProtectedData]::Unprotect($decoded, $null, 'CurrentUser')
    $decryptedString = [Text.Encoding]::ASCII.GetString($decryptedBytes)
    
    # trim null terminating chars from padding (does not account for pwds with spaces in them)
    $sb = [System.Text.StringBuilder]::new()
    foreach($char in $decryptedString.ToCharArray()) {
        if($char -ne 0) {
            $sb.Append($char) > $null
        }
    }
    return $sb.ToString()
}

# round trip test
$plainText = 'AllYourPasswordsAreBelongToUs'

# encrypt
$encrypted = EncryptPassword($plainText)
Write-Host "Encrypted Base64 Encoded PWD: $encrypted"

# decrypt
$decrypted = DecryptPassword($encrypted)
Write-Host "Decrypted PWD: $decrypted"

# assert equality
if($plainText -ne $decrypted) {
    Write-Error "Round trip failed!" 
}