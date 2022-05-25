# Get last 100 log entries as a PowerShell object
$gitHist = (git log --format="%ai`t%H`t%an`t%ae`t%s" -n 100) | ConvertFrom-Csv -Delimiter "`t" -Header ("Date","CommitId","Author","Email","Subject")

# Now you can do iterate over each commit in PowerShell, group sort etc.
# Example to get a commit top list
$gitHist|Group-Object -Property Author -NoElement|Sort-Object -Property Count -Descending

# Example do something for each commit
$gitHist|% {if ($_.Author -eq "Mattias Karlsson") {"Me"} else {"Someone else"} }