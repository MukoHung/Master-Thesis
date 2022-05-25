$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)

foreach ($i in Get-ChildItem -Recurse -Force) {
    if ($i.PSIsContainer) {
        continue
    }
    
    if ($i.Extension.ToLower() -ne ".cs") {
        continue
    }

    $content = Get-Content $i.Fullname

    if ($content -ne $null) {
        [System.IO.File]::WriteAllLines($i.Fullname, $content, $Utf8NoBomEncoding)
    } else {
        Write-Host "No content from: $i"   
    }
}