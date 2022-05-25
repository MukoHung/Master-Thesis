$req_url    = "https://www.cloudxns.net/api2/ddns"
$api_key    = "YOUR_API_KEY_HERE"
$secret_key = "YOUR_SECRET_KEY_HERE"
$host_name  = "your.hostname.here"
$ifMac      = "YOUR-INTERFACE-MAC-ADDRESS-HERE"

Write-Host -NoNewline "Getting Interface IP Adresss..."
$ifAdapter = Get-NetAdapter | Where-Object -Property MacAddress -EQ $ifMac
$ifIPAddress = Get-NetIPAddress -ifIndex $ifAdapter.ifIndex -SuffixOrigin Dhcp -AddressFamily IPv4 
$name = $ifAdapter.Name
$local = $ifIPAddress.IPAddress

if ($local -eq $null) {
    Write-Host "Interface not ready."
    exit
}
Write-Host "$local($name)"


Write-Host -NoNewline "Getting Local DNS Record......."
$dnsQuery = Resolve-DnsName $host_name | Where-Object -Property Section -EQ Answer
$dnsRecord = $dnsQuery.IPAddress

if ($local -eq $dnsRecord)
{
    Write-Host "Not Changed."
    exit
}
Write-Host $dnsRecord


Write-Host -NoNewline "Getting Remote DNS Record......"
$dnsNSQuery = Resolve-DnsName zhaowy.net -Type NS | Where-Object -Property section -EQ answer
$dnsQuery = Resolve-DnsName $host_name -Server $dnsNSQuery[0].IPAddress -Type A | Where-Object -Property Section -EQ Answer
$dnsRecord = $dnsQuery.IPAddress

if ($local -eq $dnsRecord)
{
    Write-Host "Not Changed"
    exit
}
Write-Host $dnsRecord


$req_body = ConvertTo-Json @{
    "domain" = $host_name
    "ip" = $local
}

$req_time = (Get-Date).ToString()

$beforeHash = $api_key + $req_url + $req_body + $req_time + $secret_key
$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8 = new-object -TypeName System.Text.UTF8Encoding
$api_hmac = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($beforeHash)))
$api_hmac = $api_hmac.ToLower() -replace  "-", ""

$http_header = @{
    'API-KEY'          = $api_key
    'API-REQUEST-DATE' = $req_time
    'API-HMAC'         = $api_hmac
    'API-FORMAT'       = 'json'
}

Write-Host -NoNewline "Updating Remote DNS Record....."
$result = Invoke-RestMethod -Method Post -Uri $req_url -Body $req_body -Headers $http_header
Write-Host $result.message