cmdkey /list | ForEach-Object{if($_ -like "*target=TERMSRV/*"){cmdkey /del:($_ -replace " ","" -replace "Target:","")}}
echo "Connecting to 192.168.1.100"
$Server="192.168.1.100"
$User="Administrator"
$Password="AdminPassword"
cmdkey /generic:TERMSRV/$Server /user:$User /pass:$Password
mstsc /v:$Server
