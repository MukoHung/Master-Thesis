function Import-Portatour {
    param (
        [parameter(Mandatory=$True,Position=1)] [ValidateScript({ Test-Path -PathType Leaf $_ })] [String] $FilePath,
        [parameter(Mandatory=$False,Position=2)] [System.URI] $ResultURL
    )
	
	# CONST 
	$CODEPAGE = "iso-8859-1" # alternatives are ASCII, UTF-8 
	# We have a REST-Endpoint
	$RESTURL = "https://my.portatour.net/a/api/ImportCustomers/"
	
	# Testing
	$userEmail = "some.user@example.org"
	
	# Read file byte-by-byte
  $fileBin = [System.IO.File]::ReadAllBytes($FilePath)

  # Convert byte-array to string
	$enc = [System.Text.Encoding]::GetEncoding($CODEPAGE)
	
	$fileEnc = $enc.GetString($fileBin)
	# Read a second hardcoded file which we want to upload through the API call
	$importConfigFileEnc = $enc.GetString([System.IO.File]::ReadAllBytes("C:\Users\xyz\Documents\WindowsPowerShell\portatour.importcfg"))
	
	# Create Object for Credentials
	$user = "Username"
  $pass = "Passw0rd"
	
	$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)

	# We need a boundary (something random() will do best)
  $boundary = [System.Guid]::NewGuid().ToString()
	
	# Linefeed character
  $LF = "`r`n"
	
	# Build up URI for the API-call
	$uri = $RESTURL + "?userEmail=$userEmail&mode=UpdateOrInsert"
	
	# Build Body for our form-data manually since PS does not support multipart/form-data out of the box
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"Import.xlsx`"",
		"Content-Type: application/octet-stream$LF",
        $fileEnc,
        "--$boundary",
        "Content-Disposition: form-data; name=`"importConfig`"; filename=`"portatour.importcfg`"",
		"Content-Type: application/octet-stream$LF",
        $importConfigFileEnc,
        "--$boundary--$LF"
     ) -join $LF
	
    try {
        # Submit form-data with Invoke-RestMethod-Cmdlet
        Invoke-RestMethod -Uri $uri -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines -Credential $cred
    }
    # In case of emergency...
    catch [System.Net.WebException] {
        Write-Error( "REST-API-Call failed for '$URL': $_" )
        throw $_
    }
}
