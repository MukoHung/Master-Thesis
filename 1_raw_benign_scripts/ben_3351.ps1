function Restore-UserDPAPI {
<#
    .SYNOPSIS

        Restores a user account's DPAPI master key on a new system.

        Author: @harmj0y
        License: BSD 3-Clause
        Required Dependencies: None
        Optional Dependencies: None
    
    .DESCRIPTION

        This function will take a backup of a user's DPAPI master key folder (C:\Users\<username>\AppData\Roaming\Microsoft\Protect\<SID>\),
        copies the folder to %APPDATA%\Microsoft\Protect\ for the current user on a new machine, sets several
        DPAPI MigratedUsers registry keys necessary, and invokes dpapimig.exe to kick off "Protected Content Migration".
        If the password for the user account associated with the master key differs from the current user's,
        the "Protected Content Migration" GUI will prompt for the old user password.

        There is more information on this process from KeePass at https://sourceforge.net/p/keepass/wiki/Recover%20Windows%20User%20Account%20Credentials/

    .PARAMETER Path

        The C:\Users\<username>\AppData\Roaming\Microsoft\Protect\<SID>\ folder to restore, must be in S-1-... SID format.

    .PARAMETER UserName

        The username linked to the folder to restore.

    .PARAMETER UserDomain

        The domain (or local machine) linked to the UserName/folder.
    
    .PARAMETER ProtectedUserKey

        The path to an optional ProtectedUserKey.bin KeePass DPAPI blob.

    .EXAMPLE

        PS C:\Temp> Restore-UserDPAPI -Path C:\Temp\S-1-5-21-456218688-4216621462-1491369290-1210\ -UserName testuser -UserDomain testlab.local

        Restores the DPAPI master key for the testlab.local\testuser (SID=S-1-5-21-456218688-4216621462-1491369290-1210) from
        the C:\Temp\S-1-5-21-456218688-4216621462-1491369290-1210\ backup folder.

    .EXAMPLE

        PS C:\Temp> Restore-UserDPAPI -Path C:\Temp\S-1-5-21-456218688-4216621462-1491369290-1210\ -UserName testuser -UserDomain testlab.local -ProtectedUserKey ProtectedUserKey.bin

        Restores the DPAPI master key for the testlab.local\testuser (SID=S-1-5-21-456218688-4216621462-1491369290-1210) from
        the C:\Temp\S-1-5-21-456218688-4216621462-1491369290-1210\ backup folder, and copies the KeePass-specific
        ProtectedUserKey.bin DPAPI blob into the proper location.

    .LINK

        https://sourceforge.net/p/keepass/wiki/Recover%20Windows%20User%20Account%20Credentials/

#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [ValidateScript({ Test-Path -Path $_ })]
        [String]
        $Path,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]
        $UserName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]
        $UserDomain,

        [ValidatePattern('.*ProtectedUserKey\.bin')]
        [ValidateScript({ Test-Path -Path $_ })]
        [Alias('KeePassBlob')]
        [String]
        $ProtectedUserKey
    )

    $UserFolder = Get-Item $Path
    $SID = $UserFolder.Name
    
    if($SID -notmatch '^S-1-.*') {
        throw "User folder must be in 'S-1-...' SID format!"
    }

    Write-Host "`n[*] Copying $($UserFolder.FullName) DPAPI folder to $ENV:APPDATA\Microsoft\Protect\"
    Copy-Item -Path $UserFolder -Destination $ENV:APPDATA\Microsoft\Protect\ -Recurse -Force

    Write-Host "`n[*] Creating DPAPI MigratedUsers registry keys"
    $Null = New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DPAPI\MigratedUsers\$SID\UserDomain" -Force
    $Null = New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DPAPI\MigratedUsers\$SID\UserDomain" -Name $UserDomain -Force

    $Null = New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DPAPI\MigratedUsers\$SID\UserName" -Force
    $Null = New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DPAPI\MigratedUsers\$SID\UserName" -Name $UserName -Force

    Write-Host "`n[*] Calling dpapimig.exe... (this may take just a bit)`n"
    Start-Process $ENV:WINDIR\System32\dpapimig.exe -NoNewWindow -Wait

    if($PSBoundParameters['ProtectedUserKey']) {
        $ProtectedUserKeyFile = Get-Item $ProtectedUserKey
        Write-Host "[*] Copying $($ProtectedUserKeyFile.FullName) to $ENV:APPDATA\KeePass\`n"
        if (-not (Test-Path -Path $ENV:APPDATA\KeePass\)) { $Null = New-Item $ENV:APPDATA\KeePass\ -Type Directory }
        Copy-Item -Path $ProtectedUserKeyFile -Destination $ENV:APPDATA\KeePass\ -Force
    }
}
