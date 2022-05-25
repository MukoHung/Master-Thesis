########################################################
#
#       Check certificates inside a java keystore
#
########################################################

[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True)]
	[string]$keystore,
		
	[Parameter(Mandatory=$True)]
	[string]$password,
	
	[Parameter(Mandatory=$True)]
	[string]$alias,
	
	[Parameter(Mandatory=$True)]
	[int]$threshold
)

[System.Threading.Thread]::CurrentThread.CurrentCulture = "en-US"

$keytool="keytool.exe"
$certificate = Invoke-Expression "$keytool -list -v -keystore $keystore -storepass $password -alias '$alias'"

foreach($line in $certificate){    
    if($line.Contains("Valid from: ")){        
		$index = $line.IndexOf("until: ")
		$dateAsString = $line.SubString($index + "until: ".length).Replace(" CET","")
		$expirationDate = [datetime]::parseexact($dateAsString,"ddd MMM dd HH:mm:ss yyyy",$null)
		break
    }
}

$now = ([System.DateTime]::Now)
$daysToExpire = [int]($expirationDate - $now).TotalDays

if ($threshold -lt $daysToExpire) {
	Write-Host "[OK] Certificate '$alias' expires in '$expirationDate' ($daysToExpire day(s) remaining)."
	exit 0
} elseif ($daysToExpire -lt 0) {
	Write-Host "[CRITICAL] Certificate $alias has already expired."
    exit 2
} else {
	Write-Host "[WARNING] Certificate '$alias' expires in '$expirationDate' ($daysToExpire day(s) remaining)."
    exit 1
}
