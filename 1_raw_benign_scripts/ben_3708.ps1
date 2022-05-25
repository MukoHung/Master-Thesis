# Works with PowerShell v2, but only works with very simple JSON
function Get-SimpleJSON {
    param(        
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$True)]
        [Alias('Uri')]
        [string]$JSONUri,
        
        [Alias('CamelCase')]
        [switch]$TitleCase
    )
    if ($JSONUri -notlike "*://*") { $JSONUri = "http://$($JSONUri)" }
    
    # Create web client and request the JSON output
    $webClient = New-Object -TypeName System.Net.WebClient
    $rawOutput = $webClient.DownloadString($JSONUri)
    
    # Trim the JSON and make it easier for me to parse
    $rawObject = $rawOutput.trim().trim('{','}').replace(',"',';').replace('":','=').replace('"','').split(';')

    # Dynamically build output object properties hashtable
    $props = @{}
    foreach ($prop in $rawObject) {
        # Split the key=value pair
        $key = $prop.Split('=')[0]
        $value = $prop.Split('=')[1]
        if ($TitleCase) {
            # Convert key name to Title (or Camel) case
            $key = (Get-Culture).TextInfo.ToTitleCase($key.ToLower())
        }
        # Add the current property to the hashtable
        $props.Add($key, $value)
    }
    # Create the object and write it out
    $obj = New-Object -TypeName PSObject -Property $props
    Write-Output -InputObject $obj
}

# And here's it in use:
Get-SimpleJSON -JSONUri www.telize.com/geoip | Select-Object longitude, latitude, continent_code, country_code3 | Format-Table -AutoSize

# Or as a one-liner for PowerShell v3+:
ConvertFrom-Json -InputObject (Invoke-WebRequest -Uri www.telize.com/geoip).Content | Select-Object longitude, latitude, continent_code, country_code3 | Format-Table -AutoSize