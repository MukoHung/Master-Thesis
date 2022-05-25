class Token {
    [string] $token
    [System.DateTimeOffset] $expires
    Token($response) {
        $this.token = $response.token;
        $this.expires = [System.DateTimeOffset]::FromUnixTimeMilliseconds($response.expires)
    }
}

$rootUri = "https://www.arcgis.com/sharing/rest"
$params = @{
    username = "me";
    password = "mypassword";
    expiration = '60'
    referer = 'https://wsdot.maps.arcgis.com'
    f = 'json'
}

$tokenUri = "$rootUri/generateToken"
$response = Invoke-RestMethod -Uri $tokenUri -Method Post -Body $params
$token = New-Object Token $response
return $token