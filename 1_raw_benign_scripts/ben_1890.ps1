Add-Type -AssemblyName System.Web

Write-Host "Paimon.moe Wish Importer" -ForegroundColor Cyan
Write-Host "1. Open Genshin Impact in this PC"
Write-Host "2. Then open the wish history and wait it to load"
Write-Host "3. When you are ready press [ENTER] to continue! (or any key to cancel)"
Write-Host "Waiting..."

$keyInput = [Console]::ReadKey($true).Key
if ($keyInput -ne "13") {
    Write-Host "Bye~"
    exit
}

$logLocation = "%userprofile%\AppData\LocalLow\miHoYo\Genshin Impact\output_log.txt";
$path = [System.Environment]::ExpandEnvironmentVariables($logLocation);
if (-Not [System.IO.File]::Exists($path)) {
    Write-Host "Cannot find the log file! Make sure to open the wish history first!" -ForegroundColor Red
    exit
}

$logs = Get-Content -Path $path
$match = $logs -match "^OnGetWebViewPageFinish.*log$"
if (-Not $match) {
    Write-Host "Cannot find the wish history url! Make sure to open the wish history first!" -ForegroundColor Red
    exit
}

[string] $wishHistoryUrl = $match -replace 'OnGetWebViewPageFinish:', ''
$uri = [System.UriBuilder]::New($wishHistoryUrl)
$uri.Path = "event/gacha_info/api/getGachaLog"
$uri.Host = "hk4e-api-os.mihoyo.com"
$uri.Fragment = ""

$banners = [ordered]@{
    100 = "Beginners' Wish";
    200 = "Standard";
    301 = "Character Event";
    302 = "Weapon Event";
}

$wishes = [System.Collections.ArrayList]@()

function fetch($url) {
    $ProgressPreference = 'SilentlyContinue'

    $retrycount = 0
    $completed = $false
    $response = $null

    while (-Not $completed) {
        try {
            $response = Invoke-WebRequest -Uri $url -ContentType "application/json" -UseBasicParsing -TimeoutSec 30
            $completed = $true
        }
        catch {
            if ($retrycount -ge 3) {
                throw
            }
            else {
                $retrycount++
            }
        }
    }

    return $response
}

function GetBannerLog($code, $type) {
    $total = 0
    $params = [System.Web.HttpUtility]::ParseQueryString($uri.Query)
    $params.Set("lang", "en");
    $params.Set("gacha_type", $code);
    $params.Set("size", "20");
    $params.Add("lang", "en-us");

    $page = 1
    $lastList = [System.Collections.ArrayList]@()
    $lastId = 0
    do {
        $params.Set("page", $page)
        $params.Set("end_id", $lastId);

        $uri.Query = $params.ToString()
        $apiUrl = $uri.Uri.AbsoluteUri

        Write-Host "`rProcessing $type Banner - Page $page - x$total"  -NoNewline
        
        try {
            $response = fetch $apiUrl

            $result = $response | ConvertFrom-Json
            if ($result.retcode -ne 0) {
                if ($result.message -eq "authkey timeout") {
                    Write-Host "Authkey expired, please re-open the Wish History page" -ForegroundColor Red
                    exit
                }
            
                Write-Host "Error code returned from MiHoYo API! Try again later" -ForegroundColor Red
                exit
            }
            
            $lastList = $result.data.list
            foreach ($wish in $result.data.list) {
                [void]$wishes.Add(@($wish.gacha_type, $wish.time, $wish.name, $wish.item_type, $wish.rank_type))
            }
            
            $total = $total + $result.data.list.Count;
            $page++;
            if ($result.data.list.Count -gt 0) {
                $lastId = $result.data.list[$result.data.list.Count - 1].id
            }
            else {
                $lastId = 0
            }
        }
        catch {
            Write-Host "Error when connecting to MiHoYo API! (Check your internet connection)" -ForegroundColor Red
            exit
        }

        Write-Host "`rProcessing $type Banner - Page $page - x$total"  -NoNewline

        Start-Sleep -Seconds 1
    } while ($lastList.Count -ne 0)
}

foreach ($banner in $banners.GetEnumerator()) {
    Write-Host ""
    GetBannerLog $banner.Name $banner.Value
}

$generated = "paimonmoe,importer,version,1,0`n"
foreach ($w in $wishes) {
    $str = $w -join ","
    $generated += "$str`n"
}

Write-Host ""
Write-Host "Press any key to copy the result, then paste it back to paimon.moe" -ForegroundColor Green
[void][Console]::ReadKey($true)
Set-Clipboard -Value $generated

$documentpath = [Environment]::GetFolderPath("MyDocuments")
$time = Get-Date -Format "yyyyMMddHHmm"
$generated | Out-File -FilePath "$documentpath\paimon-moe-import-$time.csv"
Write-Host "The file also saved on $documentpath\paimon-moe-import-$time.csv" -ForegroundColor Green
