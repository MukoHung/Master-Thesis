[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Invoke = Invoke-WebRequest -Headers @{"API-Key" = "$apikey"} -Method Post ` -Body "{`"url`":`"$url`"}" -Uri https://urlscan.io/api/v1/scan/ ` -ContentType application/json
