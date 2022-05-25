#Calculates an eTag for a local file that should match the S3 eTag of the uploaded file. 

$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider

$blocksize = (1024*1024*5)
$startblocks = (1024*1024*16)

function AmazonEtagHashForFile($filename) {
    $lines = 0
    [byte[]] $binHash = @()

    $reader = [System.IO.File]::Open($filename,"OPEN","READ")
    
    if ((Get-Item $filename).length -gt $startblocks) {
        $buf = new-object byte[] $blocksize
        while (($read_len = $reader.Read($buf,0,$buf.length)) -ne 0){
            $lines   += 1
            $binHash += $md5.ComputeHash($buf,0,$read_len)
        }
        $binHash=$md5.ComputeHash( $binHash )
    }
    else {
        $lines   = 1
        $binHash += $md5.ComputeHash($reader)
    }

    $reader.Close()
    
    $hash = [System.BitConverter]::ToString( $binHash )
    $hash = $hash.Replace("-","").ToLower()

    if ($lines -gt 1) {
        $hash = $hash + "-$lines"
    }

    return $hash
}
