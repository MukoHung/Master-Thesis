### sense api powershell examples
# with reference:
#  https://www.jokecamp.com/blog/invoke-restmethod-powershell-examples/
#  https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/invoke-restmethod

## enter your email address and password (will use securestring later)
$emailAddress = "email@contoso.corp"
$password = "insertpassword"




## change the security protocol to TLS 1.2
#https://msdn.microsoft.com/en-us/library/system.net.securityprotocoltype%28v=vs.110%29.aspx?f=255&MSPPError=-2147217396
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


## these headers were used by my client as of february 2017
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Sense-Client-Version", '1.3.7-9be446d')
$headers.add("Host", 'api.sense.com')
$headers.add("User-Agent", 'okhttp/3.4.1')

$body = @{
  email=$emailAddress
  password=$password
}


## create an authorized session
$senseAuthentication = invoke-restmethod -uri https://api.sense.com/apiservice/api/v1/authenticate -method post -sessionvariable sensewebsession -Body $body -headers $headers -transferencoding "compress"
$monitorID = $(($senseAuthentication.monitors).id)
$headers.add("Authorization", "bearer $($senseAuthentication.access_token)")



## get info on your sense device
$sensedevicestatusresponse = invoke-restmethod https://api.sense.com/apiservice/api/v1/app/monitors/$monitorID/status -method get -websession $sensewebsession -headers $headers


## list devices
$devicelistresponse = invoke-restmethod https://api.sense.com/apiservice/api/v1/app/monitors/$monitorID/devices -method get -websession $sensewebsession -headers $headers


## get usage history
$granularity = "SECOND" #acceptable values: SECOND,MINUTE,HOUR,DAY,WEEK,MONTH,YEAR
$startDateTime = "2017-02-07T01:48:00.000Z" #start time of data in UTC
$frames = "5400" #number of data samples you will retrive. the android client default is 5400

$senseUsageHistory = invoke-restmethod "https://api.sense.com/apiservice/api/v1/app/history/usage?monitor_id=$monitorID&granularity=$granularity&start=$startDateTime&frames=$frames" -method get -websession $sensewebsession -headers $headers
