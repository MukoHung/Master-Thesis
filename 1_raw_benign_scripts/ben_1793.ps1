<#
    .SYNOPSIS 
        Send an array of labels to a Github Repo
    .DESCRIPTION

    .EXAMPLE        
        Post-GithubLabels "##############" "myOrganization" "myRepo" '[{"name": "bug","color": "fc2929"},{"name": "duplicate","color": "cccccc"}]''
    .NOTES 
        Author     : Ryan Killeen
 #>
 function Post-GithubLabels($token, $orgOrUser, $repoName, $labels) {

    $postURL = "https://api.github.com/repos/" + $orgOrUser + "/" + $repoName + "/labels?access_token=" + $token 

    Write-Host $postURL

    $labelsAsObj =  $labels  | ConvertFrom-Json
    
    Foreach($label in $labelsAsObj) {
        $payload = $label | ConvertTo-Json
        $postResponse = Invoke-RestMethod $postURL -Method Post -Body $payload  -ContentType 'application/json'
    }
}