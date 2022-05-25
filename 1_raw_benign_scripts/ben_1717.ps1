$type = [System.Security.Cryptography.X509Certificates.X509ContentType]::Cert

get-childitem -path cert:\LocalMachine\AuthRoot | ForEach-Object {
	$hash = $_.GetCertHashString()
	[System.IO.File]::WriteAllBytes("$hash.der", $_.export($type) )
}