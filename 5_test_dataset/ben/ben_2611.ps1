$http = new-object System.Net.WebClient
$feed = [xml]$http.DownloadString("https://nuget.org/api/v2/Packages")
$feed.feed.entry | % { 
    $http.DownloadFile($_.content.src, ("C:\temp\"+ $_.title.InnerText + "." + $_.Properties.Version  +".nupkg")) 
}
