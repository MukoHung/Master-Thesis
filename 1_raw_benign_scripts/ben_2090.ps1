$stop = $args.Count
$inputIP = ""
$inputFile = ""
$knownIPFile = ""
$showUsage = 0
$verbose = 0
for ($i = 0; $i -lt $stop; $i++)
{
	if ($args[$i] -eq "-f") {
		if ( ($i + 1) -eq $stop) {
			$showUsage = 1
		}
		else {
			$i++
			$inputFile = $args[$i]
		}
	}
	elseif ($args[$i] -eq "-k") {
		if ( ($i + 1) -eq $stop) {
			$showUsage = 1
		}
		else {
			$i++
			$knownIPFile = $args[$i]
		}
	}
	elseif ($args[$i] -eq "-verbose") {
		$verbose = 1
	}
	else {
		if ( ($i + 1) -eq $stop) {
			$inputIP = $args[$i]
		}
		else {
			$showUsage = 1
		}
	}
}

if ($stop -eq 0) {
	$showUsage = 1
}

if ($showUsage) {
	Write-Host "Usage: ip_lookup.ps1 [-multiline] [-k <KNOWN_IP_FILE] -f <FILENAME>"
	Write-Host "       ip_lookup.ps1 [-multiline] [-k <KNOWN_IP_FILE] <IP_ADDRESS>"
	Write-Error "Bad Input"
	exit
}

$knownIPs = @{}
function LoadKnownIPs($knownIPList)
{
	# File should be IP<TAB>Description
	$reader = [System.IO.File]::OpenText($knownIPList)
	$line = $reader.ReadLine()
	
	while( $line) 
	{ 
		$result = $line.Split("`t")
		if ($result.Count -le 2) {
			$knownIPs[$result[0].Trim()] = $result[1]
		}
		else {
			Write-Output ("-" + $result[0].Trim() + "-")
			Write-Output "Error at $line with " + $result.Count
		}
		$line = $reader.ReadLine() 
	}
	$reader.Close()
}

if ( $knownIPFile -ne "" ) {
	LoadKnownIPs($knownIPFile)
}

function LookupIP($ip) {
	$result = nslookup $ip  2> $null | select-string -pattern "Name:"
	if ( ! $result ) { $result = "" }
	$result = $result.ToString()
	if ($result.StartsWith("Name:")) {
		$result = $result.Split()
		$result = $result[$result.Count -1 ]
	}
	else {
		$result = "NOT FOUND"
	}
	$knownMatch = ""
	if ($knownIPs.ContainsKey($ip)) {
		$knownMatch = $knownIPs[$ip]
	}
	if ($verbose) {
		Write-Output $ip 
		Write-Output $result 
		Write-Output $knownMatch
	} 
	else {
		Write-Output "$ip `t $result `t $knownMatch"
	}
}

if ( $inputFile -ne "") {
	$reader = [System.IO.File]::OpenText($inputFile)
	$line = $reader.ReadLine()
	
	while( $line) 
	{ 
		LookupIP $line.Trim()
		$line = $reader.ReadLine() 
	}
	$reader.Close()
}
else {
	LookupIP $inputIP
}