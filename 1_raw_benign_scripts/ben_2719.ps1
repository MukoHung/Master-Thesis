# Will need to be run as an administrator

$rule_name = "Valheim Server 1"
# Change ports as needed
$tcp_ports = "2456,2457,2458"
# Change ports as needed
$udp_ports = "2456,2457,2458"

netsh advfirewall firewall add rule name="${rule_name}: TCP" dir=in protocol=tcp localport=$tcp_ports action=allow
netsh advfirewall firewall add rule name="${rule_name}: UDP" dir=in protocol=udp localport=$udp_ports action=allow

pause