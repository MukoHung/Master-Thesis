function Choice-AzureSubscription
{
  $appdata = [environment]::GetFolderPath("Applicationdata")
  $jsonFile = Join-Path $appdata -childpath "Windows Azure Powershell" | join-path -ChildPath "AzureProfile.json"
  $json = get-content $jsonFile -encoding UTF8 -raw | ConvertFrom-Json

  if($json.Subscriptions.Count -gt 1) {
    for($index = 0;$index -lt $json.Subscriptions.Count;$index++){
      write-host $index ":" $json.Subscriptions[$index].Name
    }
    $subscriptionIndex = Read-Host "Select Azure Subscription " 
    if($subscriptionIndex -le $json.Subscriptions.Count -and $subscriptionIndex -ge 0) {
      Select-AzureSubscription $json.Subscriptions[$subscriptionIndex].Name
    }
  }  
}
