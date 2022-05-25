mkdir "~\Desktop\AzureFriday"
cd "~\Desktop\AzureFriday"
[Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
$a = ([xml](new-object net.webclient).downloadstring("http://channel9.msdn.com/Shows/Azure-Friday/feed/mp4high"))
$a.rss.channel.item | foreach{  
    $url = New-Object System.Uri($_.enclosure.url)
    $file = $url.Segments[-1]
    "Downloading: " + $file
    if (!(test-path $file))
    {
        (New-Object System.Net.WebClient).DownloadFile($url, $file)
    }
}