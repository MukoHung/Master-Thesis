while ($true) {
    $i = Get-Random 10

    $ext = ".dat"
    $container = "test"
    $filename = "test" + ([string]$i).padleft(2,'0') + $ext

    $accountname = "xxxxxxxxxx"
    $sas = "xxxxxxxxxx"
    $url = "https://" + $accountname + ".blob.core.windows.net/" + $container + "/" + $filename + $sas

    ./azcopy.exe cp $url .
    sleep $($i * 10)
}