#simple and dirty proxy
#usage: http://127.0.0.1:8000/?url=http://www.obscuresec.com
$Up = "http://+:8000/"
$Hso = New-Object Net.HttpListener
$Wco = New-Object Net.Webclient

#ignore self-signed/invalid ssl certs
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$True}

Foreach ($P in $Up) {$Hso.Prefixes.Add($P)} 
    $Hso.Start()
    While ($Hso.IsListening) {
        $HC = $Hso.GetContext()
        $HReq = $HC.Request
        $HRes = $HC.Response
        $HRes.Headers.Add("Content-Type","text/html")      
        $ProxURL = $HReq.QueryString['URL']
        If ($ProxURL) {$Content = $Wco.downloadString("$ProxURL")}       
        $Buf = [Text.Encoding]::UTF8.GetBytes($Content)
        $HRes.ContentLength64 = $Buf.Length
        $HRes.OutputStream.Write($Buf,0,$Buf.Length)
        $HRes.Close()
    }
    $Hso.Stop()