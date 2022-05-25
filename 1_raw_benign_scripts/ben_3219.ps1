[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    $Filter=".*",
    
    #TODO: handle https & no basic auth as well..
    $RegistryEndpoint = "registry.mysite.com",
    $UserName = "user",
    $Password = "password"
)


#encode credentials to Base64String
$AuthString = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($UserName):$($Password)"))

$Result = (Invoke-RestMethod -Uri "http://$RegistryEndpoint/v2/_catalog" -Method Get -Headers @{ Authorization = "Basic $AuthString";}).repositories -Match $Filter

Write-Host -ForegroundColor Green ("found {0} images:" -f $Result.count)
$Result | % { 
    $image=$_
    $image
    (irm -uri "http://$RegistryEndpoint/v2/$image/tags/list" -Method Get -Headers @{ Authorization = "Basic $AuthString";}).tags  | % {
        $tag=$_
        "  docker pull $RegistryEndpoint/${image}:${tag}"
    }
}