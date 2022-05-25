param
(
    [string] $BuildID=""
)

#global variables
$baseurl = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI 
$baseurl += $env:SYSTEM_TEAMPROJECT + "/_apis"

Write-Debug  "baseurl=$baseurl"
Write-Debug  "basermurl=$basermurl"

<#
.Synopsis
Creates either a Basic Authentication token or a Bearer token depending on where the method is called from VSTS. 
When you send a Personal Access Token that you generate in VSTS it uses this one. Within the VSTS pipeline it uses env:System_AccessToken 
#>
function New-VSTSAuthenticationToken
{
    [CmdletBinding()]
    [OutputType([object])]
         
    $accesstoken = "";
    if([string]::IsNullOrEmpty($env:System_AccessToken)) 
    {
        if([string]::IsNullOrEmpty($env:PersonalAccessToken))
        {
            throw "No token provided. Use either env:PersonalAccessToken for Localruns or use in VSTS Build/Release (System_AccessToken)"
        } 
        Write-Debug $($env:PersonalAccessToken)
        $userpass = ":$($env:PersonalAccessToken)"
        $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($userpass))
        $accesstoken = "Basic $encodedCreds"
    }
    else 
    {
        $accesstoken = "Bearer $env:System_AccessToken"
    }

    return $accesstoken;
}


<#
.Synopsis
Sets a Build Tag on a specific BuildID. Semicolon separates multiple Build Tags (e.g. Test;TEST2;Ready)
#>
function Set-BuildTag
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [string] $BuildID="",
        [string] $BuildTags=""
    )

    $buildTagsArray = $BuildTags.Split(";");

    $token = New-VSTSAuthenticationToken

    Write-Host "BaseURL: [$baseurl]"
    Write-Host "tagURL: [$tagURL]"
    Write-Host "token: [$token]"

    if ($buildTagsArray.Count -gt 0) 
    {

        foreach($tag in $buildTagsArray)
        {
            $tagURL = "$baseurl/build/builds/$BuildID/tags/$tag`?api-version=2.0"
            $response = Invoke-RestMethod -Uri $tagURL -Headers @{Authorization = $token}  -Method Put
            Write-Host $response
        }   
    }
}

<#
.Synopsis
Sets a Build Tag on a specific BuildID. Semicolon separates multiple Build Tags (e.g. Test;TEST2;Ready)
#>
function Get-BuildTrigger
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [string] $BuildID=""
    )

    $token = New-VSTSAuthenticationToken
    $buildUrl = "$baseurl/build/builds/$($BuildID)?api-version=2.0"
    $response = Invoke-RestMethod -Uri $buildUrl -Headers @{Authorization = $token}  -Method Get

    return $response.reason
}

function Set-BuildTagToTrigger
{
    param
    (
        [string] $BuildID=""
    )
 
    $reason =  Get-BuildTrigger -BuildID $BuildID
    Set-BuildTag -BuildID $BuildID -BuildTags $reason

 }

 Set-BuildTagToTrigger -BuildID $BuildID