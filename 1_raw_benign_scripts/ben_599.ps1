# See https://github.com/ebekker/ACMESharp/wiki/Quick-Start for background
# Could be enhanced by putting YOUR_CF_API_KEY and YOUR_EMAIL in environment vars
# Usage:
# > cf-update-dns-txt.ps1 -Domain example.com -Value vNx_fpLgvq0l4rqSATuxhxl9pa155SoeKvNZ98AFB_4

param( [string]$domain, [string]$value )
$headers = @{
    "X-Auth-Key" = "YOUR_CF_API_KEY"
    "X-Auth-Email" = "YOUR_EMAIL"
    "Content-Type" = "application/json"
}

# Get CloudFlare's zone identifer for the given domain
Write-Host "`nTrying to get zone identifier for $domain"
Try
{
    $url = "https://api.cloudflare.com/client/v4/zones?name=$domain"
    $response = (Invoke-RestMethod -Method Get $url -Headers $headers)
    $zoneId = $response.result.id
    Write-Host "Success! Identifier for $domain is $zoneId`n`n"
}
Catch
{
    Write-Host "Cannot get zone identifier; exiting..."
    Break
}

# Get identifier for the _acme-challenge TXT entry
Write-Host "Trying to get the _acme_challenge TXT entry id"
Try
{
    $url = "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records?name=_acme-challenge.$domain"
    $response = (Invoke-RestMethod -Method Get $url -Headers $headers)
    $txtId = $response.result.id
    Write-Host "Success! _acme-challenge id is $txtId`n`n"
}
Catch
{
    Write-Host "Cannot get _acme-challenge TXT entry; exiting..."
    Break
}

# Remove the existing TXT entry
Write-Host "Trying to delete _acme-challenge TXT entry"
Try
{
    $url = "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$txtId"
    $response = Invoke-RestMethod -Method Delete $url -Headers $headers
    Write-Host "Success! _acme-challenge TXT entry deleted from $domain`n`n"
}
Catch
{
    Write-Host "Cannot delete _acme-challenge DNS TXT entry; it's probably already deleted"
}

# Add or update the provided RR Value to CloudFlare
Write-Host "Trying to add _acme-challenge TXT $value to $domain"
Try
{
    $url = "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records"
    $body = @{
      "type" = "TXT"
      "name" = "_acme-challenge"
      "content" = $value
    } | ConvertTo-Json -Compress

    $r = Invoke-WebRequest -Method Post $url -Headers $headers -Body $body
    Write-Host "Success! Added $value to _acme-challenge on $domain"
}
Catch
{
    Write-Host "Adding the _acme-challenge TXT entry failed; exiting..."
    Break
}
