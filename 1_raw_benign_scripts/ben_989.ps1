Get-WmiObject CommandLineEventConsumer -namespace root\subscription | Where-Object {$_.Name -match ('SCM Event Consumer')} | Select-Object -first 1 | Remove-WmiObject

Get-WmiObject __EventFilter -namespace root\subscription | Where-Object {$_.Name -match ('SCM Event Filter')} | Select-Object -first 1 | Remove-WmiObject

netsh.exe ipsec static delete policy name=netbc
netsh.exe ipsec static delete filteraction name=block
netsh.exe ipsec static delete filterlist name=block