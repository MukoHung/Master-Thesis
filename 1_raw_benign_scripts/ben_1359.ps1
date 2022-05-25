Set-StrictMode -Version Latest

$payload = @{
	"channel" = "#my-channel"
	"icon_emoji" = ":bomb:"
	"text" = "This is my message. Hello there!"
	"username" = "Mr. Robot"
}

Invoke-WebRequest `
	-Body (ConvertTo-Json -Compress -InputObject $payload) `
	-Method Post `
	-Uri "https://hooks.slack.com/services/HOOK_API_SLUG" | Out-Null
