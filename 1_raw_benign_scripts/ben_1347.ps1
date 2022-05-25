echo "[+] Getting \system\\currentcontrolset\\services"

$raw_services = Get-ChildItem -Path hklm:\system\\currentcontrolset\\services | select Name
$services = @()

foreach ($srv in $raw_services) {
	$shortname = "$srv".Split("\")[-1]
	$shortname = $shortname.Substring(0,$shortname.Length-1)
	$services += $shortname
}

echo "[+] Downloading drv_list.txt from Github (safe)"

$drv_list = (new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/x0rz/EQGRP_Lost_in_Translation/633bd9097a88cb71f1af837e006c09dabf5c9273/windows/Resources/Ops/Data/drv_list.txt") 
foreach ($line in $drv_list.Split([Environment]::NewLine)) {
	$srv = $line.Split('",')[1]
	if ($services -contains $srv) {
		$desc = $line.Split('",')[4]
		if ($desc -like "KILL") {
			echo "You most likely have an Equation Group malware"
			write-host "$srv`t => $desc" -foreground "red"
		} elseif ($desc -match '[**|!!]') {
			write-host "$srv`t => $desc" -foreground "yellow"
		} else {
			echo "$srv`t => $desc"
		}
	}
}
