Get-ChildItem . | Foreach-Object -Process {
    
    $subPath = $_.LastWriteTime.year.tostring() + "\" + $_.LastWriteTime.year.tostring() + "." + $_.LastWriteTime.month.tostring("00")
    $from = $_.Name
    function Move-Android ($subdest) {
        Write-Output $_.Name
        $dest = $subdest + "\" + $subPath
        if (!(Test-Path $dest)) {
            New-Item -Path $dest -ItemType Directory | Out-Null
        }
        move-item $from $dest
    }
    function Move-iOS ($subdest, $prefix, $suffix) {
        Write-Output $_.Name
        $realModifiedTime = $_.LastWriteTime.ToString("yyyyMMdd_HHmmss")
        $newName="$($prefix)_$($realModifiedTime)$($suffix)"
        $dest = "$($subdest)\$($subPath)"
        Rename-Item -Path $_ -NewName $newName
        Write-Output $dest
        if (!(Test-Path $dest)) {
            New-Item -Path $dest -ItemType Directory | Out-Null
        }
        Move-Item -Path $newName -Destination $dest
    }
    switch -regex -casesensitive ($_) {
        "^VID" {
            Move-Android("Video")
            Break
        }
        "^IMG|^PANO" {
            Move-Android("Photo")
            Break
        }
        "^WIN" {
            Move-Android("Photo")
        }
        "^Screen" {
            Move-Android("Screenshot")
            Break
        }
        "iOS.heic$" {
            Move-iOS "Photo"  "IMG"  ".heic"
            Break
        }
        "iOS.png$" {
            Move-iOS "Screenshot" "Screenshot" ".png"
            Break
        }
        "iOS.jpg$" {
            Move-iOS "Saved" "Saved" ".jpg"
            Break
        }
        "iOS.MOV$" {
            Move-iOS "Video" "VID" ".MOV"
            Break
        }
        default {}
    }
}
