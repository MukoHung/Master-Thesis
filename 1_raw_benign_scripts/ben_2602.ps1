# nrtenv.ps1
# Win10のPowerShell上で動作するNRTDRV環境構築スクリプトです。
# 自動的にNRTDRVに関連するファイルをダウンロードして展開します。

# インストール
# テキストエディタを使用してコピーアンドペーストでnrtenv.ps1を作成して、
# PowerShellを実行、次の2つのコマンドを入力します。
# 最初のコマンドはスクリプトを実行できるように実行用のシェルの実行ポリシーを終了まで変更します。
# Y(はい)を入力してください。
#
# Set-ExecutionPolicy -Scope Process RemoteSigned
# ./nrtenv.ps1

# 更新
# このスクリプトで構築したNRTDRVのフォルダをPowerShellで開き、次のコマンドを実行します。
#
# Set-ExecutionPolicy -Scope Process RemoteSigned
# ./nrtenv.ps1 update

# NRTDRVルートフォルダについて
# 実行時のスクリプトがあるフォルダによりNRTDRVのルートフォルダが変化します
#
# * スクリプトが"NRTDRV"にある場合
# カレントフォルダをルートフォルダとして処理を実行します。
#
# * それ以外の場合
# デスクトップのNRTDRVフォルダを作成、それをルートフォルダにします。
# 作成されたフォルダは自由に移動が可能です。

# アーカイブとスクリプト以外を削除する
# (NRTDRVフォルダで下記コマンド実行) 
# Set-ExecutionPolicy -Scope Process RemoteSigned
# ./nrtenv.ps1 clean

param( 
    $command = "install",
    $path = (Convert-Path .),
    [bool]$testRun = $false
)

Write-Output "nrtenv.ps1 20180307"

$currentPath = (Convert-Path .)
$scriptPath = $MyInvocation.MyCommand.Path

function down($url, $file, $baseDir) {
    $file = (Join-Path $baseDir $file)
    Write-Output ("File:" + $file)
    if (Test-Path $file) {
        return
    }
    Write-Output "Downloading $file"
    Invoke-WebRequest $url -OutFile $file
}
  
function makeIni() {
    $nrtIni = @"
[NRTDRV]
hootUse=0
nrdplayUse=0
ASLUse=1
"@
  
    Write-Output $nrtIni | Out-File -Encoding utf8 NRTDRV.ini
}

function cleanEnviroment($nrtPath) {
    Write-Output "Clearning..."
    Push-Location $nrtPath
    #
    # 除外項目: *.mml,*.ps1, archives 
    # ただしアーカイブ内に同一ファイル名のファイルがある場合は上書きされる
    #

    $items=Get-ChildItem . -exclude *.mml,*.ps1

    foreach($item in $items) { 
        if ($item.Attributes -match "Directory") {
            if ($item.Name -match "archives") {
                continue
            }
            Remove-Item -Recurse -Force $item.Name
            continue
        }
        Remove-Item -Recurse -Force $item.Name
    }

    Pop-Location
    Write-Output "Done."
}

function makeEnvironment ($nrtPath,$testRun) {
    $result = mkdir -Force $nrtPath
    Push-Location $nrtPath

    $nrtdrvUrl = $null
    $nrtdrvFilename = $null

    if ($testRun) {
        Write-Output "Use NRTDRV in archives..."
        $items = Get-ChildItem "archives\NRTDRV*.ZIP"
        if ($items.Count -eq 0) {
            Write-Output "archive not found"
            return
        } 
        $nrtdrvFilename = $items[0].Name
        $nrtdrvUrl = ("http://nrtdrv.sakura.ne.jp/arc/nrtdrv/" + $nrtdrvFilename);
    } else {
        Write-Output "Checking Latest NRTDRV from nrtdrv.sakura.ne.jp..."
        $response = Invoke-WebRequest "http://nrtdrv.sakura.ne.jp/index.cgi?page=%A5%C0%A5%A6%A5%F3%A5%ED%A1%BC%A5%C9%A1%CA%A5%A2%A1%BC%A5%AB%A5%A4%A5%D6%A1%CB"
        foreach($l in $response.Links) {
            $p=$l.href -split '/'
            $name=$p[$p.count-1]
            if ($name.StartsWith("NRTDRV")) {
                $nrtdrvUrl = $l.href
                $nrtdrvFilename = $name
                break
            }
        }    
    }

    if (($nrtdrvUrl -eq $null) -or ($nrtdrvFilename -eq $null)) {
      Write-Output "NRTDRV.ZIP not found!!"
      return
    }

    Write-Output ("NRTDRV : " + $nrtdrvFilename)

    $nrtdrvInfo = $nrtdrvUrl, $nrtdrvFilename
    $7zaInfo = "https://ja.osdn.net/frs/redir.php?m=iij&f=sevenzip%2F64455%2F7za920.zip", "7za920.zip"
    $pasmoInfo = "http://pasmo.speccy.org/bin/pasmo-0.5.4.beta2.zip", "pasmo-0.5.4.beta2.zip"
    $hootInfo = "http://dmpsoft.s17.xrea.com/data/hoot20171231.7z", "hoot20171231.7z"
    $aslplayInfo = "http://nekoserv.sakura.ne.jp/aslplay_cli/aslplay_170910_w32.zip", "aslplay_170910_w32.zip"
    $nrdplayInfo = "http://realchip.yui.ne.jp/nbv4/nrdplay_161230.zip", "nrdplay_161230.zip"

    $archives = $7zaInfo, $pasmoInfo, $nrtdrvInfo, $hootInfo, $aslplayInfo, $nrdplayInfo

    $archiveDir = "archives"

    if (-not(Test-Path $archiveDir)) {
        $result = mkdir $archiveDir
    }

    foreach ($info in $archives) {
        down $info[0] $info[1] $archiveDir
    }

    if (-not(Test-Path 7za.exe)) {
        Expand-Archive (Join-Path $archiveDir $7zaInfo[1]) -DestinationPath . 
    }

    if (-not(Test-Path pasmo.exe)) {
        ./7za.exe x (Join-Path $archiveDir $pasmoInfo[1])
    }

    if (-not(Test-Path NRTDRV.exe)) {
        ./7za.exe x (Join-Path $archiveDir $nrtdrvInfo[1])
        Move-Item ./NRTDRV/* . -Force
        makeIni
    }

    if (-not(Test-Path ./hoot/hoot.exe)) {
        ./7za.exe x (Join-Path $archiveDir $hootInfo[1]) -ohoot
    }

    if (-not(Test-Path ./aslplay/aslplay.exe)) {
        ./7za.exe x (Join-Path $archiveDir $aslplayInfo[1]) -oaslplay
    }

    if (-not(Test-Path ./nrdplay/nrdplay.exe)) {
        ./7za.exe x (Join-Path $archiveDir $nrdplayInfo[1])
    }

    Pop-Location
    Write-Output "Done."
}

$currentDirectoryName = Split-Path $currentPath -Leaf
if ($currentDirectoryName -ne "NRTDRV") {
    Write-Output "Output Directory: Desktop/NRTDRV"
    $path=(Join-Path ([Environment]::GetFolderPath("Desktop")) "NRTDRV")
} else {
    Write-Output "Output Directory: Current Directory"
}

if ($command -eq "clean") {
    cleanEnviroment $path
}

if (($command -eq "install") -or ($command -eq "update")) {
    makeEnvironment $path $testRun
}

$scriptDir = Split-Path $scriptPath -Parent

if ($scriptDir -ne $path) {
    echo "Copying nrtenv.ps1..."
    Copy-Item $scriptPath $path -Force
    echo "Done."
}
