# Not secure by any means, just a PoC for XOR'ing data using powershell
# Credit to http://stackoverflow.com/questions/3478954/code-golf-xor-encryption

$enc = [System.Text.Encoding]::UTF8

function xor {
    param($string, $method)
    $xorkey = $enc.GetBytes("secretkey")

    if ($method -eq "decrypt"){
        $string = $enc.GetString([System.Convert]::FromBase64String($string))
    }

    $byteString = $enc.GetBytes($string)
    $xordData = $(for ($i = 0; $i -lt $byteString.length; ) {
        for ($j = 0; $j -lt $xorkey.length; $j++) {
            $byteString[$i] -bxor $xorkey[$j]
            $i++
            if ($i -ge $byteString.Length) {
                $j = $xorkey.length
            }
        }
    })

    if ($method -eq "encrypt") {
        $xordData = [System.Convert]::ToBase64String($xordData)
    } else {
        $xordData = $enc.GetString($xordData)
    }
    
    return $xordData
}

$output = xor "text to encrypt" "encrypt"
# $output = xor "ciphertext" "decrypt"

Write-Host $output