<#
.SYNOPSIS
Uninstall one or more Windows Program or Feature, by name or regular expression.

.DESCRIPTION

Lists Programs And Features installed on the current machine which match 
the -matchingName parameter and then, after force or confirmation, uninstalls them.

Examples
Uninstall-Programs-Or-Features SpyWare
Uninstall-Programs-Or-Features "Net Core SDK - 2.1.(1|2|3)"

.PARAMETER matchingName 

A regular expression, for instance spyware or "Redistributable \(x64\) - 1(0|1|2)\."
Use quotation marks if it's complicated.

.PARAMETER force

If -force is $true, then uninstallation will proceed without further prompting. 
Otherwise, a Y/N prompt will be required, after first showing the list of expected uninstallations

.PARAMETER msiexecParameters

If specified, these parameters are passed to msiexec. 
The default is "/q" for no user interaction if the current process has Adminstrator rights, 
or "/qb" if not.

.EXAMPLE
Uninstall-Programs-Or-Features SpyWare

.EXAMPLE 
Uninstall-Programs-Or-Features "Net Core SDK - 2.1.(1|2|3)"

.NOTES
Uninstallation is done one-by-one in series, calling msiexec for each item.
#>

Param(
  [Parameter(Mandatory=$true)][ValidateLength(3,9999)][string] $MatchingName,
  [string] $msiexecParameters="/q",
  [switch] $force
  )

#------------------------------------------------------
  function confirmYN( 
      [string]$YesCharacters="Y", 
      [string]$NoCharacters="N", 
      [string]$prompt= "Yes or No?", 
      [string]$promptOnFail="Please choose one of Yes or No" )
  {
    $yesPattern= [string]::Join("|",  $YesCharacters.ToCharArray())
    $noPattern = [string]::Join("|",  $NoCharacters.ToCharArray())
    $validCharsPattern= [string]::Join("|", $yesPattern,$noPattern )
    while( -not ( ($choice= (Read-Host $prompt )) -match $validCharsPattern ) ){ write-warning $promptOnFail }
    return $choice -match $yesPattern -and -not ($choice -match $NoPattern)
  }

  function amIAdmin
  {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
              IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")
  }
#------------------------------------------------------

  if($msiexecParameters -eq "/q" -and -not (amIAdmin)){
    write-warning "msiexec /q only works in an elevated console with Adminstrator rights. Using msiexec /qb instead."
    $msiexecParameters="/qb"
  }

  $Path32="HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
  $Path64="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
  $Path32PsPath=
    "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
  $Path64PsPath=
    "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
  $uninstalls32 = gci $Path32 | % { get-ItemProperty $_.PSPath } | where { $_ -match $MatchingName } 
  $uninstalls64 = gci $Path64 | % { get-ItemProperty $_.PSPath } | where { $_ -match $MatchingName } 

  $lines= $( $uninstalls64 + $uninstalls32 | %{ 
                $(if($_.UninstallString -match "^msiexec(\.| )" ){
                  $_.UninstallString.Replace("/I","/X").Replace("/X{",'/X "{').Replace("}",'}"')  + " $msiexecParameters"
                }else{
                  $_.UninstallString
                })
            })

  if( $lines -is [String]){ $lines = @($lines)}

  # --- display a lot before continuing-----------

  $uninstalls64 | Format-Table -Property DisplayName, Readme, InstallDate, 
                                  @{Label="Guid"; Expression= { $($_.PSPath.Replace($Path64PsPath,"")) } }
  if($uninstalls32.Length -gt 0){
    "Wow6432Node Versions"
    $uninstalls32 | Format-Table -Property DisplayName, Readme, 
                      @{Label="Guid"; Expression= { $($_.PSPath.Replace($Path32PsPath,"")) } }
  }





  # --- Do it if confirmed or forced -----------

  if($uninstalls64.Length -eq 0 -and $uninstalls32.Length -eq 0){

    "Nothing to do."

  }elseif( $force -or ($youchose= confirmYN -prompt "Continue with uninstall? (Yes or No)" ) ){

    "You chose: $youchose"
     $lines | %{ 
      "$_  ... "
      & cmd.exe /C "$_"
    }

  }else{

    "Nothing uninstalled."

  }
