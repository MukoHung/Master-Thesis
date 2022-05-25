function unzip($path,$to) {
    $7z = "$env:TEMP\7z"
    if (!(test-path $7z) -or !(test-path "$7z\7za.exe")) { 
        if (!(test-path $7z)) { md $7z | out-null }
        push-location $7z
        try {
            write-host "Downloading 7zip" -foregroundcolor cyan
            $wc = new-object system.net.webClient
            $wc.headers.add('user-agent', [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox)
            $wc.downloadFile("http://softlayer-dal.dl.sourceforge.net/project/sevenzip/7-Zip/9.20/7za920.zip","$7z\7z.zip")
            write-host "done." foregroundcolor green

            add-type -assembly "system.io.compression.filesystem"
            [io.compression.zipfile]::extracttodirectory("$7z\7z.zip","$7z")
            del .\7z.zip
        }
        finally { pop-location }
    }

    if ($path.endswith('.tar.gz') -or $path.endswith('.tgz')) {
        # This is some crazy s**t right here
        $x = "cmd"
        $y = "/C `"^`"$7z\7za.exe^`" x ^`"$path^`" -so | ^`"$7z\7za.exe^`" x -y -si -ttar -o^`"$to^`""
        & $x $y
    } else {
        & "$7z\7za.exe" x $path -y -o"$to"
    }
}