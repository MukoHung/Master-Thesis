function Convert-Files($source, $dest) {

    Get-ChildItem -File -Recurse |
        Where-Object {$_.extension -match "^.(py|js|css|html)$"} |
        ForEach-Object {
        Convert-File $_.FullName $source $dest
    }
}

function Convert-File($path, $source, $dest) {
    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
    Write-Host "converting:", $path -ForegroundColor "green"
    $x = [System.IO.File]::ReadAllText($path)
    $content = $x -replace $source, $dest
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBomEncoding)
}

function dos2unix($file) {
    if ($file) {
        Convert-File $file "`r`n" "`n"
    }
    else {
        Convert-Files "`r`n" "`n"
    }
}

function unix2dos($file) {
    if ($file) {
        Convert-File $file "`n" "`r`n"
    }
    else {
        Convert-Files "`n" "`r`n"
    }
}