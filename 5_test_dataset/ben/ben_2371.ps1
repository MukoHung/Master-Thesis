$VerbosePreference = "SilentlyContinue"
$ErrorActionPreference= 'silentlycontinue'

Function Get-IniContent 
{ 
    <# 
    .Synopsis 
        Gets the content of an INI file 
         
    .Description 
        Gets the content of an INI file and returns it as a hashtable 
         
    .Notes 
        Author    : Oliver Lipkau <oliver@lipkau.net> 
        Blog      : http://oliver.lipkau.net/blog/ 
        Date      : 2014/06/23 
        Version   : 1.1 
         
        #Requires -Version 2.0 
         
    .Inputs 
        System.String 
         
    .Outputs 
        System.Collections.Hashtable 
         
    .Parameter FilePath 
        Specifies the path to the input file. 
         
    .Example 
        $FileContent = Get-IniContent "C:\myinifile.ini" 
        ----------- 
        Description 
        Saves the content of the c:\myinifile.ini in a hashtable called $FileContent 
     
    .Example 
        $inifilepath | $FileContent = Get-IniContent 
        ----------- 
        Description 
        Gets the content of the ini file passed through the pipe into a hashtable called $FileContent 
     
    .Example 
        C:\PS>$FileContent = Get-IniContent "c:\settings.ini" 
        C:\PS>$FileContent["Section"]["Key"] 
        ----------- 
        Description 
        Returns the key "Key" of the section "Section" from the C:\settings.ini file 
         
    .Link 
        Out-IniFile 
    #> 
     
    [CmdletBinding()] 
    Param( 
        [ValidateNotNullOrEmpty()] 
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})] 
        [Parameter(ValueFromPipeline=$True,Mandatory=$True)] 
        [string]$FilePath 
    ) 
     
    Begin 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"} 
         
    Process 
    { 
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Processing file: $Filepath" 
             
        $ini = @{} 
        switch -regex -file $FilePath 
        { 
            "^\[(.+)\]$" # Section 
            { 
                $section = $matches[1] 
                $ini[$section] = @{} 
                $CommentCount = 0 
            } 
            "^(;.*)$" # Comment 
            { 
                if (!($section)) 
                { 
                    $section = "No-Section" 
                    $ini[$section] = @{} 
                } 
                $value = $matches[1] 
                $CommentCount = $CommentCount + 1 
                $name = "Comment" + $CommentCount 
                $ini[$section][$name] = $value 
            }  
            "(.+?)\s*=\s*(.*)" # Key 
            { 
                if (!($section)) 
                { 
                    $section = "No-Section" 
                    $ini[$section] = @{} 
                } 
                $name,$value = $matches[1..2] 
                $ini[$section][$name] = $value 
            } 
        } 
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Finished Processing file: $path" 
        Return $ini 
    } 
         
    End 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"} 
}


Function Get-BattlEyeGUID ([string]$steamID64)
{
Try
{
$beBytes = [System.Text.Encoding]::ASCII.GetBytes("BE")
$idBytes = [System.BitConverter]::GetBytes([Int64]::Parse($steamID64))
 
$sb = New-Object System.Text.StringBuilder
$md5 = New-Object System.Security.Cryptography.MD5CryptoServiceProvider
$md5.ComputeHash($beBytes + $idBytes) | %{ [void] $sb.Append($_.ToString("x2")) }
 
Return $sb.ToString()
}
Catch
{
Return ""
}
}



Set-Location F:\Server1\db

$filter='Bankmoney="'
$query = (dir -include *.ini -recurse  |  select-string $filter )
$files = $query.Path | Get-Unique

#loop for the sql-script
Foreach ($file in $files)
{

$iniconent = Get-IniContent $file
$uid = $iniconent["Playerinfo"]["UID"].Replace("`"","")
$name = $iniconent["Playerinfo"][“Name”].Replace("`"","")
$name2= '\"'+$name+'\"'
$bankmoney = 0
[int]$bankmoney = ($iniconent["Playerinfo"][“BankMoney”]).Replace("`"","")
$cmoney = 0
[int]$cmoney = ($iniconent["PlayerSave"][“Money”]).Replace("`"","")
$fullmoney = $bankmoney + $cmoney
$Beguid = Get-BattlEyeGUID $uid
$Beguid2 = '\"'+$Beguid+'\"'


if ($fullmoney -gt 10000) {

#INSERT INTO `PlayerInfo` VALUES ('76561197964070402','\"Torndeco\"','WEST',0,'\"9d5a2241429129715f8b262f8fddb2e9\"');
"INSERT INTO `PlayerInfo` VALUES ('$uid','$name2','WEST',$fullmoney,'$Beguid2');" | Out-File D:\wiking\user-import-final.sql -Append
#"UPDATE `PlayerInfo` SET BattlEyeGUID = '$Beguid2' WHERE UID ='$UID';" | Out-File D:\wiking\update-beguid.sql -Append
}

}