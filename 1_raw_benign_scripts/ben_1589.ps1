Param(
    [Parameter(mandatory=$true, position=0)]
    [string]$Target,
    [Parameter(mandatory=$false, position=1)]
    [string]$Folder = "/",
    [Parameter(mandatory=$false, position=2)]
    [ValidateRange(1, 65535)]
    [int]$Port = 80,
    [Parameter(mandatory=$false)]
    [ValidateSet("GET","HEAD","OPTIONS","PROPFIND", "TRACE", "CONNECT")]
    [string]$Verb = "HEAD",
    [Parameter(mandatory=$false)]
    [ValidateSet("0.9", "1.0", "1.1")]
    [string]$Version = "1.1"
)

$ua = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1"
$text = "$Verb $Folder HTTP/$Version`r`n" +
    "User-Agent:$ua`r`n" +
    "Host:$Target`:$Port`r`n" +
    "Connection:Closed`r`n`r`n"

$tcp = New-Object System.Net.Sockets.TcpClient($Target, $Port)
$tcp.SendTimeout = 2000
$tcp.ReceiveTimeout = 2000
if($tcp.Connected) {
    try{
        $stream = $tcp.GetStream()
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.Write($text)
        $writer.Flush()
        $bytes = New-Object byte[] 1024 
        $len = $stream.Read($bytes, 0, $bytes.Length)
        while($len -gt 0) {
            Write-Output ([System.text.encoding]::UTF8.GetString($bytes, 0, $len))
            if($stream.DataAvailable){
                $len = $stream.Read($bytes, 0, $bytes.Length)
            } else {
                $len = 0
            }
        }
        $writer.Close()
        $stream.Close()
    } catch {
        Write-Warning "Unable to connect to $Target : $Port"
    } finally {
        $tcp.Close()
    }
}