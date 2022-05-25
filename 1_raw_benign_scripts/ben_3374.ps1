<#
    .SYNOPSIS
    
    Sends a message to one or more Rocket.Chat WebHooks.

    .DESCRIPTION

    This script can be called with parameters in order to send a message to one or more
    Rocket.Chat webHooks. The text may contain any supported format keywords you can use
    in the GUI.

    If the message was sent to all Webhooks, the Return Code is 0. If a webhook couldn't
    be reached and CrashOnFailure isn't set, the Return Code is 1. In that case the script
    will try to send the other messages. If CrashOnFailure is set, the script will terminate
    with RC 1 after the first unsuccessful attempt.

    .PARAMETER Text

    The text you want to send to the webhook. When calling this from the command line, make
    sure to surround the text with quotes and/or curly braces. The escape character is ` .

    .PARAMETER WebHooks

    Enter the URLs of one or more Webhooks separated by a semicolon.

    .PARAMETER Icon

    (Optional)
    Enter the name of an Icon that's supposed to be displayed as the profile picture of the
    sender. A regex ensures the value starts and ends with a colon.

    .PARAMETER CrashOnFailure

    If this switch is used and one of the Webhooks can't be reached or process the message
    the script exists with RC = 1.

    .EXAMPLE

    Send "Hello World" to a Webhook with the Globe-Icon.

    .\Rocket_Chat_send_Message.ps1 -Text "Hello World!" -Icon ":earth_africa" -Webhooks "http://rc-test.com/hooks/d9ik3Kdk/..."

    .EXAMPLE

    Send "Hello World" to two Webhooks

    .\Rocket_Chat_send_Message.ps1 -Text "Hello World!" -Webhooks "http://rc-test.com/hooks/d9ik3Kdk/...;http://rc-test.com/hooks/d9ik3KAKDJ/..."

    .NOTES

    Author: Maurice B.
    Github: https://github.com/MauriceBrg

#>

# We need at least PS-Version 3 for Invoke-RestMethod
#Requires -Version 3

Param(
    [Parameter(Mandatory=$True)]
     [ValidateNotNullOrEmpty()]
     [string] $Text,
    [Parameter(Mandatory=$True)]
     [ValidateNotNullOrEmpty()]
     [string] $WebHooks,
    [Parameter(Mandatory=$False)]
     [ValidatePattern('^:.{1,}:$')] # Simple sanity check, should start and end with a colon and have at least one character in betweekn
     [string] $Icon,
    [Parameter(Mandatory=$False)]
     [switch] $CrashOnFailure
)


$ReturnCode = 0

$Payload = @{
  "text"= $Text
}

# Add the icon to the Payload if the parameter isn't empty
if ( -not [string]::IsNullOrWhiteSpace($Icon) ) {
    $Payload["icon_emoji"] = $Icon
}



$WebHooks -split ";" | ForEach-Object {

    $Hook = $_

    try {
        $Result = Invoke-RestMethod -Uri $Hook -Body $Payload -Method Post -ErrorAction Stop

        if ( -not $Result.success ){
            throw ("Posting to {0} wasn't successful!" -f $Hook)
        }

    } catch {

        $Exception = $_

        Write-Host ("Something went wrong while posting to {0} !" -f $Hook)
        Write-Host ("Error: {0}" -f $Exception )

        if ( $CrashOnFailure ) {
            # We encountered an error, exit now!
            exit(1)
        } else {
            $ReturnCode = 1
        }
    }

}

exit($ReturnCode)