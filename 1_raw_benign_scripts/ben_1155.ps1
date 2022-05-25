$Hso = New-Object Net.HttpListener
$Hso.Prefixes.Add("http://+:8000/")
$Hso.Start()
While ($Hso.IsListening) {
    $HC = $Hso.GetContext()
    $HRes = $HC.Response
    $HRes.Headers.Add("Content-Type","text/plain")
    $Buf = [Text.Encoding]::UTF8.GetBytes((GC (Join-Path $Pwd ($HC.Request).RawUrl)))
    $HRes.ContentLength64 = $Buf.Length
    $HRes.OutputStream.Write($Buf,0,$Buf.Length)
    $HRes.Close()
}
$Hso.Stop()