$chars = @("1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")

foreach($i in $chars){

$code = "49AYTQ55V{0}" -f $i

$Payload = @{
    session = "SESSIONID"
    code = $code
}

Write-Host ($Payload|ConvertTo-Json)


$headers = @{
    'Origin' = 'https://beta.teamspeak.com'
    'Referer' = 'https://beta.teamspeak.com/'
    'Sec-Fetch-Mode' = 'cors'
    'content-type' = 'application/json'
}

$response = Invoke-RestMethod -Uri "https://api.teamspeak.com/user/redeem-badge" -Method Post -Body ($Payload|ConvertTo-Json) -ContentType "application/json" -Headers $headers -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36"
}