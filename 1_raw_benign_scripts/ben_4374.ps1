# UpdateDDNS.ps1 
# Update Dynamic DNS on Namecheap.com via HTTP GET request.
Param(
	[parameter(Mandatory=$true)]
	[alias("c")]
	$ConfigFile)

# Parse the content of an INI file, return a hash with values.
# Source: Artem Tikhomirov. http://stackoverflow.com/a/422529
Function Parse-IniFile ($file) {
	$ini = @{}
	switch -regex -file $file {
		"^\s*([^#].+?)\s*=\s*\`"*(.*?)\`"*$" {
			$name,$value = $matches[1..2]
			$ini[$name] = $value.Trim()
		}
	}
	$ini
}

# Write a message to log.
function Log-Message ($MSG) {
	$script:Logger += "$(get-date -format u) $MSG`n"
	Write-Output $MSG
}

# Write an error to log.
function Log-Error ($MSG) {
	$script:Logger += "$(get-date -format u) ERROR`: $MSG`n"
	Write-Error "ERROR`: $MSG"
}

# Write contents of log to file.
function Flush-Log {
	$file = "ddnsupdate.log"
	Write-Output $script:Logger | Out-File $file
}

# Send an email with the contents of the log buffer.
# SMTP configuration and credentials are in the configuration dictionary.
function Email-Log ($config, $message) {
	$EmailFrom        = $config["EmailFrom"]
	$EmailTo          = $config["EmailTo"]
	$EmailSubject     = "DDNS log $(get-date -format u)"  
	  
	$SMTPServer       = $config["SMTPServer"]
	$SMTPPort         = $config["SMTPPort"]
	$SMTPAuthUsername = $config["SMTPAuthUsername"]
	$SMTPAuthPassword = $config["SMTPAuthPassword"]

	$mailmessage = New-Object System.Net.Mail.MailMessage 
	$mailmessage.From = $EmailFrom
	$mailmessage.To.Add($EmailTo)
	$mailmessage.Subject = $EmailSubject
	$mailmessage.Body = $message

	$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $SMTPPort) 
	$SMTPClient.EnableSsl = $true 
	$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("$SMTPAuthUsername", "$SMTPAuthPassword") 
	$SMTPClient.Send($mailmessage)
}

function Get-WebClient ($config) {
	$client = New-Object System.Net.WebClient
	if ($config["ProxyEnabled"]) {
		$ProxyAddress  = $config["ProxyAddress"]
		$ProxyPort     = $config["ProxyPort"]
		$ProxyDomain   = $config["ProxyDomain"]
		$ProxyUser     = $config["ProxyUser"]
		$ProxyPassword = $config["ProxyPassword"]
		$proxy         = New-Object System.Net.WebProxy
		$proxy.Address = $ProxyAddress
		if ($ProxyPort -and $ProxyPort -ne 80) {
			$proxy.Address = "$ProxyAddress`:$ProxyPort"
		} else {
			$proxy.Address = $ProxyAddress
		}
		$account = New-Object System.Net.NetworkCredential($ProxyUser, $ProxyPassword, $ProxyDomain)
		$proxy.Credentials = $account
		$client.Proxy = $proxy
		
	}
	$client
}

try {
	$Logger = ""
	
	Log-Message "Dynamic DNS Update Client"

	# Check if a config file exists.
	Log-Message "Looking for a configuration file: $ConfigFile"
	if (!(Test-Path -path $ConfigFile)) {
		Log-Error "A valid configuration file could not be found"
		exit 1
	}
	# Load configuration:
	Log-Message "Parsing $ConfigFile"
	$config = Parse-IniFile ($ConfigFile)
	if ($config.Count -eq 0) {
		Log-Error "The file $ConfigFile didn't have any valid settings"
		exit 2
	}
	# Create a new web client
	$client = Get-WebClient($config)

	# Get current public IP address
	Log-Message "Retrieving the current public IP address"
	$Pattern   = '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
	$CurrentIp = $client.DownloadString('http://myip.dnsomatic.com/')
	Log-Message "Retrieving stored IP address"
	$StoredIp  = [Environment]::GetEnvironmentVariable("PUBLIC_IP","User")
	if (!($CurrentIp -match $Pattern)) {
		Log-Error "A valid public IP address could not be retrieved"
		exit 3
	}
	Log-Message "Stored IP: [$StoredIp] Retrieved IP: [$CurrentIp]"
	# Compare current IP address with environment variable.	   
	if ($StoredIp -eq $CurrentIp ) {
		Log-Message "Nothing to see here."
		exit 0
	}
	
	Log-Message "Updating IP address on domain registrar"
	#https://dynamicdns.park-your-domain.com/update?host=SUBDOMAIN&amp;domain=YOURDOMAIN&amp;password=0123456789ABCDEF&amp;ip=$CurrentIp
	$DDNSSubdomain = $config["DDNSSubdomain"]
	$DDNSDomain    = $config["DDNSDomain"]
	$DDNSPassword  = $config["DDNSPassword"]
	$UpdateUrl     = "https://dynamicdns.park-your-domain.com/update?host=$DDNSSubdomain&amp;domain=$DDNSDomain&amp;password=$DDNSPassword&amp;ip=$CurrentIp"
	$UpdateDDNS    = $client.DownloadString($UpdateUrl)
	Log-Message "$UpdateDDNS"
	Log-Message "DDNS Updated at namecheap.com"
	[Environment]::SetEnvironmentVariable("PUBLIC_IP", $CurrentIp, "User")
	Log-Message "Environment variable set: $CurrentIp"
	Email-Log $config $Logger
	Log-Message "Email sent"
}
catch [System.Exception] {
	Log-Error $_.Exception.Message
	exit 5
}
finally {
	Flush-Log
}
