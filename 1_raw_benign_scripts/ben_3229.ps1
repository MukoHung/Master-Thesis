# By Anders and Henkan 2014-08-07 v1
# http://ideasof.andersaberg.com

$path = $args[0]
$chars = "abcdefghijklmnopqrstuvwxyz"

function GetFileName($num)
{	
	$name = ""	
	while($num -gt 25) {
		$name += "z"
		$num -= 26
	}
	$name += $chars[$num]	
	return $name
}

function RenameRec($xpath) {
	$counter = -1
	$items = @(Get-ChildItem $xpath | ForEach-Object -Process {$_.FullName})
	
	foreach($item in $items) {
		$counter += 1
		$filename = split-path $item -Leaf
		$name = GetFileName($counter)
		#write-host "OLD $filename NEW $name"
		if($filename -ne $name){

			#Write-Host "Renaming $item to $name"
			Rename-Item $item $name
		}
	}
	
	$folders = @(Get-ChildItem $xpath -Directory | ForEach-Object -Process {$_.FullName})
	foreach($folder in $folders) {
		RenameRec($folder)
	}
}

Write-Host "Renaming all files... (this can take a while, Ignore any errors)"
RenameRec($path)
Remove-Item $path