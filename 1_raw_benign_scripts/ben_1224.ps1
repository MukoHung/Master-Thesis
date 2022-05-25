$url    = "https://github.com/sabnzbd/sabnzbd/releases/download/1.2.0/SABnzbd-1.2.0-win32-setup.exe"
$dest   = ([Environment]::GetFolderPath("Desktop") + "\SABnzbd-1.2.0-win32-setup.exe")
$client = new-object System.Net.WebClient
$client.DownloadFile($url,$dest)