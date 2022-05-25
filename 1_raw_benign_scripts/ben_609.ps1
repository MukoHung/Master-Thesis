# Originally from http://www.adminarsenal.com/admin-arsenal-blog/powershell-silently-change-firefox-default-search-providers-for-us

$Provider = "Google"
# Default valid provider options: 
#   Amazon.com, Bing, DuckDuckGo, eBay, Google, Twitter, Wikipedia (en), Yahoo

# This disclaimer is required verbatim...
$Disclaimer = "By modifying this file, I agree that I am doing so only "
$Disclaimer += "within Firefox itself, using official, user-driven search "
$Disclaimer += "engine selection processes, and in a way which does not "
$Disclaimer += "circumvent user consent. I acknowledge that any attempt "
$Disclaimer += "to change this file from outside of Firefox is a malicious "
$Disclaimer += "act, and will be responded to accordingly."


$Pattern    = "{`"\[global\]`"\:{`"current`"\:`"(.*)`",`"hash`"\:`"(.*)`"}}"
$Encoding   = [System.Text.Encoding]::UTF8
$Hasher     = New-Object ([System.Security.Cryptography.SHA256]::Create())

Get-ChildItem "$env:public\..\*\AppData\Roaming\Mozilla\Firefox\Profiles\*" | 
    Where-Object { $_.PSIsContainer } | ForEach-Object {

    $ByteData   = $Encoding.GetBytes($_.Name + $Provider + $disclaimer)
    $HashResult = $Hasher.ComputeHash($ByteData)
    $Result     = [System.Convert]::ToBase64String($HashResult)
    $File = "$($_.FullName)\search-metadata.json"
    $Data = "{`"[global]`":{`"current`":`"$Provider`",`"hash`":`"$Result`"}}"

    If (-Not (Test-Path $File)) {New-Item -Path $File -ItemType file}

    (Get-Content $File) | Foreach-Object {
        If ($_ | Select-String -Pattern $Pattern) { 
            $_ -replace $Pattern, $Data
        } Else {
            $data 
        } 
    } | Out-File $File -Encoding utf8

    If ((Get-Content $File) -eq $Null) {
        $Data  | Out-File $File -Encoding utf8
    }
}