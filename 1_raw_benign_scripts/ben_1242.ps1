$infos = @{
     'ServerInstance'='DESKTOP-QB7CLF4';
     'Username' = 'test';
     'Password' = '1452' 
}

Invoke-Sqlcmd @infos -Query 'DROP DATABASE IF EXISTS gksbm'
Write-Host 'Database dropped!'
