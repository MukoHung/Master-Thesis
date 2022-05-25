$token = "TOKEN"
$account = "ACCOUNT_ID"
$zone = "DOMAIN_NAME"
$record = "RECORD_ID"
$ip = Invoke-WebRequest -URI http://icanhazip.com | Select-Object -Expand Content

$url = "https://api.dnsimple.com/v2/" + $account + "/zones/" + $zone + "/records/" + $record;

$headers = @{ 
    "Authorization" = "Bearer " + $token;
    "Content-Type" = "application/json";
    "Accept" = "application/json"
    }

$content = @{ "content" = $IP };
$body = $content | convertto-json

Invoke-WebRequest -URI $url -Headers $headers -Method Patch -Body $body;