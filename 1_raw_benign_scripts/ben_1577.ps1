<#
.SYNOPSIS

Reports if your password is pwned by querying haveibeenpwned.com

.DESCRIPTION

Query haveibeenpwned.com to see if a password has appeared in a breach.

The query sends the first 5 characters of the SHA1 hash, so the query should be considered safe and anonymous.

If you pass no parameters, you are prompted for the password to check and the password is not echoed to the screen.

.PARAMETER password_notsecure

Pass a plaintext password. This option is for convenience, but not recommended.
If used with real passwords, clear your history and transcripts after use.

.PARAMETER password_secure

Pass a SecureString password, e.g. read from a file.

.EXAMPLE

PS> Get-AmIPwned.ps1
Password to check: : ******

Pwned    Seen Hash
-----    ---- ----
 True 2670319 6367c48dd193d56ea7b0baad25b19455e529f5ee

.EXAMPLE

PS> 'P@ssw0rd', 'P@assw0rd', 'adsfadfsasdfadsadsf','abc123','password' | Get-AmIPwned.ps1

Pwned    Seen Hash
-----    ---- ----
 True   47205 21bd12dc183f740ee76f27b78eb39c8ad972a757
 True      39 630aab54f57ad2af22e2479b071bc1b47d09d1b0
False       0 f59b862b64a1043869acee3997841106d4ec01d5
 True 2670319 6367c48dd193d56ea7b0baad25b19455e529f5ee
 True 3303003 5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8

#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline)]
    [string]
    $password_notsecure,

    [Parameter(ValueFromPipeline)]
    [SecureString]
    $password_secure
)

begin
{
    class PwnedPasswordResult {
        [bool]$Pwned
        [int]$Seen
        [string]$Hash
    }

    $sha1 = [System.Security.Cryptography.SHA1CryptoServiceProvider]::new()
    $secProtocol = [System.Net.ServicePointManager]::SecurityProtocol
    $ProgressPreference = 'Ignore'
}

process
{
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = "tls, tls11, tls12"

        if (!$password_secure -and !$password_notsecure) {
            $password_secure = Read-Host -AsSecureString -Prompt 'Password to check: '
        }

        if (!$password_notsecure) {
            $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password_secure)
            $password_notsecure = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
            $bstr = $null
        }

        $password_bytes = [System.Text.Encoding]::ASCII.GetBytes($password_notsecure)
        $password_notsecure = $null

        $password_hash = ($sha1.ComputeHash($password_bytes) | % { $_.ToString("x2") }) -join ''
        $password_bytes = $null

        $prefix = $password_hash.Substring(0,5)
        $suffix = $password_hash.Substring(5)
        $range = (iwr "https://api.pwnedpasswords.com/range/$prefix").Content
        if ($range -match "${suffix}:(\d+)")
        {
            $pwned = $true
            $hits = $matches[1]
        }
        else
        {
            $pwned = $false
            $hits = 0
        }

        [PwnedPasswordResult]@{
            Pwned = $pwned
            Seen = $hits
            Hash = $password_hash
        }
    } finally {
        [System.Net.ServicePointManager]::SecurityProtocol = $secProtocol
    }
}
