# 例1
"書き込み内容" `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Set-Content -Path ".\BOMlessUTF8.txt" -Encoding Byte

# 例2
Get-Content -Path ".\Source.txt" -Raw -Encoding Default `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Set-Content -Path ".\BOMlessUTF8.txt" -Encoding Byte

# 例3
# Out-Stringを使って明示的に改行込みの文字列にする
# 例2と異なり -Raw オプションが付いていないのに注意
Get-Content -Path ".\Source.txt" -Encoding Default `
    | Out-String `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Set-Content -Path ".\BOMlessUTF8.txt" -Encoding Byte
    