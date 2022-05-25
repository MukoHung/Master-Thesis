$helpTopic = "about_Splatting"
$excludedWords = "the"
$words = ((Get-Help $helpTopic) -replace "[^\w]"," " -replace "\d"," " -replace '_'," " -split " ") | Where-Object {$_ -ne ""}
$sortedWords = $words | Group-Object | Sort-Object -Property Count -Descending | Where-Object -Property Name -NE $excludedWords

[PSCustomObject]@{
    'Help Topic Name'   = $helpTopic
    'Word Count'        = $words.Count
    'Top Word'          = ($sortedWords | Select-Object -First 1).Name
    'Top Word Count'    = ($sortedWords | Select-Object -First 1).Count
    'Top 5 Words'       = ($sortedWords | Select-Object -First 5).Name -join ", "
}
