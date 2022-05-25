 param (
    [string]$Version = $( Read-Host "Input version" ),
    [string]$DomainName = $( Read-Host "Input domain name" ),
    [string]$ApplicationName = $( Read-Host "Input application name" )
 )


$ApplicationURI = $("https://$DomainName/$ApplicationName")


#--------------------------------------------------------------------------------------
# to create 256 bit AES key
# FROM: https://gist.github.com/ctigeek/2a56648b923d198a6e60
function Create-AesManagedObject($key, $IV) {

    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256

    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }

    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }

    $aesManaged
}


function Create-AesKey() {
    $aesManaged = Create-AesManagedObject 
    $aesManaged.GenerateKey()
    [System.Convert]::ToBase64String($aesManaged.Key)
}

#--------------------------------------------------------------------------------------




#--------------------------------------------------------------------------------------
#
#This function is used to get the authentication token. 
#
#FROM: http://stackoverflow.com/questions/31684821/how-to-add-application-to-azure-ad-programmatically/39136456#39136456
function GetAuthToken
{
       param
       (
              [Parameter(Mandatory=$true)]
              $TenantName
       )

       $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

       $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"

       [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null

       [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

       $clientId = "1950a258-227b-4e31-a9cf-717495945fc2" 

       $redirectUri = "urn:ietf:wg:oauth:2.0:oob"

       $resourceAppIdURI = "https://graph.windows.net"

       $authority = "https://login.windows.net/$TenantName"

       $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

       $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId,$redirectUri, "Auto")

       return $authResult
}

#
#You can then submit a POST request to the Azure Active Directory Graph API in order to create your application. However there is a little setup required...
#



# The name of this AAD instance
$global:tenant = $DomainName
$global:aadSecretGuid = New-Guid
$global:aadDisplayName = $ApplicationName
$global:aadIdentifierUris = @($ApplicationURI)

#BH: Not using this now.  Using function "Create-AesKey" instead..
#$guidBytes = [System.Text.Encoding]::UTF8.GetBytes($global:aadSecretGuid)
$global:aadSecretKey = Create-AesKey

$global:aadSecret = @{
    'endDate'=[DateTime]::UtcNow.AddDays(365).ToString('u').Replace(' ', 'T');
    'keyId'=$global:aadSecretGuid;
    'startDate'=[DateTime]::UtcNow.AddDays(-1).ToString('u').Replace(' ', 'T');  
    'value'=$global:aadSecretKey
}

#Save the key to a file
$SecretFile = $("$SecretFilePath\$($ApplicationName)_Secret.key")
$global:aadSecretKey | out-file $SecretFile
Write-Host $("----- Application Key is $global:aadSecretKey")
Write-Host $("----- Application Key Value saved to file $SecretFile")


# ADAL JSON token - necessary for making requests to Graph API
$global:token = GetAuthToken -TenantName $global:tenant


# REST API header with auth token
$global:authHeader = @{
    'Content-Type'='application/json';
    'Authorization'=$global:token.CreateAuthorizationHeader()
}


#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
#
#Now you can hit the Graph API, and create the AAD application
#NOTE:
# I modifed the original code taken from http://stackoverflow.com/questions/31684821/how-to-add-application-to-azure-ad-programmatically/39136456#39136456
# so that the "PasswordCredentials" are suplpied rather than "KeyCredentials". Having checked the manifest of an application and key 
# created manually in the portal, this is what needs to be provded to achive the same thing here)
#

$resource = "applications"
$payload = @{
    'displayName'=$global:aadDisplayName;
    'homepage'= $ApplicationURI;
    'identifierUris'= $global:aadIdentifierUris;
    'passwordCredentials'=@($global:aadSecret)
}
$payload = ConvertTo-Json -InputObject $payload
$uri = "https://graph.windows.net/$($global:tenant)/$($resource)?api-version=1.6"

Write-Host $("----- Calling Graph REST API to create application $ApplicationName")

$result = (Invoke-RestMethod -Uri $uri -Headers $global:authHeader -Body $payload -Method POST -Verbose).value

#--------------------------------------------------------------------------------------


Get-AzureRmADApplication -DisplayNameStartWith $ApplicationName | Select-Object -ExpandProperty 'ApplicationId' | Out-File $SecretFile -Append