param (
    [switch]$nonpremium,
    [switch]$ngrok,
    [int]$RAM = 4
)

$error.clear()

$MEM = $RAM.toString() + 'G'

function Send-WebhookMessage {

    param (
        $title,
        $description,
        $color
    )
    $time = get-date -UFormat "%Y-%m-%dT%T"
    $authorObject = [PSCustomObject]@{
        name     = 'Server'
        url      = 'https://github.com/kamack38'
        icon_url = 'https://upload.wikimedia.org/wikipedia/commons/0/01/Windows_Terminal_Logo_256x256.png'
    }

    $footerObject = [PSCustomObject]@{
        text     = 'By kamack38'
        icon_url = 'https://i.imgur.com/rbxQ6dD.png'
    }

    $imageObject = [PSCustomObject]@{
        url = 'https://store-images.s-microsoft.com/image/apps.608.13510798887677013.5c7792f0-b887-4250-8c4e-4617af9c4509.bcd1385a-ad15-450c-9ddd-3ee80c37121a?mode=scale&q=90&h=1080&w=1920'
    }

    $embedObject = [PSCustomObject]@{
        title       = $title
        description = $description
        color       = $color
        author      = $authorObject

        footer      = $footerObject

        timestamp   = $time
        image       = $imageObject
    }

    [System.Collections.ArrayList]$embedArray = @()
    $embedArray.Add($embedObject)

    $payload = [PSCustomObject]@{
        embeds     = $embedArray
        username   = 'iPlay Poland'
        avatar_url = 'https://i.imgur.com/MNLox2O.png'
    }
    Write-Host "Sending webhook message..." -Foreground Yellow
    Invoke-RestMethod -Uri $Env:hook_url -Method Post -Body ($payload | ConvertTo-Json -Depth 4) -ContentType 'application/json; charset=utf-16' > $null
    if ($?) { Write-Host "Message Sent" -Foreground Green }
}

if ($ngrok) {
    if (!(Test-Connection "http://localhost:4040/api/tunnels" -Quiet)) {
        Write-Host "Ngrok server NOT running. Starting server..." -ForegroundColor Yellow
        Start-Job -Name 'Ngrok Minecraft Server' -Scriptblock { ngrok tcp 25565 -region eu -log=stdout } > $null
    }
    $response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -Method 'Get'
    $ip = $response.tunnels.public_url
    $ip = $ip.substring(6)

    if (Test-Path $PSScriptRoot/update_vars.ps1) {
        . $PSScriptRoot/update_vars.ps1 
        $webhook = 1
        Send-WebhookMessage 'Serwer został włączony 🟢' "Serwer został włączony. **Połącz** się z nim już teraz: ``$ip``" '1092143' 
    }
    else {
        $webhook = 0
        Write-Host "Vars file not found! Skipping.." -Foreground Yellow 
    }

    if ($error) {
        Write-Host "Server has not beeen started" -ForegroundColor Red
        Write-Output $error
    }
    else {
        Write-Host "Server has been started succesfully" -ForegroundColor Green
    }
}

if ($nonpremium) {
    if (!(Get-ChildItem .\plugins -Filter *AuthMe*.jar)) {
        Write-Host "AutheMe plugin isn't present. Check your plugins folder." -ForegroundColor Red
    }
    else {
        Write-Host "Running non-premium Minecraft server with $RAM GB of RAM..." -ForegroundColor Yellow
        java ('-Xmx' + $MEM) ('-Xms' + $MEM) --add-modules=jdk.incubator.vector -jar purpur.jar --nogui --online-mode 0
    }
}
else {
    Write-Host "Running premium Minecraft server with $RAM GB of RAM..." -ForegroundColor Yellow
    java ('-Xmx' + $MEM) ('-Xms' + $MEM) --add-modules=jdk.incubator.vector -jar purpur.jar --nogui
}

if ($webhook) {
    Send-WebhookMessage 'Serwer wyłączony 🔴' "Serwer o IP: ``$ip`` został wyłączony. Zapraszamy ponownie później :)" '15413831'
}

if ($ngrok) {
    Stop-Job -Name 'Ngrok Minecraft Server'
    Write-Host "Shuting down Ngrok server" -ForegroundColor Yellow
}

if (!$error.count) {
    Write-Host ("Script has run with no errors") -ForegroundColor Green
}
else {
    Write-Host ("Script has run with " + $error.count + " errors") -ForegroundColor Red
    Write-Output $error
}