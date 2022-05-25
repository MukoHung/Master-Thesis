<#
.SYNOPSIS
Converts a JSON string into a PowerShell hashtable using the .NET System.Web.Script.Serialization.JavaScriptSerializer
.PARAMETER json
The string of JSON to deserialize
#>
function ConvertFrom-Json
{	
	param(
	[string] $json
	)
	
	# load the required dll
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
        $deserializer = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
	$dict = $deserializer.DeserializeObject($json)
	
	return $dict
}


<#
.SYNOPSIS
Converts a PowerShell hashtable into a JSON string using the .NET System.Web.Script.Serialization.JavaScriptSerializer
.PARAMETER dict
The object to serialize into JSON.
#>
function ConvertTo-Json
{
	param(
	[Object] $dict
	)
		
        # load the required dll
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
        $serializer = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
	$json = $serializer.DeserializeObject($dict)
	
	return $json
}

<#
.SYNOPSIS
Performs synchronous HTTP communication with the target specified.
.DESCRIPTION
Using the System.Net.WebRequest object, creates an HTTP web request 
populating it with the $content specified and submitting the request 
to the $target indicated using the incoming $verb.
.PARAMETER target
The target URL to communicate with
.PARAMETER authHeader
The content of an AUTHORIZATION header to add to the HTTP request.
Examples: "Basic someEncodedUserPass" or "token someOAuthToken"
.PARAMETER verb
The HTTP verb to assign the request.
.PARAMETER content
The string content to encode and add to the request body.
#>
function Execute-HttpCommand() {
    param(
        [string] $target,
	[string] $authHeader,
	[string] $verb,	
	[string] $content
    )

	$webRequest = [System.Net.WebRequest]::Create($target)
        $encodedContent = [System.Text.Encoding]::UTF8.GetBytes($content)
        $webRequest.Headers.Add("Authorization", $authHeader);
        $webRequest.Method = $verb

	write-host "Http Url: $target"
	write-host "Http Verb: $verb"
	write-host "Http authorization header: $authHeader"
	write-host "Http Content: $content"
	if($encodedContent.length -gt 0) {
		
	     $webRequest.ContentLength = $encodedContent.length
    	     $requestStream = $webRequest.GetRequestStream()
    	     $requestStream.Write($encodedContent, 0, $encodedContent.length)
    	     $requestStream.Close()
	}

        [System.Net.WebResponse] $resp = $webRequest.GetResponse();
	if($resp -ne $null) {
    	     $rs = $resp.GetResponseStream();
    	     [System.IO.StreamReader] $sr = New-Object System.IO.StreamReader -argumentList $rs;
    	     [string] $results = $sr.ReadToEnd();
	     return $results;
	}
	return '';
}