# Use the following commands to bind/unbind SSL cert
# netsh http add sslcert ipport=0.0.0.0:443 certhash=3badca4f8d38a85269085aba598f0a8a51f057ae "appid={00112233-4455-6677-8899-AABBCCDDEEFF}"
# netsh http delete sslcert ipport=0.0.0.0:443 
$HttpListener = New-Object System.Net.HttpListener
$HttpListener.Prefixes.Add("http://+:80/")
$HttpListener.Prefixes.Add("https://+:443/")
$HttpListener.Start()
While ($HttpListener.IsListening) {
    $HttpContext = $HttpListener.GetContext()
    $HttpRequest = $HttpContext.Request
    $RequestUrl = $HttpRequest.Url.OriginalString
    Write-Output "$RequestUrl"
    if($HttpRequest.HasEntityBody) {
      $Reader = New-Object System.IO.StreamReader($HttpRequest.InputStream)
      Write-Output $Reader.ReadToEnd()
    }
    $HttpResponse = $HttpContext.Response
    $HttpResponse.Headers.Add("Content-Type","text/plain")
    $HttpResponse.StatusCode = 200
    $ResponseBuffer = [System.Text.Encoding]::UTF8.GetBytes("")
    $HttpResponse.ContentLength64 = $ResponseBuffer.Length
    $HttpResponse.OutputStream.Write($ResponseBuffer,0,$ResponseBuffer.Length)
    $HttpResponse.Close()
    Write-Output "" # Newline
}
$HttpListener.Stop()