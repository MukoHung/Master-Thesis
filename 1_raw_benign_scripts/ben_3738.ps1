Add-Type -OutputAssembly hello.exe -TypeDefinition @'
using System;

public class Hello {
    public static void Main(string[] Args) {
        System.Console.WriteLine("Hello, world!");
        System.Console.Read();
    }
}
'@

$FromTheInternet = @'
[ZoneTransfer]
ZoneId=3
ReferrerUrl=https://www.probablyevil.com/
HostUrl=https://www.probablyevil.com/hello.exe
'@

# Simulate hello.exe having originated from the Internet Zone.
Set-Content -Path hello.exe -Stream Zone.Identifier -Value $FromTheInternet

# Copy hello.exe into the FeelTheBurn directory. An ISO will be created from this directory.
mkdir FeelTheBurn
cp .\hello.exe .\FeelTheBurn\

# Simulate FeelTheBurn.iso having originated from the Internet Zone.
Set-Content -Path FeelTheBurn.iso -Stream Zone.Identifier -Value $FromTheInternet

# Validate that both files originated from the Internet Zone
Get-Content -Path .\hello.exe -Stream Zone.Identifier
Get-Content -Path .\FeelTheBurn\hello.exe -Stream Zone.Identifier

# Create an ISO file from the FeelTheBurn directory.
# New-IsoFile from: https://github.com/wikijm/PowerShell-AdminScripts/blob/master/Miscellaneous/New-IsoFile.ps1
ls .\FeelTheBurn\ | New-IsoFile -Path FeelTheBurn.iso -Media CDR -Title TestIso

# Simulate double-clicking the ISO and mount it.
$null = Mount-DiskImage -ImagePath "$PWD\FeelTheBurn.iso" -StorageType ISO -Access ReadOnly

# Observe that hello.exe, once mounted, no longer originates from the Internet Zone.
Get-Content -Path E:\hello.exe -Stream Zone.Identifier
