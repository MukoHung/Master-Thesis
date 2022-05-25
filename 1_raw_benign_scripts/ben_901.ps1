function ConvertTo-Base64KMSEncryptedString {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [String[]]
        $String,

        [Parameter(
            Mandatory = $true
        )]
        [string]
        $KeyId,

        [hashtable]$EncryptionContext
    )
    
    process {
        foreach ($SourceString in $String) {
            $byteArray = [System.Text.Encoding]::UTF8.GetBytes($SourceString)
            $stringStream = [System.IO.MemoryStream]::new($ByteArray)
            try {
                $Params = @{
                    KeyId = $KeyId 
                    Plaintext = $stringStream 
                    ErrorAction = 'Stop'
                }
                if ($EncryptionContext) {
                    $Params['EncryptionContext'] = $EncryptionContext
                }
                $KMSResult = Invoke-KMSEncrypt @Params

                [System.Convert]::ToBase64String($KMSResult.CiphertextBlob.ToArray())
            }
            finally {
                if ($stringStream) { $stringStream.Dispose() }
                if ($KMSResult.CiphertextBlob) { $KMSResult.CiphertextBlob.Dispose() }
            }
        }
    }
}

function ConvertFrom-Base64KMSEncryptedString {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [String[]]
        $EncryptedString,

        [hashtable]$EncryptionContext
    )
    
    process {
        foreach ($SourceString in $EncryptedString) {
            try{
                $byteArray = [System.Convert]::FromBase64String($SourceString)
            }
            Catch {
                Write-Error -ErrorRecord $_
                continue
            }
            $stringStream = [System.IO.MemoryStream]::new($byteArray)
            try {
                $Params = @{
                    CiphertextBlob = $stringStream 
                    ErrorAction = 'Stop'
                }
                if ($EncryptionContext) {
                    $Params['EncryptionContext'] = $EncryptionContext
                }
                $KMSResult = Invoke-KMSDecrypt @Params

                $reader = [System.IO.StreamReader]::new($KMSResult.Plaintext)
                $reader.ReadToEnd()
            }
            finally {
                if ($reader){ $reader.Dispose() }
                if ($stringStream){ $stringStream.Dispose() }
            }
        }
    }
}