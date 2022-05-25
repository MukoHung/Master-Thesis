# Zabbix graph save script.
# Required PowerShell v3.0 or later.

# variables.
$zabbixURL = "http://192.168.0.10/zabbix/"
$zabbixAPIURL = $zabbixURL + "api_jsonrpc.php"
$zabbixGraphURL = $zabbixURL + "chart2.php?graphid="
$baseJSON = @{ "jsonrpc" = "2.0"; "id" = 1 }

# Get login token.
$authJSON = $baseJSON.clone()
$authJSON.method = "user.login"
$authJSON.params = @{ "user" = "Admin"; "password" = "zabbix" }
$login = Invoke-RestMethod -Uri $zabbixAPIURL -Body ($authJSON | ConvertTo-Json) -method POST -ContentType "application/json"
$baseJSON.auth = $login.result

# Set Cookie.
$zabbixDomain = $zabbixURL
$session = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object -TypeName System.Net.Cookie
$cookie.Name = "zbx_sessionid"
$cookie.Value = $login.result
$session.Cookies.Add($zabbixDomain,$cookie)

# get hostids
$hostGetJSON = $baseJSON.clone()
$hostGetJSON.method = "host.get"
$hostGetJSON.params = @{ "output" = "extend" }
$hostGetResult = Invoke-WebRequest -Uri $zabbixAPIURL -WebSession $session -Body ($hostGetJSON | ConvertTo-Json) -method POST -ContentType "application/json"
$hosts = ($hostGetResult.toString() | ConvertFrom-Json).result
$hosts | % {
    $hostname = $_.name
    $hostID = $_.hostid

    # get graphids per host.
    $graphGetJSON = $baseJSON.clone()
    $graphGetJSON.method = "graph.get"
    $graphGetJSON.params = @{ "output" = "extend"; "hostids" = $hostID }
    $graphGetResult = Invoke-WebRequest -Uri $zabbixAPIURL -WebSession $session -Body ($graphGetJSON | ConvertTo-Json) -method POST -ContentType "application/json"
    $graphs = ($graphGetResult.toString() | ConvertFrom-Json).result
    # save graphs.
    $yyyymmdd = (Get-Date -Day 1).AddMonths(-1).toShortDateString() -replace('/')  # date format is depending OS configuration...?
    $graphs | % {
        $graphName = $_.name
        # prev. month graph data.
        $graphURL = $zabbixGraphURL + $_.graphid + '&period=2592000&width=800&stime=' + $yyyymmdd + '000000'
        $dir = "C:\zabbix_graphs\" + $hostname
        New-Item -ItemType Directory -Force $dir
        $output = $dir + "\" + $hostname + $_.graphid + ".png"
        Invoke-WebRequest -Uri $graphURL -WebSession $session -Outfile $output
    }
}

