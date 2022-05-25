Function Encode-Script
{
	Param(
		[Parameter(Position = 0, Mandatory = $True)]
		[String]
		$Data,
			
		[Parameter(Position = 1, Mandatory = $True)]
		[String]
		$Key
	)
	
	$stub = @'
function Expand-Script($Key) 
{

	$script = '**ScRiPtGoEsHeRe**'

	$Key = $Key.PadRight(32,'X')
	
	$encBytes = [System.Convert]::FromBase64String($script)
	
	if($encBytes.Length -gt 32){
	
		# extract the IV
		$IV = $encBytes[0..15];
		$AES = New-Object System.Security.Cryptography.AesCryptoServiceProvider;
		$AES.Mode = "CBC";
		$AES.Key = [system.Text.Encoding]::UTF8.GetBytes($key);
		$AES.IV = $IV;
		$CompressedData = [System.Text.Encoding]::UTF8.GetString(($AES.CreateDecryptor()).TransformFinalBlock(($encBytes[16..$encBytes.length]), 0, $encBytes.Length-16))
		return $(New-Object IO.StreamReader ($(New-Object IO.Compression.DeflateStream ($(New-Object IO.MemoryStream (,$([Convert]::FromBase64String($CompressedData)))), [IO.Compression.CompressionMode]::Decompress)), [Text.Encoding]::ASCII)).ReadToEnd()
	}
}
'@
	
	$ms = New-Object IO.MemoryStream
	$action = [IO.Compression.CompressionMode]::Compress
	$cs = New-Object IO.Compression.DeflateStream ($ms,$action)
	$sw = New-Object IO.StreamWriter ($cs, [Text.Encoding]::ASCII)
	$Data | ForEach-Object {$sw.WriteLine($_)}
	$sw.Close()
    
	# Base64 encode stream
	$Data = [Convert]::ToBase64String($ms.ToArray())
	
	$Key = $Key.PadRight(32,'X')
		
	# Make Byte Array
	$bytes = $([system.Text.Encoding]::UTF8.GetBytes($Data))
		
	# get a random IV
	$IV = [byte] 0..255 | Get-Random -count 16
	$AES = New-Object System.Security.Cryptography.AesCryptoServiceProvider
	$AES.Mode = "CBC"
	$AES.Key = [system.Text.Encoding]::UTF8.GetBytes($Key)
	$AES.IV = $IV
	$ciphertext = $IV + ($AES.CreateEncryptor()).TransformFinalBlock($bytes, 0, $bytes.Length)
		
	$encryptedData = [Convert]::ToBase64String($ciphertext)
	
	$stub = $stub.replace('**ScRiPtGoEsHeRe**',$encryptedData)
	return $stub
}