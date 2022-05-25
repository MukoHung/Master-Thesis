
# Stolen from http://ctrlf5.net/?p=263 and http://www.dailycoding.com/posts/convert_image_to_base64_string_and_base64_string_to_image.aspx
function ConvertFrom-StringToMemoryStream{
    param(
        [parameter(Mandatory)]
        [string]$InputString
    )
    $stream = New-Object System.IO.MemoryStream;
    $writer = New-Object System.IO.StreamWriter($stream);
    $writer.Write($InputString);
    $writer.Flush();
    return $stream
}

function ConvertFrom-Base64toMemoryStream{
    param(
        [parameter(Mandatory)]
        [string]$Base64Input
    )

    [byte[]]$bytearray = [System.Convert]::FromBase64String($Base64Input)
    $stream = New-Object System.IO.MemoryStream($bytearray,0,$bytearray.Length)
    return $stream
}

function ConvertFrom-StreamToBase64{
    param(
        [parameter(Mandatory)]
        [System.IO.MemoryStream]$inputStream
    )
    $reader = New-Object System.IO.StreamReader($inputStream);
    $inputStream.Position = 0;
    return  [System.Convert]::ToBase64String($inputStream.ToArray())
}


function ConvertFrom-StreamToString{
    param(
        [parameter(Mandatory)]
        [System.IO.MemoryStream]$inputStream
    )
    $reader = New-Object System.IO.StreamReader($inputStream);
    $inputStream.Position = 0;
    return $reader.ReadToEnd()
}


# Example

$input = "Tes123123t"
$keyID = "c1d0d2ff-0aba-4e34-ad4b-9fcce153bc58"
$EncryptedFilePath = "$env:temp\EncryptedBase64.secret"


# Get the enrcrypted stream from Amazon
$EncryptedOuput = (Invoke-KMSEncrypt -KeyId $keyID -Plaintext $(ConvertFrom-StringToMemoryStream $input) -region us-east-1)

# Convert it to Base64 so we can write it to a file
$EncryptedBase64 = ConvertFrom-StreamToBase64 -inputStream $EncryptedOuput.CiphertextBlob
Set-Content -Path $EncryptedFilePath -Value $EncryptedBase64 -Force

# Decrypt the secret from the file
$DecryptedOutputStream = Invoke-KMSDecrypt -CiphertextBlob $(ConvertFrom-Base64toMemoryStream -Base64Input $(Get-Content $EncryptedFilePath)) -region us-east-1

# Convert the decrypted stream to a strimg
$DecryptedOutput = ConvertFrom-StreamToString -inputStream $DecryptedOutputStream.Plaintext

Write-Host ("Decrypted Output: $DecryptedOutput")