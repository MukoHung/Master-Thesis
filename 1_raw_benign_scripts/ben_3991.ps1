###### STEP 1 - Get GIT Credentials
$EncryptedPasswordString = "Your Encrypted Github Password String"
$Args = "Your Github Username", ($EncryptedPasswordString |ConvertTo-SecureString)
$GitCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Args

# Required Functions
Function Update-AllPowerShellProfile
{
    $ProfileDirectory =  "$env:USERPROFILE\Documents\WindowsPowerShell\"
    $AllPSPRofiles = dir $ProfileDirectory | ?{$_.name -like "*Profile*"} | sort LastWriteTime -Descending
    
    If($AllPSPRofiles[0].LastWriteTime -ne $AllPSPRofiles[1].LastWriteTime)
    {
        Write-Host "Newer version of profile found." -ForegroundColor Yellow
        Write-Host "Replicating it to other Powershell profiles and to the Copy on your GitHub gist." -ForegroundColor Yellow
        $LastEditedProfile = $AllPSPRofiles[0]
        $OtherProfiles = (dir $ProfileDirectory |`
        ?{$_.name -ne $($LastEditedProfile.name) -and $_.name -like "*Profile*"}).FullName

# STEP 2 - Update other local profiles of other PowerShell hosts
        
        $OtherProfiles | % { Copy-Item -Path $LastEditedProfile.FullName -Destination $_ -Force }

# STEP 3 - Update the Secrete Gist on GitHub
        
        Update-GithubGist -Path $profile -GistName "$(hostname)_Profile.ps1" -Secret | Out-Null
        Write-Host "DONE." -ForegroundColor Green
    }
}

Function Get-GithubGist
{

Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName = $True)] [String[]] $GithubUser,
        [String[]] $FileName,
        [switch] $openInISE
)

    Begin
    {
        $output = @()

        if(!$GitCreds){$GitCreds = Get-Credential ''}
            
        $AuthenticationString = "{0}:{1}" -f $GitCreds.UserName, $GitCreds.GetNetworkCredential().Password
        $AuthenticationString = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($AuthenticationString))
        
        $Header = @{
                        'Authorization' = 'Basic ' + $AuthenticationString
                        'Content-Type' = 'application/json'
        }
    
    }
    Process
    {       
        Foreach($User in $GithubUser)
        {
            $Gists = Invoke-RestMethod -Headers $Header -Uri "https://api.github.com/users/$($User)/gists?per_page=100"
            
            $Result  =  ForEach($Gist in $Gists)
                        {
                            
                            $FileInfo = $Gist.files."$(($Gist.files |gm -MemberType NoteProperty).Name)"
            
                            #$GetFileName = {($gist.files| Get-Member -MemberType NoteProperty).Name}
                            [PSCustomObject]@{
                                GithubUser = $User
                                Language = $FileInfo.language        
                                FileName = $FileInfo.Filename
                                Url      = $gist.url
                                RawUrl   = ($gist.files).($FileInfo.filename).raw_url
                                GistID   = Split-Path -Leaf $gist.url
                            }
                        }
            
            $output += $Result | Where-Object {$_.FileName -match $FileName}

        }

        $output
                                

        If($openInISE)
        {
            $output | Foreach{
                        
                      $OpenTab = $psISE.CurrentPowerShellTab.Files.Add()
                      $OpenTab.Editor.Text = Invoke-RestMethod -Uri $($_.rawurl).tostring() -Headers $Header
            }
        }
    }
    End
    {
        
    }
}
Function Update-GithubGist
{    
Param(
        [Parameter(Mandatory=$true)] [String] $Path,
        [Parameter(Mandatory=$true)] [String] $GistName,
        [Switch] $Secret = $False
)

    Begin
    {
        $URL = $APIURL = "https://api.github.com/gists"
        $Method  = 'POST'
        $TargetGithubGist = Get-GithubGist -GithubUser $GitCreds.UserName -FileName $GistName
    }
    Process
    {
    
        if (Test-Path -Path $Path)
        {
            $fileName = Split-Path -Path $Path -Leaf
            $contents = Get-Content -Path $Path -Raw
        }    

        #region gist Header
        if(!$GitCreds){$GitCreds = Get-Credential 'prateekkumarsingh'}
            
        $AuthenticationString = "{0}:{1}" -f $GitCreds.UserName, $GitCreds.GetNetworkCredential().Password
        $AuthenticationString = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($AuthenticationString))
        
        $Header = @{
                        'Authorization' = 'Basic ' + $AuthenticationString
                        'Content-Type' = 'application/json'
        }
    #endregion

        #region Gist Body
        $Gist = @{
                    'description' = "This gist was updated on $((Get-Date).tostring("dd\-MMM\-yy hh\:mm\:ss")) from Machine: $(hostname)"
                    'public' = -not($Secret)
                    'files' = @{
                                "$(hostname)_Profile.ps1" = @{
                                                    'content' = "$($contents)"
                                                  }
                               }
        }
    #endregion

        
        if($TargetGithubGist)
        {
            Invoke-RestMethod -Uri $($APIURL + "/"+ $TargetGithubGist.GistID) -Method 'patch' -Headers $Header -Body ($gist | ConvertTo-Json)|`
            Select URL, ID, @{n='LocalFileName';e={$Path}},Public, created_at, updated_at,Description, @{n='Owner';e={($_.owner).login}}
        }
        else # When the Gistname mentioned by the user doesn't exist.
        {
            Invoke-RestMethod -Uri $URL -Method 'Post' -Headers $Header -Body ($gist | ConvertTo-Json) |`
            Select URL, ID, @{n='LocalFileName';e={$Path}},Public, created_at, updated_at,Description, @{n='Owner';e={($_.owner).login}}
        }

    }
    End
    {
        
    }

    

}

# Call
Update-AllPowerShellProfile