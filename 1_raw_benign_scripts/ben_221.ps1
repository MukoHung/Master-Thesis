#This script will display the ADPrep Version for your Schema, Forest, Domain and RODC

Import-Module ActiveDirectory

CD AD:

$Forest = Read-Host 'Put your forest name in DN format like DC=msft,DC=Net'

$Rootdomain=Get-ADForest | select RootDomain

$Schemaversion=[ADSI]"LDAP://cn=schema,cn=configuration,$Forest"

$ForsetPrep=[ADSI]"LDAP://CN=ActiveDirectoryUpdate,CN=ForestUpdates,cn=configuration,$Forest"

$RODCPrep=[ADSI]"LDAP://CN=ActiveDirectoryRodcUpdate,CN=ForestUpdates,cn=configuration,$Forest"

$domainPrep=[ADSI]"LDAP://CN=ActiveDirectoryUpdate,CN=DomainUpdates,CN=System,$Forest"

 

Write-Host "Schema Version"

$Schemaversion.Properties.objectVersion

Write-Host "ForestPrep Version"

$ForsetPrep.Properties.revision

Write-Host "RODCPrep Version"

$RODCPrep.Properties.revision

Write-Host "DomainPrep Version"

$domainPrep.Properties.revision 

sl c: