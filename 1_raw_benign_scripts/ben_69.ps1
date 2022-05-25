#PowerShell: convert strings copied as integers back to byte-characters
function convertchars([uint32]$a){return [bitconverter]::GetBytes([uint32]$a) | %{[char]$_}}