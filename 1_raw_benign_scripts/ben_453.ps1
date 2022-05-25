# API Documentation can be at http://timlossev.com/attachments/Proteus_API_Guide_3.7.1.pdf
# Connecting the the API

$credential = Get-Credential
$uri = "http://bluecatserver/Services/API?wsdl"
$bc = New-WebServiceProxy -Uri $uri
$bc.CookieContainer = New-Object System.Net.CookieContainer
$bc.login($Credential.UserName, ($Credential.GetNetworkCredential()).Password)

# Find IP based on assigned name in Bluecat

$name = "node1"
$bc.searchByObjectTypes("$name", "IP4Address", 0, 999)

# Assign/Update IP Assignments

$ip = '10.18.24.16'
$name = 'node2'
$record = $bc.getIP4Address(17,$ip)
if ($record.id -ne 0) {
    if ($record.name -ne $name) {
        if ($PSCmdlet.ShouldProcess("Replace $($record.name) with $($name) ?")) {
            $record.name = $name
            $bc.update($record)
        }
    }
}
if ($record.id -eq 0) {
    $mac=""
    $prop = "name=$name"
    $bc.assignIP4Address(17,$ip,$mac,$name,"MAKE_STATIC",$prop)
}

# Remove IP Assignmnet

$name = 'node2'
$prop = $bc.searchByObjectTypes("$name", "IP4Address", 0, 1)
$bc.delete($prop.id)

# Get next IP within specified subnet

$subnet = "10.18.20.0"
$network = $bc.searchByObjectTypes("$subnet", "IP4Network", 0, 999)
$bc.getNextIP4Address("$($network.id)",([regex]::Matches($($network.properties),"(?<=defaultView=)\d{6}").value))