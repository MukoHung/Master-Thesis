function Find-KeePassconfig {
<#
    .SYNOPSIS

        Finds and parses any KeePass.config.xml (2.X) and KeePass.ini (1.X) files.

        Author: @harmj0y
        License: BSD 3-Clause
        Required Dependencies: None
        Optional Dependencies: None

    .DESCRIPTION

        This function searches for any KeePass.config.xml (KeePass 2.X) and KeePass.ini (1.X) files in C:\Users\
        and C:\Program Files[x86]\ by default, or any path specified by -Path. For any files found, it will 
        parse the XML and output information relevant to the database location and keyfile/user master key information.

    .PARAMETER Path

        Optional path to a KeePass.config.xml/KeePass.ini file or specific folder to search for KeePass config files.

    .EXAMPLE

        PS C:\> Find-KeePassconfig

        DefaultDatabasePath    : C:\Users\testuser\Desktop\Database2.kdb
        SecureDesktop          :
        LastUsedFile           : C:\Users\testuser\Desktop\Database3.kdb
        DefaultKeyFilePath     : C:\Users\testuser\Desktop\k.bin
        DefaultUserAccountData :
        RecentlyUsed           : {C:\Users\testuser\Desktop\Database3.kdb, C:\Users\testuser\Desktop\k2.bin}
        KeePassConfigPath      : C:\Users\testuser\Desktop\blah\KeePass-1.31\KeePass.ini

        DefaultDatabasePath    : C:\Users\testuser\Desktop\NewDatabase.kdbx
        SecureDesktop          : False
        LastUsedFile           : C:\Users\testuser\Desktop\NewDatabase.kdbx
        DefaultKeyFilePath     : C:\Users\testuser\Desktop\blah\KeePass-2.34\KeePass.chm
        DefaultUserAccountData : @{UserDomain=TESTLAB; UserKeePassDPAPIBlob=C:\Users\testuser\AppData\Roaming\KeePass\Protected
                                 UserKey.bin; UserSid=S-1-5-21-456218688-4216621462-1491369290-1210; UserName=testuser; UserMas
                                 terKeyFiles=System.Object[]}
        RecentlyUsed           : {C:\Users\testuser\Desktop\NewDatabase.kdbx}
        KeePassConfigPath      : C:\Users\testuser\Desktop\blah\KeePass-2.34\KeePass.config.xml
#>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateScript({Test-Path -Path $_ })]
        [Alias('FullName')]
        [String[]]
        $Path
    )

    BEGIN {

        function local:Get-IniContent {
        <#
            .SYNOPSIS

                This helper parses an .ini file into a proper PowerShell object.

                Author: 'The Scripting Guys'
                Link: https://blogs.technet.microsoft.com/heyscriptingguy/2011/08/20/use-powershell-to-work-with-any-ini-file/

            .LINK

                https://blogs.technet.microsoft.com/heyscriptingguy/2011/08/20/use-powershell-to-work-with-any-ini-file/
        #>
            [CmdletBinding()]
            Param(
                [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
                [Alias('FullName')]
                [ValidateScript({ Test-Path -Path $_ })]
                [String[]]
                $Path
            )

            PROCESS {
                ForEach($TargetPath in $Path) {
                    $IniObject = @{}
                    Switch -Regex -File $TargetPath {
                        "^\[(.+)\]" # Section
                        {
                            $Section = $matches[1].Trim()
                            $IniObject[$Section] = @{}
                            $CommentCount = 0
                        }
                        "^(;.*)$" # Comment
                        {
                            $Value = $matches[1].Trim()
                            $CommentCount = $CommentCount + 1
                            $Name = 'Comment' + $CommentCount
                            $IniObject[$Section][$Name] = $Value
                        }
                        "(.+?)\s*=(.*)" # Key
                        {
                            $Name, $Value = $matches[1..2]
                            $Name = $Name.Trim()
                            $Values = $Value.split(',') | ForEach-Object {$_.Trim()}
                            if($Values -isnot [System.Array]) {$Values = @($Values)}
                            $IniObject[$Section][$Name] = $Values
                        }
                    }
                    $IniObject
                }
            }
        }

        function Local:Get-KeePassINIFields {
            # helper that parses a 1.X KeePass.ini into a custom object
            [CmdletBinding()]
            Param (
                [Parameter(Mandatory=$True)]
                [ValidateScript({ Test-Path -Path $_ })]
                [String]
                $Path
            )

            $KeePassINIPath = Resolve-Path -Path $Path
            $KeePassINIPathParent = $KeePassINIPath | Split-Path -Parent
            $KeePassINI = Get-IniContent -Path $KeePassINIPath
            $RecentlyUsed = @()

            try {
                if($KeePassINI.KeePass.KeeLastDb) {
                    $LastUsedFile = Resolve-Path -Path "$KeePassINIPathParent\$($KeePassINI.KeePass.KeeLastDb)" -ErrorAction Stop
                }
            }
            catch {}

            try {
                if($KeePassINI.KeePass.KeeKeySourceID0) {
                    $DefaultDatabasePath = Resolve-Path -Path $KeePassINI.KeePass.KeeKeySourceID0 -ErrorAction SilentlyContinue
                }
            }
            catch {}

            try {
                if($KeePassINI.KeePass.KeeKeySourceValue0) {
                    $DefaultKeyFilePath = Resolve-Path -Path $KeePassINI.KeePass.KeeKeySourceValue0 -ErrorAction SilentlyContinue
                }
            }
            catch {}

            # grab any additional cached databases/key information
            $KeePassINI.KeePass.Keys | Where-Object {$_ -match 'KeeKeySourceID[1-9]+'} | Foreach-Object {
                try {
                    $ID = $_[-1]
                    $RecentlyUsed += $KeePassINI.Keepass["KeeKeySourceID${ID}"]
                    $RecentlyUsed += $KeePassINI.Keepass["KeeKeySourceValue${ID}"]
                }
                catch{}
            }

            $KeePassINIProperties = @{
                'KeePassConfigPath' = $KeePassINIPath
                'SecureDesktop' = $Null
                'LastUsedFile' = $LastUsedFile
                'RecentlyUsed' = $RecentlyUsed
                'DefaultDatabasePath' = $DefaultDatabasePath
                'DefaultKeyFilePath' = $DefaultKeyFilePath
                'DefaultUserAccountData' = $Null
            }
            $KeePassINIInfo = New-Object -TypeName PSObject -Property $KeePassINIProperties
            $KeePassINIInfo.PSObject.TypeNames.Insert(0, 'KeePass.Config')
            $KeePassINIInfo
        }

        function Local:Get-KeePassXMLFields {
            # helper that parses a 2.X KeePass.config.xml into a custom object
            [CmdletBinding()]
            Param (
                [Parameter(Mandatory=$True)]
                [ValidateScript({ Test-Path -Path $_ })]
                [String]
                $Path
            )

            $KeePassXMLPath = Resolve-Path -Path $Path
            $KeePassXMLPathParent = $KeePassXMLPath | Split-Path -Parent
            [Xml]$KeePassXML = Get-Content -Path $KeePassXMLPath

            $LastUsedFile = ''
            $RecentlyUsed = @()
            $DefaultDatabasePath = ''
            $DefaultKeyFilePath = ''
            $DefaultUserAccountData = $Null

            if($KeePassXML.Configuration.Application.LastUsedFile) {
                $LastUsedFile = Resolve-Path -Path "$KeePassXMLPathParent\$($KeePassXML.Configuration.Application.LastUsedFile.Path)" -ErrorAction SilentlyContinue
            }

            if($KeePassXML.Configuration.Application.MostRecentlyUsed.Items) {
                $KeePassXML.Configuration.Application.MostRecentlyUsed.Items | Foreach-Object {
                    Resolve-Path -Path "$KeePassXMLPathParent\$($_.ConnectionInfo.Path)" -ErrorAction SilentlyContinue | Foreach-Object {
                        $RecentlyUsed += $_
                    }
                }
            }

            if($KeePassXML.Configuration.Defaults.KeySources.Association.DatabasePath) {
                $DefaultDatabasePath = Resolve-Path -Path "$KeePassXMLPathParent\$($KeePassXML.Configuration.Defaults.KeySources.Association.DatabasePath)" -ErrorAction SilentlyContinue
            }

            if($KeePassXML.Configuration.Defaults.KeySources.Association.KeyFilePath) {
                $DefaultKeyFilePath = Resolve-Path -Path "$KeePassXMLPathParent\$($KeePassXML.Configuration.Defaults.KeySources.Association.KeyFilePath)" -ErrorAction SilentlyContinue
            }

            $DefaultUserAccount = $KeePassXML.Configuration.Defaults.KeySources.Association.UserAccount -eq 'true'

            $SecureDesktop = $KeePassXML.Configuration.Security.MasterKeyOnSecureDesktop -eq 'true'

            if($DefaultUserAccount) {

                $UserPath = $Path.Split('\')[0..2] -join '\'

                $UserMasterKeyFolder = Get-ChildItem -Path "$UserPath\AppData\Roaming\Microsoft\Protect\" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

                if($UserMasterKeyFolder) {

                    $UserSid = $UserMasterKeyFolder | Split-Path -Leaf

                    try {
                        $UserSidObject = (New-Object System.Security.Principal.SecurityIdentifier($UserSid))
                        $UserNameDomain = $UserSidObject.Translate([System.Security.Principal.NTAccount]).Value

                        $UserDomain, $UserName = $UserNameDomain.Split('\')
                    }
                    catch {
                        Write-Warning "Unable to translate SID from $UserMasterKeyFolder , defaulting to user name"
                        $UserName = $UserPath.Split('\')[-1]
                        $UserDomain = $Null
                    }

                    $UserMasterKeyFiles = @(, $(Get-ChildItem -Path $UserMasterKeyFolder -Force | Select-Object -ExpandProperty FullName) )
                }
                else {
                    $UserSid = $Null
                    $UserName = $Null
                    $UserDomain = $Null
                }

                $UserKeePassDPAPIBlob = Get-Item -Path "$UserPath\AppData\Roaming\KeePass\ProtectedUserKey.bin" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

                $UserMasterKeyProperties = @{
                    'UserSid' = $UserSid
                    'UserName' = $UserName
                    'UserDomain' = $UserDomain
                    'UserKeePassDPAPIBlob' = $UserKeePassDPAPIBlob
                    'UserMasterKeyFiles' = $UserMasterKeyFiles
                }
                $DefaultUserAccountData = New-Object -TypeName PSObject -Property $UserMasterKeyProperties
            }

            $KeePassXmlProperties = @{
                'KeePassConfigPath' = $KeePassXMLPath
                'SecureDesktop' = $SecureDesktop
                'LastUsedFile' = $LastUsedFile
                'RecentlyUsed' = $RecentlyUsed
                'DefaultDatabasePath' = $DefaultDatabasePath
                'DefaultKeyFilePath' = $DefaultKeyFilePath
                'DefaultUserAccountData' = $DefaultUserAccountData
            }
            $KeePassXmlInfo = New-Object -TypeName PSObject -Property $KeePassXmlProperties
            $KeePassXmlInfo.PSObject.TypeNames.Insert(0, 'KeePass.Config')
            $KeePassXmlInfo
        }
    }

    PROCESS {
        if($PSBoundParameters['Path']) {
            $XmlFilePaths = $Path
        }
        else {
            # possible locations for KeePass configs
            $XmlFilePaths = @("$($Env:WinDir | Split-Path -Qualifier)\Users\")
            $XmlFilePaths += "${env:ProgramFiles(x86)}\"
            $XmlFilePaths += "${env:ProgramFiles}\"
        }

        $XmlFilePaths | Foreach-Object { Get-ChildItem -Path $_ -Recurse -Include @('KeePass.config.xml', 'KeePass.ini') -ErrorAction SilentlyContinue } | Where-Object { $_ } | Foreach-Object {
            Write-Verbose "Parsing KeePass config file '$($_.Fullname)'"

            if($_.Extension -eq '.xml') {
                Get-KeePassXMLFields -Path $_.Fullname
            }
            else {
                Get-KeePassINIFields -Path $_.Fullname
            }
        }
    }
}
