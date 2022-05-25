#based largely on https://www.lewisroberts.com/2016/05/28/using-azure-dns-dynamic-dns/

Function Get-DDWRTExternalIP {
    $Page = Invoke-WebRequest -UseBasicParsing -Uri "http://icanhazip.com/"

    Return $Page.Content.Trim()
}

# Get the invocation path of the current file.
$ScriptPath = Split-Path $Script:MyInvocation.MyCommand.Path

# Set the expected IP Address. Obtain this from a DNS query or set it statically.
$EI = [System.Net.Dns]::GetHostAddresses("test.com") | Select-Object -ExpandProperty IPAddressToString
Write-Host $EI
# Obtain the IP Address of the Internet connection.
$IP = Get-DDWRTExternalIP

# If the IP isn't what you expected...
If ($IP -ne $EI) {

    # Login to Azure
    #$Creds = Import-Clixml -Path $ScriptPath"AzureRMCreds.xml"
    #Write-Host $ScriptPath"AzureRMCreds.xml"
    #Login-AzureRmAccount -Credential $Creds

    $azureAplicationId ="Application/Directory Id"
    $azureTenantId= "Tenant Id"
    $azurePassword = ConvertTo-SecureString "Application secure key" -AsPlainText -Force
    $psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
    Add-AzureRmAccount -Credential $psCred -TenantId $azureTenantId  -ServicePrincipal 
    
    # Update the apex record
    $RecordSet = New-AzureRmDnsRecordSet -Name "subdomain" -RecordType A -ZoneName "test.com" -ResourceGroupName "ResourceGroupName" -Ttl 60 -Overwrite -Force
    Add-AzureRmDnsRecordConfig -RecordSet $RecordSet -Ipv4Address $IP
    Set-AzureRmDnsRecordSet -RecordSet $RecordSet

}
Else {
    Write-Output "No need to update DNS address as they both match ($IP)"
}