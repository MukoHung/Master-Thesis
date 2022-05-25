<#
.SYNOPSIS
tcpクライアントとサーバを実行します。

.DESCRIPTION

.PARAMETER addr

接続先のIPアドレス

.PARAMETER port

接続先のport番号

.PARAMETER server

サーバとして起動するかどうか。
常に受信待ち状態になります。

.PARAMETER loop

サーバとして起動した場合に、コネクションが切れたら再接続するかどうか。

.INPUTS
None. This script does not correspond.

.OUTPUTS
System.Int32
If success, this script returns 0, otherwise -1.

.EXAMPLE
.\nc.ps1

localhost:2222でクライアントとして接続します。

.EXAMPLE
.\nc.ps1 -s

localhost:2222でサーバとして待ち受け状態にします。
#>

[CmdletBinding(
  SupportsShouldProcess=$true,
  ConfirmImpact='Medium'
)]
Param(
    [string]$addr = 'localhost',
    [alias("p")][int]$port = 2222,
    [alias("s")][switch]$server,
    [alias("l")][switch]$loop
)

$ErrorActionPreference = 'Stop'

function recieve($client) {
    $stream = $client.GetStream()
    $buffer = New-Object System.Byte[] $client.ReceiveBufferSize
    $enc = New-Object System.Text.AsciiEncoding

    try {
        $ar = $stream.BeginRead($buffer, 0, $buffer.length, $NULL, $NULL)
        while ($TRUE) {
            if ($ar.IsCompleted) {
                $bytes = $stream.EndRead($ar)
                if ($bytes -eq 0) {
                    break
                }
                $date = (Get-Date -Format yyyy/MM/dd-HH:mm:ss.ffff)
                Write-Host -n "recieve(${date}): $($enc.GetString($buffer, 0, $bytes))"
                $ar = $stream.BeginRead($buffer, 0, $buffer.length, $NULL, $NULL)
            }
            Start-Sleep -m 100
        }
    } catch [System.IO.IOException] {
        # ignore exception at $stream.BeginRead()
    } finally {
        $stream.Close()
    }
}

function send($client) {
    $stream = $client.GetStream()
    $enc = New-Object System.Text.AsciiEncoding

    try {
        while ($TRUE) {
            if ($Host.UI.RawUI.KeyAvailable) {
                $msg = (Read-Host "prompt")
                $data = $enc.GetBytes($msg + "`n")
                $stream.Write($data, 0, $data.length)
                Write-Host "send message($(Get-Date -Format yyyy/MM/dd-HH:mm:ss.ffff)): $msg"
            }
        }
    } catch [System.IO.IOException] {
        # ignore exception at $stream.BeginRead()
    } finally {
        $stream.Close()
    }
}

if ($server) {
    $ip = [System.Net.Dns]::GetHostEntry($addr)
    $endpoint = New-Object System.Net.IPEndPoint ($ip.AddressList[0], $port)
    do {
      $listener = New-Object System.Net.Sockets.TcpListener $endpoint
      $listener.Start()
      Write-Verbose "Listening on [${addr}] (family 0, port ${port})"

      $handle = $listener.BeginAcceptTcpClient($null, $null)
      while (!$handle.IsCompleted) { Start-Sleep -m 100 }
      $client = $listener.EndAcceptTcpClient($handle)
      $remote = $client.Client.RemoteEndPoint
      Write-Verbose "Connection from [$($remote.Address)] port ${port} [tcp/*] accepted (family 2, sport $($remote.Port))"

      recieve $client

      $client.Close()
      $listener.Stop()
    } while ($loop)
} else {
    $client = New-Object System.Net.Sockets.TcpClient ($addr, $port)
    Write-Verbose "Connection to ${addr} ${port} port [tcp/*] succeeded!"

    send $client

    $client.Close()
}

