# Get-DirStats.ps1
# Written by Bill Stewart (bstewart@iname.com)

#requires -version 2

# PowerShell wrapper script for the SysInternals du.exe command:
# https://docs.microsoft.com/en-us/sysinternals/downloads/du
# Why? Object output for sorting, filtering, calculating totals, etc.
#
# Version history:
# 1.0 (2019-09-23)
# * Initial version.

<#
.SYNOPSIS
Outputs file system directory statistics using the SysInternals du.exe (or du64.exe) command.

.DESCRIPTION
Outputs file system directory statistics using the SysInternals du.exe (or du64.exe) command. The du.exe (or du64.exe) file must reside in the Path. The 64-bit version of du.exe (du64.exe) is recommended on 64-bit operating system versions.

.PARAMETER Path
Specifies a path to one or more file system directories. Wildcards are permitted. The default path is the current directory.

.PARAMETER CountHardlinks
Counts each instance of hardlinked files.

.PARAMETER FormatNumbers
Formats numbers in the output object to include thousands separators. (Note that this causes the numeric properties in the output objects to become strings.)

.PARAMETER Levels
Specifies the number of directory levels (directory depth) to include in the output. The default is 1.

.PARAMETER NoRecurse
Specifies not to recurse into subdirectories.

.PARAMETER OutputSubdirs
Specifies to output each subdirectory in the output.

.OUTPUTS
PSObjects with the following properties:
  Path                 String
  CurrentFileCount     UInt32
  CurrentFileSize      UInt32
  FileCount            UInt32
  DirectoryCount       UInt32
  DirectorySize        UInt32
  DirectorySizeOnDisk  UInt32
If you specify -FormatNumbers, the UInt32 properties will be String instead.

.LINK
https://docs.microsoft.com/en-us/sysinternals/downloads/du
#>

[CmdletBinding(DefaultParameterSetName = "None")]
param(
  [Parameter(Position = 0,ValueFromPipeline = $true)]
  [String[]] $Path,

  [Switch] $FormatNumbers,

  [Switch] $CountHardlinks,

  [Parameter(ParameterSetName = "Levels")]
  [UInt32] $Levels = 1,

  [Parameter(ParameterSetName = "NoRecurse")]
  [Switch] $NoRecurse,

  [Parameter(ParameterSetName = "OutputSubdirs")]
  [Switch] $ShowSubdirs
)

begin {
  function Find-DU {
    if ( [Environment]::Is64BitProcess ) {
      $commandPath = (Get-Command 'du64.exe' -ErrorAction SilentlyContinue).Path
      if ( -not $commandPath ) {
        $commandPath = (Get-Command 'du.exe' -ErrorAction SilentlyContinue).Path
      }
      if ( -not $commandPath ) {
        throw "Could not find the Sysinternals 'du64.exe' or 'du.exe' command in the Path. Download it, copy it to a directory in your Path, and try again."
      }
    }
    else {
      $commandPath = (Get-Command 'du.exe' -ErrorAction SilentlyContinue).Path
      if ( -not $commandPath ) {
        throw "Could not find the Sysinternals 'du.exe' command in the Path. Download it, copy it to a directory in your Path, and try again."
      }
    }
    if ( (Get-Item $commandPath).VersionInfo.CompanyName -notmatch 'SysInternals' ) {
      throw "The file '$commandPath' is not the SysInternals version. Download it, copy it to a directory in your Path, and try again."
    }
    if ( [Environment]::Is64BitProcess -and ((Split-Path $commandPath -Leaf) -eq 'du.exe') ) {
      Write-Warning "Found the SysInternals 'du.exe' command in the Path, but it may not be the 64-bit version. Recommend using the 64-bit version ('du64.exe') on 64-bit operating systems."
    }
    $commandPath
  }

  $CommandPath = Find-DU

  # Assume current file system location if -Path not specified
  if ( -not $Path ) {
    $Path = $ExecutionContext.SessionState.Path.CurrentFileSystemLocation.Path
  }

  function Format-Output {
    process {
      $_ | Select-Object Path,
        @{Name = "CurrentFileCount";    Expression = {'{0:N0}' -f $_.CurrentFileCount}},
        @{Name = "CurrentFileSize";     Expression = {'{0:N0}' -f $_.CurrentFileSize}},
        @{Name = "FileCount";           Expression = {'{0:N0}' -f $_.FileCount}},
        @{Name = "DirectoryCount";      Expression = {'{0:N0}' -f $_.DirectoryCount}},
        @{Name = "DirectorySize";       Expression = {'{0:N0}' -f $_.DirectorySize}},
        @{Name = "DirectorySizeOnDisk"; Expression = {'{0:N0}' -f $_.DirectorySizeOnDisk}}
    }
  }

  function Get-DirStats {
    param(
      [String] $path
    )
    $commandArgs = '-accepteula','-nobanner','-c'
    switch ( $PSCmdlet.ParameterSetName ) {
      "Levels" {
        $commandArgs += '-l'
        $commandArgs += '{0}' -f $Levels
      }
      "NoRecurse" {
        $commandArgs += '-n'
      }
      "OutputSubdirs" {
        $commandArgs += '-v'
      }
    }
    if ( $CountHardlinks ) {
      $commandArgs += '-u'
    }
    $commandArgs += $path
    & $CommandPath $commandArgs | ConvertFrom-Csv | Select-Object Path,
      @{Name = "CurrentFileCount";    Expression = {$_.CurrentFileCount -as [UInt32]}},
      @{Name = "CurrentFileSize";     Expression = {$_.CurrentFileSize -as [UInt32]}},
      @{Name = "FileCount";           Expression = {$_.FileCount -as [UInt32]}},
      @{Name = "DirectoryCount";      Expression = {$_.DirectoryCount -as [UInt32]}},
      @{Name = "DirectorySize";       Expression = {$_.DirectorySize -as [UInt32]}},
      @{Name = "DirectorySizeOnDisk"; Expression = {$_.DirectorySizeOnDisk -as [UInt32]}}
  }
}

process {
  foreach ( $PathItem in $Path ) {
    if ( -not $FormatNumbers ) {
      Get-DirStats $PathItem
    }
    else {
      Get-DirStats $PathItem | Format-Output
    }
  }
}
