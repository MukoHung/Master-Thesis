$wsl_address = bash.exe -c "ifconfig eth0 | grep 'inet '"
$found = $wsl_address -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if( $found ){
  $wsl_address = $matches[0];
} else{
  echo "The Script Exited, the ip address of WSL 2 cannot be found";
  exit;
}

#[Ports]

#All the ports you want to forward separated by coma
$ports_local=@(2222,9833,8080,1026,6201,1107,7011);
$ports_remote=@(22,3389,8080,1026,6201,1107,7011);

#[Static ip]
#You can change the addr to your ip config to listen to a specific address
$addr='0.0.0.0';
# $ports_a = $ports -join ",";


#Remove Firewall Exception Rules
#iex "Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' ";

#adding Exception Rules for inbound and outbound Rules
# iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP";
# iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP";

for( $i = 0; $i -lt $ports_local.length; $i++ ){
  $port_local = $ports_local[$i];
  $port_remote = $ports_remote[$i];
  iex "netsh interface portproxy delete v4tov4 listenport=$port_local listenaddress=$addr";
  iex "netsh interface portproxy add v4tov4 listenport=$port_local listenaddress=$addr connectport=$port_remote connectaddress=$wsl_address";
}
