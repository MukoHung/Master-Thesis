#!/usr/bin/env pwsh

# https://stackoverflow.com/questions/8761888/capturing-standard-out-and-error-with-start-process
function Start-Command ([String]$Path, [String]$Arguments) {
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $Path
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $Arguments
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    return @{
        stdout = $p.StandardOutput.ReadToEnd()
        stderr = $p.StandardError.ReadToEnd()
        ExitCode = $p.ExitCode
    }
}

# https://stackoverflow.com/questions/1783554/fast-and-simple-binary-concatenate-files-in-powershell
function Join-File ([String[]]$Path, [String]$Destination) {
    $OutFile = [IO.File]::Create($Destination)
    foreach ($File in $Path) {
        $InFile = [IO.File]::OpenRead($File)
        $InFile.CopyTo($OutFile)
        $InFile.Dispose()
    }
    $OutFile.Dispose()
}

function Get-RandomBytes ([Int32]$Length) {
    $RNG = [Security.Cryptography.RandomNumberGenerator]::Create()
    $Bytes = [Byte[]]::new($Length)
    $RNG.GetBytes($Bytes)
    return $Bytes
}

function Invoke-EncryptFile ([String]$Path, [Byte[]]$Key, [Byte[]]$IV, [String]$OutFile) {
    $File = [IO.File]::ReadAllBytes($Path)

    $AES = [Security.Cryptography.Aes]::Create()
    $AES.Key = $Key
    $AES.IV = $IV
    $Encryptor = $AES.CreateEncryptor($AES.Key, $AES.IV)
    $Encrypted = $Encryptor.TransformFinalBlock($File, 0, $File.Length)

    [IO.File]::WriteAllBytes($OutFile, $Encrypted)
}

# $FFmpegExec = 'D:\ffmpeg\bin\ffmpeg.exe'
# $CurlExec = 'D:\curl-7.68.0-win64-mingw\bin\curl.exe'
$FFmpegExec = 'ffmpeg'
$CurlExec = 'curl'
if (Test-Path alias:\curl) {
    Remove-Item alias:\curl
}

$Video = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath((Read-Host 'Input H264+AAC video path').Replace('"', ''))

$TempDirectory = [IO.Path]::GetDirectoryName($Video) + '/' + [GUID]::NewGuid().ToString('N')
New-Item $TempDirectory -ItemType Directory

&$FFmpegExec -i $Video -c copy -vbsf h264_mp4toannexb -absf aac_adtstoasc ($TempDirectory + '/video.ts')
&$FFmpegExec -i ($TempDirectory + '/video.ts') -c copy -f segment -segment_list ($TempDirectory + '/video.m3u8') ($TempDirectory + '/%d.ts')
Remove-Item ($TempDirectory + '/video.ts')

$tsCount = (Get-ChildItem $TempDirectory -Filter *.ts).Length
do {
    $LimitExceed = $false
    foreach ($ts in (Get-ChildItem $TempDirectory -Filter *.ts)) {
        if ($ts.Length -gt 5MB) {
            $LimitExceed = $true
            Write-Host '[ERROR]' -NoNewline -BackgroundColor DarkRed -ForegroundColor White
            Write-Host (' File size limit exceeded: {0} ({1} MB)' -f $ts.Name, [Math]::Round($ts.Length / 1MB, 2))
        }
    }
    if ($LimitExceed) {
        Read-Host 'Compress the files and press enter to continue'
    }
} while ($LimitExceed)

Write-Host 'Parsing M3U8...'
$m3u8Source = [IO.File]::ReadAllLines($TempDirectory + '/video.m3u8')
$m3u8 = @{
    'meta' = @();
    'info' = @();
}
for ($i = 0; $i -lt $m3u8Source.Count; $i++) {
    if (($m3u8Source[$i] -eq '#EXTM3U') -or ($m3u8Source[$i] -eq '#EXT-X-ENDLIST')) {
        continue
    }

    if ($m3u8Source[$i].StartsWith('#EXTINF:')) {
        $m3u8.info += @{
            'duration' = [Double]($m3u8Source[$i].Replace('#EXTINF:', '').Replace(',', ''));
            'file' = $m3u8Source[++$i];
        }
    } else {
        $m3u8.meta += $m3u8Source[$i]
    }
}

Write-Host 'Merging TS files...'
$FastStart = 3
for ($i = 0; $i -lt $tsCount; $i++) {
    $LastPath = ('{0}/{1}.ts' -f $TempDirectory, ($i - 1))
    $CurrentPath = ('{0}/{1}.ts' -f $TempDirectory, $i)

    if (-not [IO.File]::Exists($LastPath)) {
        continue
    }

    if ((Get-Item $LastPath).Length + (Get-Item $CurrentPath).Length -le @(2MB, 1MB)[[Bool]$FastStart]) {
        Write-Host '[MERGE]' -NoNewline -BackgroundColor DarkGreen -ForegroundColor White
        Write-Host (' {0}.ts <- {1}.ts' -f $i, ($i - 1))
        Join-File -Path $LastPath, $CurrentPath -Destination ('{0}/~.ts' -f $TempDirectory)

        Remove-Item $LastPath
        Remove-Item $CurrentPath
        Rename-Item ('{0}/~.ts' -f $TempDirectory) ('{0}.ts' -f $i)
    } else {
        Write-Host '[SKIP]' -NoNewline -BackgroundColor DarkCyan -ForegroundColor White
        if ($FastStart -gt 0) {
            $FastStart--
            Write-Host (' {0}.ts ({1} MB FastStart)' -f $i, [Math]::Round((Get-Item $LastPath).Length / 1MB, 2))
        } else {
            Write-Host (' {0}.ts ({1} MB)' -f $i, [Math]::Round((Get-Item $LastPath).Length / 1MB, 2))
        }
    }
}

