$last = (Get-Date) – (new-timespan -days 90)
$EmptyGroups = Get-ADGroup -filter {(whenChanged -le $last)} -Properties members, memberof, WhenChanged, Name, `
 SamAccountName, GroupCategory, Description, Modified, WhenCreated, DistinguishedName -Server xxxx.xxx.com:3268 | `
 where {!$_.members} | where {!$_.membersof} | Where {!$_.memberof} | `
 where {(($_.DistinguishedName -notlike "*OU=xxx,OU=xxxx,DC=*,DC=uis,DC=xxx,DC=com") `
  -and ($_.DistinguishedName -notlike "*OU=xxx,DC=*,DC=xx,DC=xx,DC=com") `
  -and ($_.DistinguishedName -notlike "*OU=xxx,DC=xx,DC=xxx,DC=com") `
  -and ($_.DistinguishedName -notlike "*OU=xxx,OU=xx,DC=xx,DC=xx,DC=xxx,DC=com") `
  )} | ` 
  select Name, SamAccountName, DistinguishedName, Modified, WhenCreated, WhenChanged, Members, Memberof, Membersof |Export-Csv -Path .\EmptyGrpList.csv