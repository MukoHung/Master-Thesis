param (
    [string]$file = $(throw "-file is required."),
    [string]$hash,
    [string]$algo = 'SHA256'
)

# available algorithms MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512

$calc = $($(CertUtil -hashfile $file $algo)[1] -replace " ","")

if (!$hash) {
    echo $calc   
}
elseif ($calc -eq $hash) {
    echo "ok"
}
else {
    echo "doesn't match"
}