Write-Host 'Writing M3U8...'
$MergedInfo = @()
$tsLast = 0
for ($i = 0; $i -lt $tsCount; $i++) {
    if (-not [IO.File]::Exists(('{0}/{1}.ts' -f $TempDirectory, $i))) {
        continue
    }
    $MergedDuration = 0
    for ($j = $tsLast; $j -le $i; $j++) {
        $MergedDuration += $m3u8.info[$j].duration
    }
    $MergedInfo += @{
        'duration' = $MergedDuration;
        'file' = $m3u8.info[$i].file
    }
    $tsLast = $i + 1
}
$m3u8.info = $MergedInfo

$m3u8Content = @('#EXTM3U')
foreach ($meta in $m3u8.meta) {
    $m3u8Content += $meta
}
foreach ($info in $m3u8.info) {
    $m3u8Content += '#EXTINF:' + $info.duration + ','
    $m3u8Content += $info.file
}
$m3u8Content += '#EXT-X-ENDLIST'
[IO.File]::WriteAllLines($TempDirectory + '/video.m3u8', $m3u8Content)
Read-Host 'Press enter to start uploading'

$EncryptKey = Get-RandomBytes 16
$EncryptIV = Get-RandomBytes 16

Write-Host ('Key: ' + ($EncryptKey | ForEach-Object { '{0:X2}' -f $_ }))
Write-Host ('IV: ' + ($EncryptIV | ForEach-Object { '{0:X2}' -f $_ }))
Write-Host 'Uploading Key File...'
[IO.File]::WriteAllBytes($TempDirectory + '/KEY', $EncryptKey)
$Response = (Start-Command $CurlExec (@(
    'https://kfupload.alibaba.com/mupload',
    '-H "User-Agent: iAliexpress/8.27.0 (iPhone; iOS 12.1.2; Scale/2.00)"',
    '-X POST',
    '-F scene=productImageRule',
    '-F name=image.jpg',
    '-F file=@{0}' -f ($TempDirectory + '/KEY')
) -join ' ')).stdout | ConvertFrom-Json
$EncryptKeyURL = $Response.url
Remove-Item ($TempDirectory + '/KEY')
$m3u8.meta += ('#EXT-X-KEY:METHOD=AES-128,URI="{0}",IV=0x{1}' -f $EncryptKeyURL,(($EncryptIV | ForEach-Object { '{0:x2}' -f $_ }) -join ''))

$URLMapping = @{}
foreach ($ts in (Get-ChildItem $TempDirectory -Filter *.ts)) {
    $FileName = [IO.Path]::GetFileName($ts.FullName)

    $FileEncrypted = $ts.FullName + '.encrypt'
    Invoke-EncryptFile $ts.FullName $EncryptKey $EncryptIV $FileEncrypted

    $Response = (Start-Command $CurlExec (@(
        'https://kfupload.alibaba.com/mupload',
        '-H "User-Agent: iAliexpress/8.27.0 (iPhone; iOS 12.1.2; Scale/2.00)"',
        '-X POST',
        '-F scene=productImageRule',
        '-F name=image.jpg',
        '-F file=@{0}' -f $FileEncrypted
    ) -join ' ')).stdout | ConvertFrom-Json
    Remove-Item $FileEncrypted

    if ([Bool][Int32]$Response.code) {
        Write-Host '[WARNING]' -NoNewline -BackgroundColor DarkYellow -ForegroundColor White
        Write-Host (' {0} Failed to upload' -f $FileName)
        $URL = $FileName
    } else {
        Write-Host '[UPLOAD]' -NoNewline -BackgroundColor DarkGreen -ForegroundColor White
        Write-Host (' {0} {1}' -f $FileName, $Response.url)
        $URL = $Response.url
    }

    $URLMapping.$FileName = $URL
}

Write-Host 'Writing M3U8 with URL...'
$m3u8Content = @('#EXTM3U')
foreach ($meta in $m3u8.meta) {
    $m3u8Content += $meta
}
foreach ($info in $m3u8.info) {
    $m3u8Content += '#EXTINF:' + $info.duration + ','
    $m3u8Content += $URLMapping.($info.file)
}
$m3u8Content += '#EXT-X-ENDLIST'
[IO.File]::WriteAllLines($TempDirectory + '/video_online.m3u8', $m3u8Content)

Write-Host 'Complete!'