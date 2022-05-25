param(
	[switch]$force = $false
)

$values = Get-Params $MyInvocation.UnboundArguments -values

$aliasFile = "C:\Program Files\PowerShell\7\Profile.ps1"
$content = Get-Content $aliasFile
$aliases = @()

$wordPattern = "^[A-Za-zА-Яа-я0-9\-]+$"
$scriptPattern = "^C:\\dev\\scripts\\powershell\\"
$namePattern = "^[^#].+ -Name .+"
$valuePattern = "^[^#].+ -Value .+"
$nameCapturePattern = ".+ -Name ([\w\-]+) -Value .+"

function printSplitValue {
	param([string]$value)
	$ext = $value.split(".")[1]
	$value = $value.split(".")[0]

	$category = $value.split("\")[0]
	$value -match ("\\([\w\\\-]+)") | Out-Null
	$value = $matches[1]
	write-host "..." -ForegroundColor DarkGray -NoNewline
	write-host "$category\" -ForegroundColor DarkGray -NoNewline
	write-host "$value" -ForegroundColor DarkYellow -NoNewline
	write-host ".$ext" -ForegroundColor DarkGray
}


if($values) {
	foreach($line in $content) {
		if($line -match $namePattern -and $line -match $valuePattern) {
			$value = $line.split("-Value ")[1]
			$line -match $nameCapturePattern | Out-Null
			$name = $matches[1]
			$aliases += @{ name=$name; value=$value }
		}
	}

	$matched = @()
	foreach($value in $values) {
		foreach($alias in $aliases) {
			if($value.length -eq 1) {
				if($alias.name -match "^$value.*") {
					$matched += $alias
				}
			}
			elseif($value.length -gt 1) {
				if($alias.name -match ".*$value.*") {
					$matched += $alias
				}
				elseif($value -ieq $alias.value) {
					$matched += $alias
				}
			}
		}
	}

	if($matched) {
		foreach($alias in $matched) {
			write-host $alias.name -ForegroundColor Cyan -NoNewline
			write-host " --> " -ForegroundColor DarkGray -NoNewline
			if($alias.value -match $scriptPattern) {
				$value = $alias.value.split("C:\dev\scripts\powershell\")[1]
				printSplitValue $value
			}
			elseif($alias.value -match $wordPattern) {
				write-host $alias.value -ForegroundColor DarkCyan
			}
			else {
				write-host $alias.value -ForegroundColor Gray
			}
		}
	}
	else {
		Print-Error "no matches found"
	}
}
else {
	if(!$force) {
		write-host "Print all aliases? " -ForegroundColor Cyan -NoNewline
		$force = Get-Answer @("YES", "Y")
	}

	if($force) {
		foreach($line in $content) {
			if($line -match $namePattern -and $line -match $valuePattern) {
				$value = $line.split("-Value ")[1]
				$line -match $nameCapturePattern | Out-Null
				$name = $matches[1]
	
				write-host $name -ForegroundColor Cyan -NoNewline
				write-host " --> " -ForegroundColor DarkGray -NoNewline
				if($value -match $scriptPattern) {
					$value = $value.split("C:\dev\scripts\powershell\")[1]
					printSplitValue $value
				}
				elseif($value -match $wordPattern) {
					write-host $value -ForegroundColor DarkCyan
				}
				else {
					write-host $value -ForegroundColor Gray
				}
			}
			else {
				write-host $line -ForegroundColor DarkGray
			}
		}
	}
}
