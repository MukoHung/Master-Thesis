## Powershell method of transfering small (< 1 MB) binary files via Clipboard
##
## NB: Unwise to attempt to encode binary files exceeding 1 MB due to excessive memory consumption

## Powershell 5.0> 
# On the transmission end:
$Content = Get-Content -Encoding Byte -Path binaryfile.xxx
[System.Convert]::ToBase64String($Content) | Set-Clipboard

# On the receiving end
$Base64 = Get-Clipboard -Format Text -TextFormatType Text
Set-Content -Value $([System.Convert]::FromBase64String($Base64)) -Encoding Byte -Path binaryfile.zip


## Prior to Powershell 5.0
# On the transmission end:
$Content = Get-Content -Encoding Byte -Path binaryfile.xxx
[System.Convert]::ToBase64String($Content) | clip

# On the receiving end:
# Paste the Base64 encoded contents in a text file manually:
$Base64 = Get-Content –Path binaryfile.xxx.base64_encoded.txt
Set-Content -Value $([System.Convert]::FromBase64String($Base64)) -Encoding Byte -Path binaryfile.zip

