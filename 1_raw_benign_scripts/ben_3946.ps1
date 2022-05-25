$token = '<API_Token>'

$headers = @{
  "Authorization" = "Bearer $token"
  "Content-type" = "application/json"
}

$body = @{
    accountName="<Your_account>"
    projectSlug="<Your_project_slug>"
    branch="<Your_branch>"
    commitId="<Your_commit_id>"
}
$body = $body | ConvertTo-Json

Invoke-RestMethod -Uri 'https://ci.appveyor.com/api/builds' -Headers $headers  -Body $body -Method POST