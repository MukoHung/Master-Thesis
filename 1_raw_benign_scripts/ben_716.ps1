$m365Status = m365 status

if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
}

$webhookUrl = "https://digiwijs.webhook.office.com/webhookb2/c9c07cd0-9a64-42aa-9577-c9408fd25079@2ca3eaa5-140f-4175-9563-1172edf9f339/IncomingWebhook/dd1b9d0bbc69497d8ea8f47533f87973/88e85b64-e687-4e0b-bbf4-f42f5f8e674e"

# Send top 3 for SharePoint based on file actions.
$activityUsers = m365 spo report activityuserdetail --period D7 --output json --query 'reverse(sort_by(@, &\"Viewed Or Edited File Count\")) | [0:3].\"User Principal Name\"' | ConvertFrom-Json$title = "🏆 SharePoint Weekly Social Champions 🏆"
$card = '{ \"type\": \"AdaptiveCard\", \"$schema\": \"http://adaptivecards.io/schemas/adaptive-card.json\", \"version\": \"1.2\", \"body\": [  {  \"type\": \"TextBlock\",  \"text\": \"'+$($title)+'\",  \"wrap\": true,  \"size\": \"Medium\",  \"weight\": \"Bolder\",  \"color\": \"Attention\"  },  {  \"type\": \"TextBlock\",  \"wrap\": true,  \"text\": \"Week '+$(get-date -UFormat %V)+'\",  \"fontType\": \"Default\",  \"size\": \"Small\",  \"weight\": \"Lighter\",  \"isSubtle\": true  },  {  \"type\": \"FactSet\",  \"facts\": [   {   \"title\": \"First place\",   \"value\": \"'+$($activityUsers[0])+'\"   },   {   \"title\": \"Second place\",   \"value\": \"'+$($activityUsers[1])+'\"   },   {   \"title\": \"Third place\",   \"value\": \"'+$($activityUsers[2])+'\"   }  ]  } ] }'
m365 adaptivecard send --url $webhookUrl --card $card

# Send top 3 for Teams based on chat messages
$activityUsers = m365 teams report useractivityuserdetail --period D7 --output json --query 'reverse(sort_by(@, &\"Team Chat Message Count\")) | [0:3].\"User Principal Name\"' | ConvertFrom-Json


# Send top 3 for Yammer based on posts
$activityUsers = m365 yammer report activityuserdetail --period D7 --output json --query 'reverse(sort_by(@, &\"Posted Count\")) | [0:3].\"User Principal Name\"' | ConvertFrom-Json
$title = "🏆 Yammer Weekly Social Champions 🏆"
$card = '{ \"type\": \"AdaptiveCard\", \"$schema\": \"http://adaptivecards.io/schemas/adaptive-card.json\", \"version\": \"1.2\", \"body\": [  {  \"type\": \"TextBlock\",  \"text\": \"'+$($title)+'\",  \"wrap\": true,  \"size\": \"Medium\",  \"weight\": \"Bolder\",  \"color\": \"Attention\"  },  {  \"type\": \"TextBlock\",  \"wrap\": true,  \"text\": \"Week '+$(get-date -UFormat %V)+'\",  \"fontType\": \"Default\",  \"size\": \"Small\",  \"weight\": \"Lighter\",  \"isSubtle\": true  },  {  \"type\": \"FactSet\",  \"facts\": [   {   \"title\": \"First place\",   \"value\": \"'+$($activityUsers[0])+'\"   },   {   \"title\": \"Second place\",   \"value\": \"'+$($activityUsers[1])+'\"   },   {   \"title\": \"Third place\",   \"value\": \"'+$($activityUsers[2])+'\"   }  ]  } ] }'
m365 adaptivecard send --url $webhookUrl --card $card
