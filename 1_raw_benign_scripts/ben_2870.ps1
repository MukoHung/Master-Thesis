$postSlackMessage = @{token="*topsecret*";channel="#general";text="Hello from PowerShell!";username="PowerShell";icon_url="https://pbs.twimg.com/profile_images/1604347359/logo_512x512_normal.png"}
Invoke-RestMethod -Uri https://slack.com/api/chat.postMessage -Body $postSlackMessage