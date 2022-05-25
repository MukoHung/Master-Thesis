$socket = new-object System.Net.Sockets.TcpListener('0.0.0.0', 1080);
if($socket -eq $null){
	exit 1;
}
$socket.start();
$client = $socket.AcceptTcpClient();
$stream = $client.GetStream();
$buffer = new-object System.Byte[] 2048;
$file = 'c:/afile.exe';
$fileStream = New-Object System.IO.FileStream($file, [System.IO.FileMode]'Create', [System.IO.FileAccess]'Write');

do
{
	$read = $null;
	while($stream.DataAvailable -or $read -eq $null) {
			$read = $stream.Read($buffer, 0, 2048);
			if ($read -gt 0) {
				$fileStream.Write($buffer, 0, $read);
			}
		}
} While ($read -gt 0);

$fileStream.Close();
$socket.Stop();
$client.close();
$stream.Dispose();
