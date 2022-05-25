$siteURL='http://example.com/'
# Set file name
$File = '.\urls.txt'


# Process lines of text from file and assign result to $NewContent variable
$NewContent = Get-Content -Path $File |
    ForEach-Object {
        # First we create the request.
        $HTTP_Request = [System.Net.WebRequest]::Create($siteURL + $_)

        try{
            # We then get a response from the site.
            $HTTP_Response = $HTTP_Request.GetResponse()
        }
        catch [System.Net.WebException] {
            # HTTP error, grab response from exception
            $HTTP_Response = $_.Exception.Response
        }
        finally {
            # Grab status code and dispose of response stream
            $HTTP_Status = [int]$HTTP_Response.StatusCode
            $HTTP_Response.Dispose()
        }

        $siteURL+"$_ - $HTTP_Status"

    }

# Write content of $NewContent varibale back to file
$NewContent | Out-File -FilePath $File -Encoding Default -Force