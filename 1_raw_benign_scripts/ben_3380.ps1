# Initialize
$resourceSubDomainName = "sample-subdomain"
$zoneName = "contoso.local"
$hostedZone = Get-R53HostedZones | where Name -eq $zoneName

# Set ResourceRecordSet
$resourceName = $resourceSubDomainName + "." + $zoneName
$resourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
$resourceRecordSet.Name = $resourceName
$resourceRecordSet.Type = "A"
$resourceRecordSet.ResourceRecords = New-Object Amazon.Route53.Model.ResourceRecord ("192.168.0.100")
$resourceRecordSet.TTL = 300
$resourceRecordSet.Weight = 0

# Set Action
if (((Get-R53ResourceRecordSet -HostedZoneId $hostedZone.id).ResourceRecordSets | where Name -eq $resourceName | measure).Count -eq 0)
{
    $action = [Amazon.Route53.ChangeAction]::CREATE
}
else
{
    $action = [Amazon.Route53.ChangeAction]::UPSERT
}

# Set Change 
$change = New-Object Amazon.Route53.Model.Change ($action, $resourceRecordSet)

# Execute
Edit-R53ResourceRecordSet -HostedZoneId $hostedZone.Id -ChangeBatch_Change $change