$image = "rabbitmq"
$containerName = "rabbit-mq"
$memoryHighWatermark = "512M"

$defaultUserName = "master"
$defaultPassword = "ofDesaster"

$attempts = 0
$maxAttempts = 3
$startSuccess = $false

do {
    docker ps -a -f name=$containerName -q | ForEach-Object {
        "Stopping $containerName container"
        docker stop $_ | Out-Null
        docker rm $_ | Out-Null
    }

    $imageTag = "$($image):3-management"
    docker run -d --hostname local-rabbit --name $containerName -p 5672:5672 -p 15672:15672 $imageTag

    if ($?) {
        $startSuccess = $true
        break;
    }

    $attempts = $attempts + 1

    "Waiting on $image docker run success, attempts: $attempts of $maxAttempts"
    Start-Sleep 1
} while ($attempts -lt $maxAttempts)

if (!$startSuccess) {
    throw "Failed to start $image container."
}

$webMgtUrl = "http://localhost:15672"

"Checking $image status. Test url: $webMgtUrl"
$attempts = 0
$maxAttempts = 10

do {
    Start-Sleep ($attempts + 3)
    $conns5672 = Get-NetTCPConnection -LocalPort 5672 -State Listen -ErrorVariable $err -ErrorAction SilentlyContinue
    $conns15672 = Get-NetTCPConnection -LocalPort 15672 -State Listen -ErrorVariable $err -ErrorAction SilentlyContinue

    $status = -1

    try {
        $status = Invoke-WebRequest $webMgtUrl | ForEach-Object {$_.StatusCode}
    }
    catch {
        Write-Warning "$($_.Exception.Message)"
    }

    if ($conns5672 -and $conns5672.Length -gt 0 -and $conns15672 -and $conns15672.Length -gt 0 -and $status -eq 200) {
        "$image started. Launching $webMgtUrl"
        # login as guest/guest
        Start-Process $webMgtUrl -WindowStyle Minimized
        break;
    }

    $attempts = $attempts + 1
    "$image not fully started. Attempts: $attempts of $maxAttempts. Waiting..."
} while ($attempts -lt $maxAttempts)

docker exec $containerName rabbitmqctl set_vm_memory_high_watermark absolute $memoryHighWatermark
docker exec $containerName rabbitmqctl add_user $defaultUserName $defaultPassword
docker exec $containerName rabbitmqctl set_permissions -p / $defaultUserName ".*" ".*" ".*"
"user $defaultUserName created"