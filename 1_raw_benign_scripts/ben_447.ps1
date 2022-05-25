# the purpose of the script was to do a backup of all the repositories in a bitbucket team locally
# you can add this script in a scheduler daily or a teamcity build get a backup locally of all source code
# the following script connect to bitbucket.org to get all team repositories
# it does a foreach to clone new repository or fetch, pull existing one

# use auth2 to get a token
# https://developer.atlassian.com/cloud/bitbucket/oauth-2/
# adapt the following script by 
# 1- connect to your bitbucket account and create an auth consumer Key:Secret, give the read access to the project
# 2- create also an app password 
# 3- change the pairUserPass to the Key:Secret 
# 4- change the refresh_token that you get from bitbucket on the first connection
# I forgot how I did to get the refresh token....
# 5- put your team name 
# 6- put the username of the app password 
# 7- put the app password 
# $teamRepo = "PUT team name"
# $username = "PUT username"
# $appPassword = "PUT app password"

function get-MyToken {
    $pairUserPass = "Key:Secret"
 
    $tokenQuery = "https://bitbucket.org/site/oauth2/access_token"

    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pairUserPass))

    $basicAuthValue = "Basic $encodedCreds"

    $Headers = @{
        Authorization = $basicAuthValue
    }

    $body = @{
        "grant_type"    = "refresh_token"
        "refresh_token" = "PUT REFFRESH TOKEN HERE"
    }

    $resultRequest = Invoke-RestMethod -Method POST -Uri $tokenQuery -Headers $Headers -body $body -Verbose

    return $resultRequest
}

$teamRepo = "PUT team name"
$username = "PUT username"
$appPassword = "PUT app password"
$token = get-MyToken
write-host "token : $token"
$accestoken = $token.access_token
write-host "access token : $accestoken"

$query = "https://api.bitbucket.org/2.0/repositories/$($teamRepo)?access_token=$accestoken"
$query

[System.Collections.ArrayList] $listOfRepository = @()

For ($i=1; $i -le 500; $i++) {

  if ($query -eq "" -or $query -eq $null) {
    break
  }

  $result =  Invoke-WebRequest -Uri $query -Verbose

  $jsonObject = ConvertFrom-Json -InputObject $result.Content

  $query = $jsonObject.next
  foreach ($value in $jsonObject.values) {        
	Write-Warning $value.full_name
    $listOfRepository.Add($value)		
  }
}

$listOfRepository
# if the folder of the project does not exist locally
# git clone for each project
# else
# git fetch and pull for each project

$rootfolder = (Get-Location)

foreach ($repo in $listOfRepository) {
    write-host "Fullname $($repo.full_name)"
    write-host "Name $($repo.name)"

    $foldername = $repo.full_name.Replace("$($teamRepo)/", '')
    $foldername
    $localfolder = "$rootfolder\$($foldername)"
    
	write-host "foldername $($foldername)"
    write-host "localfolder $($localfolder)"
	
    Test-Path -Path  $localfolder

	if (!(Test-Path -Path  $localfolder )) {
		$url = "https://$($username):$($appPassword)@bitbucket.org/$($repo.full_name)"
		write-host "url $url"
		git clone $url

		Set-Location $localfolder -Verbose
		git fetch --all
		git pull --all
		Set-Location $rootfolder
	}
	else {
		Set-Location $localfolder -Verbose
		git fetch --all
		git pull --all
		Set-Location $rootfolder
	}
}