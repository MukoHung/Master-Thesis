import-module activedirectory

$alladusers = Get-ADUser -filter * -Properties homemta -ResultSetSize 99999 | select samaccountname,homemta | where {$_.HomeMTA -match "Deleted Objects"}
foreach ($aduser in $alladusers)
    {
        $adusername = $aduser.samaccountname
        $database = (get-mailbox $adusername | select database).database
        $exserver = ((get-mailboxdatabase $database).ActivationPreference | where {$_.value -eq 1}).key.name
        [String]$newHomeMTA = "CN=Microsoft MTA," + (get-exchangeserver $exserver).DistinguishedName
        write-host "Bearbeite Benutzer: $adusername`t`tHomeMTA: $exserver"
        #set-aduser $adusername –replace @{homemta="$newHomeMTA"}
    }