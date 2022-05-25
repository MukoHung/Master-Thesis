#----------------------------------------------------#
# Decrypts password using Certificate
#----------------------------------------------------#
function Get-DecryptedPassword
{
	[CmdletBinding()]
	param
	(
		$EncryptedPassword,
		$EncryptedKey,
		$Thumbprint,
		$AdminUsername
	)

	$ErrorActionPreference = 'Stop'

	if (Get-ChildItem Cert:\LocalMachine\My\$thumbprint)
	{
		try
		{
			$cert = Get-Item -Path Cert:\LocalMachine\My\$thumbprint -ErrorAction Stop
			$key = $cert.PrivateKey.Decrypt(([Convert]::FromBase64String($encryptedKey)), $true)
			$secureString = $encryptedPassword | ConvertTo-SecureString -Key $key
			$adminCredential = New-Object System.Management.Automation.PSCredential($AdminUsername, $secureString)
		}
		catch
		{
			Write-Warning "Failure decrypting key.`nError:$_"
			$adminCredential = $null
		}
	} 
	else
	{
		Write-Warning "Certificate needed for password decryption not found.`nError:$_"
		$adminCredential = $null
	}

	return $adminCredential
}

function Get-EncryptedString
{
	[CmdletBinding()]
	param
	(
		[string]$EncryptedString,
		[string]$EncryptedKey,
		[string]$Thumbprint
	)

	if (Get-ChildItem Cert:\LocalMachine\My\$Thumbprint)
	{
		try
		{
			$cert = Get-Item -Path Cert:\LocalMachine\My\$Thumbprint -ErrorAction Stop
			$key = $cert.PrivateKey.Decrypt(([Convert]::FromBase64String($EncryptedKey)), $true)
			$secureString = $EncryptedString | ConvertTo-SecureString -Key $key
            $plainText = (New-Object System.Management.Automation.PSCredential 'N/A', $secureString).GetNetworkCredential().Password
		}
		catch
		{
			Write-Host "Failure decrypting key. Terminating script."
		}
	} 
	else
	{
		Write-Host "Certificate needed for string decryption not found. Terminating script."
	}

	return $plainText
}

