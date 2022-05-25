Param([parameter(Mandatory=$true,
   HelpMessage="Directory to search for .NET Assemblies in.")]
   $Directory,
   [parameter(Mandatory=$false,
   HelpMessage="Whether or not to search recursively.")]
   [switch]$Recurse = $false,
   [parameter(Mandatory=$false,
   HelpMessage="Whether or not to include DLLs in the search.")]
   [switch]$DLLs = $false,
   [parameter(Mandatory=$false,
   HelpMessage="Whether or not to include all files in the search.")]
   [switch]$All = $false)

if($All)
{
    Get-ChildItem -Path $Directory -Recurse:$Recurse -ErrorAction SilentlyContinue -Force  | % { try {$asn = [System.Reflection.AssemblyName]::GetAssemblyName($_.fullname); $_.fullname} catch {} }
}
else
{
    Get-ChildItem -Path $Directory -Filter *.exe -Recurse:$Recurse -ErrorAction SilentlyContinue -Force  | % { try {$asn = [System.Reflection.AssemblyName]::GetAssemblyName($_.fullname); $_.fullname} catch {} }

    if ($DLLs)
    {
        Get-ChildItem -Path $Directory -Filter *.dll -Recurse:$Recurse -ErrorAction SilentlyContinue -Force  | % { try {$asn = [System.Reflection.AssemblyName]::GetAssemblyName($_.fullname); $_.fullname} catch {} }
    }
}