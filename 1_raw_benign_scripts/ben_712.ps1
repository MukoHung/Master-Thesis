ls D:\Code\PSRec\Screenshots |% {
    $thisHash = identify -quiet -format "%#" $_.FullName
    
    if ($thisHash -eq $lastHash) {
        rm $_.FullName
        write-host "Removed duplicate $($_.FullName)"
    }
    $lastHash = $thisHash
}

$count = 0
ls D:\Code\PSRec\Screenshots |% {
    $count++
    write-host "Renaming $($_.FullName)"
    ren $_.FullName D:\Code\PSRec\Screenshots\Shot$($count.ToString("0000")).png
}