#----------------------------------------------------#
# String Encryption Script 
#----------------------------------------------------#
function New-EncryptedString
{
	<# Params for encryption against a new certificate that needs to be created.
	$params = @{
		StringToEncrypt = 'String Goes Here'
		CertSubject = 'Subject Name'
		CertKeyLength = 2048
		CertHashAlgorithm = 'SHA256'
		CertKeyExportPolicy = '1'
		CertExpirationInYears = 30
		CertStoreLocation = 'Cert:\LocalMachine\My'
		CertKeyUsage = 'KeyEncipherment'
		CertKeyUsageProperty = 'All'
		CertKeySpec = 'KeyExchange'
		OutputLocation = "$env:USERPROFILE"
		FileName = 'EncryptionInfo.csv'
	}
	#

	# Params for encryption against existing certificate
	$params = @{
		StringToEncrypt = 'String Goes Here'
		CertStoreLocation = 'Cert:\LocalMachine\My'
		CertThumbprint = 'Thumbprint goes here'
		OutputLocation = "$env:USERPROFILE"
		FileName = 'EncryptionInfo.csv'
	}

	New-EncryptedString @params
	#>
	[CmdletBinding(DefaultParameterSetName='Existing')]
	param
	(
		#NewCert ParameterSet
		[parameter(Mandatory=$false,ParameterSetName='New')]
		[switch]$CertAddServerAuth,

		[parameter(Mandatory=$false,ParameterSetName='New')]
		[switch]$CertAddClientAuth,

		[parameter(Mandatory=$false,ParameterSetName='New')]
		[switch]$CertAddSmartCardAuth,

		[parameter(Mandatory=$false,ParameterSetName='New')]
		[switch]$CertAddEncryptedFileSystem,

		[parameter(Mandatory=$false,ParameterSetName='New')]
		[switch]$CertAddCodeSigning,

		[parameter(Mandatory=$true,ParameterSetName='New')]
		$CertSubject,

		[parameter(Mandatory=$false,ParameterSetName='New')]
		$CertKeyLength,

		[parameter(Mandatory=$false,ParameterSetName='New')]
		$CertHashAlgorithm,

		[parameter(Mandatory=$false,ParameterSetName='New')]
		$CertKeyExportPolicy,

		[parameter(Mandatory=$false,ParameterSetName='New')]
		$CertExpirationInYears,

		#Existing Cert ParameterSet
		[parameter(Mandatory=$true,ParameterSetName='Existing')]
		$StringToEncrypt,

		[parameter(Mandatory=$true,ParameterSetName='Existing')]
		$CertStoreLocation,

		[parameter(Mandatory=$true,ParameterSetName='Existing')]
		$CertThumbprint,

		#Shared Params
		[parameter(Mandatory=$true,ParameterSetName='New')]
		[parameter(Mandatory=$true,ParameterSetName='Existing')]
		$OutputLocation,

		[parameter(Mandatory=$true,ParameterSetName='New')]
		[parameter(Mandatory=$true,ParameterSetName='Existing')]
		$FileName

	)

	function New-SelfSignedCert
	{
		[CmdletBinding()]
		param
		(
			[ValidateSet("Personal", "LocalMachine")]
			[string]$CertificateStore = "LocalMachine",

			[string]$CertificateSubject,

			[ValidateSet("SHA256", "SHA1")]
			[string]$SignatureAlgorithm = "SHA256",

			[int]$CertificateExpirationInYears = 30,

			[int]$CertificateLength = 2048,

			<# 
			For CertificateExportable
			0 = No private key export
			1 = Private key can be exported
			2 = Private key can be exported in plaintext
			4 = Private key can be exported once for archiving
			8 = Private key can be exported once in plaintext for archiving
			#>
			[ValidateSet(0,1,2,4,8)]
			[int]$CertificateExportable = 1, 

			[switch]$AddServerAuth,
  
			[switch]$AddClientAuth,
  
			[switch]$AddSmartCardAuth,
  
			[switch]$AddEncryptedFileSystem,
  
			[switch]$AddCodeSigning
		)

		$ErrorActionPreference = "Stop" 
  
		#----------------------------------------------------#
		# Checks to make certain PowerShell is running as Administrator
		#----------------------------------------------------#
		if ((([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) -eq $false) {
			Write-Host "The PowerShell session is not running as an administrator. Exiting script in 10 seconds."
			Start-Sleep -Seconds 10
			Exit
		}

		If ($CertificateStore -eq "Personal")
		{
			$machineContext = 0
			$initContext = 1
		}
		ElseIF ($CertificateStore -eq "LocalMachine")
		{
			$machineContext = 1
			$initContext = 2
		}
  
		$name = New-Object -com "X509Enrollment.CX500DistinguishedName.1" 
  
		$name.Encode("CN=$CertificateSubject", 0)
  
		$key = New-Object -com "X509Enrollment.CX509PrivateKey.1" 
  
		$key.ProviderName = "Microsoft RSA SChannel Cryptographic Provider" 
  
		$key.KeySpec = 1
  
		$key.Length = $CertificateLength
  
		$key.SecurityDescriptor = "D:PAI(A;;0xd01f01ff;;;SY)(A;;0xd01f01ff;;;BA)(A;;0x80120089;;;NS)" 
  
		$key.MachineContext = $machineContext
  
		$key.ExportPolicy = $CertificateExportable
  
		$key.Create()
  
		$ekuoids = New-Object -com "X509Enrollment.CObjectIds.1" 
  
		If ($AddServerAuth -eq $true)
		{
			$serverauthoid = New-Object -com "X509Enrollment.CObjectId.1" 
  
			$serverauthoid.InitializeFromValue("1.3.6.1.5.5.7.3.1")
  
			$ekuoids.add($serverauthoid)
		}
  
		If ($AddClientAuth -eq $true)
		{
			$clientauthoid = New-Object -com "X509Enrollment.CObjectId.1" 
  
			$clientauthoid.InitializeFromValue("1.3.6.1.5.5.7.3.2")
  
			$ekuoids.add($clientauthoid)
		}
  
		If ($AddSmartCardAuth -eq $true)
		{
			$smartcardoid = New-Object -com "X509Enrollment.CObjectId.1" 
  
			$smartcardoid.InitializeFromValue("1.3.6.1.4.1.311.20.2.2")
  
			$ekuoids.add($smartcardoid)
		}
  
		If ($AddEncryptedFileSystem -eq $true)
		{
			$efsoid = New-Object -com "X509Enrollment.CObjectId.1" 
  
			$efsoid.InitializeFromValue("1.3.6.1.4.1.311.10.3.4")
  
			$ekuoids.add($efsoid)
		}
  
		If ($AddCodeSigning -eq $true)
		{
			$codesigningoid = New-Object -com "X509Enrollment.CObjectId.1" 
  
			$codesigningoid.InitializeFromValue("1.3.6.1.5.5.7.3.3")
  
			$ekuoids.add($codesigningoid)
		}
	
		$SigOID = New-Object -ComObject X509Enrollment.CObjectId

		$SigOID.InitializeFromValue(([Security.Cryptography.Oid]$SignatureAlgorithm).Value)

		$ekuext = New-Object -ComObject "X509Enrollment.CX509ExtensionEnhancedKeyUsage.1"
  
		$ekuext.InitializeEncode($ekuoids)
  
		$cert = New-Object -ComObject "X509Enrollment.CX509CertificateRequestCertificate.1" 
  
		$cert.InitializeFromPrivateKey($initContext, $key, "")
  
		$cert.Subject = $name 
  
		$cert.Issuer = $cert.Subject
  
		$cert.NotBefore = Get-Date 
  
		$cert.NotAfter = $cert.NotBefore.AddYears($CertificateExpirationInYears)
  
		$cert.X509Extensions.Add($ekuext)

		$cert.SignatureInformation.HashAlgorithm = $SigOID
  
		$cert.Encode()
  
		$enrollment = New-Object -ComObject "X509Enrollment.CX509Enrollment.1" 
  
		$enrollment.InitializeFromRequest($cert)
  
		$certdata = $enrollment.CreateRequest(0)
  
		$enrollment.InstallResponse(2, $certdata, 0, "")
  
		Write-Host "`nFinished" -ForegroundColor Green

		Return (Get-ChildItem Cert:\$CertificateStore\My | Where {$_.Subject -eq "CN=$CertificateSubject"}).Thumbprint
	}

	Function Encrypt-Asymmetric
	{
		[CmdletBinding()]
		[OutputType([System.String])]
		param(
			[Parameter(Position=0, Mandatory=$true)][ValidateNotNullOrEmpty()][System.String]
			$ClearText,
			[Parameter(Position=1, Mandatory=$true)][ValidateNotNullOrEmpty()][ValidateScript({Test-Path $_ -PathType Leaf})][System.String]
			$PublicCertFilePath
		)

		$secureString = $ClearText | ConvertTo-SecureString -AsPlainText -Force
		$PublicCert = Get-Item -Path $PublicCertFilePath -ErrorAction Stop

		$key = New-Object byte[](32)
		$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()

		$rng.GetBytes($key)

		$encryptedString = ConvertFrom-SecureString -SecureString $secureString -Key $key
		$EncryptedByteArray = $PublicCert.PublicKey.Key.Encrypt($key,$true)

		$encryptedInfo = [PSCustomObject]@{
			"EncryptedString" = $encryptedString
			"EncryptedKeyInBase64" = $EncryptedByteArray
			"Thumbprint" = $PublicCert.Thumbprint
		}
 
		Return $encryptedInfo
	}

	if ($PSCmdlet.ParameterSetName -eq "New") {
		$newCertificateParams = @{
			CertificateStore = $CertStoreLocation
			CertificateSubject = $CertSubject
			SignatureAlgorithm = $CertHashAlgorithm
			CertificateExpirationInYears = $CertExpirationInYears
			CertificateLength = $CertKeyLength
			CertificateExportable = $CertKeyExportPolicy
		}

		if ($CertAddServerAuth)
		{
			$newCertificateParams += @{AddServerAuth = $true}
		}

		if ($CertAddClientAuth)
		{
			$newCertificateParams += @{AddClientAuth = $true}
		}

		if ($CertAddSmartCardAuth)
		{
			$newCertificateParams += @{AddSmartCardAuth = $true}
		}

		if ($CertAddEncryptedFileSystem)
		{
			$newCertificateParams += @{AddEncryptedFileSystem = $true}
		}

		if ($CertAddCodeSigning)
		{
			$newCertificateParams += @{AddCodeSigning = $true}
		}

		$newCertificate = New-SelfSignedCert @newCertificateParams
	} elseif ($PSCmdlet.ParameterSetName -eq "Existing") {
		$newCertificate = Get-ChildItem $CertStoreLocation\$CertThumbprint
	}

	$StringInfo = Encrypt-Asymmetric -ClearText $StringToEncrypt -PublicCertFilePath "$CertStoreLocation\$($newCertificate.Thumbprint)" 

	$StringOutput = [PSCustomObject]@{
		EncryptedKeyInBase64 = [Convert]::ToBase64String($StringInfo.EncryptedKeyInBase64) # byte array to base64 string
		EncryptedString = $StringInfo.EncryptedString
		Thumbprint = $StringInfo.Thumbprint
	} 

	$StringOutput | Export-Csv $OutputLocation\$FileName -NoTypeInformation

	Invoke-Item $OutputLocation\$FileName
}

function Remove-CertPrivateKey
{
	[CmdletBinding()]
	param
	(
		$CertificateThumbprint,
		$CertificateLocation = 'LocalMachine'
	)

	$cert = dir Cert:\LocalMachine\My\$CertificateThumbprint

	if ($cert.hasprivatekey -eq $true) {
	    $bytes = $cert.Export('Cert')

	    $store = New-Object system.security.cryptography.x509certificates.x509Store 'My', "$CertificateLocation"
	    $store.Open('ReadWrite')
	    $store.Remove($cert)

	    $container = New-Object system.security.cryptography.x509certificates.x509certificate2collection
	    $container.Import($bytes)
	    $store.Add($container[0])

	    $store.close()
	}
}