<#PSScriptInfo

.VERSION 1.3.0

.GUID 5a516eab-0001-4f39-82f9-f12d189bf98d

.AUTHOR Olivier Jullien

.COMPANYNAME

.COPYRIGHT MIT License

.TAGS

.LICENSEURI https://github.com/ojullien/powershell/blob/master/LICENSE

.PROJECTURI https://github.com/ojullien/PowerShell

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS sys/Writer,app/saveto

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Date: 20180620
Require Powershell Version: 6.0.2
Require .NET Framework 4.7
Require .NET Core

#>

<#

.DESCRIPTION
 Save data to external disk

#>
[CmdletBinding()]
Param(
    [switch] $bequiet,
    [switch] $logtofile,
    [switch] $waituser,
    [Parameter(Mandatory=$True,Position=1)]
    [ValidateNotNullOrEmpty()]
    [string] $cfg = 'default'
)

Set-StrictMode -Version Latest

# -----------------------------------------------------------------------------
#  Script options
# -----------------------------------------------------------------------------
New-Variable -Name m_OPTION_WAIT -Force -Option Constant,AllScope -Value $( if( $waituser.IsPresent ) {1} else {0} )

# -----------------------------------------------------------------------------
# Load common sys files
# -----------------------------------------------------------------------------

. ("$PWD\..\src\sys\cfg\constant.ps1")
. ("$m_DIR_SYS\inc\Writer\autoload.ps1")

# -----------------------------------------------------------------------------
# Load sys\Filter files
# -----------------------------------------------------------------------------

. ("$m_DIR_SYS\inc\Filter\autoload.ps1")

# -----------------------------------------------------------------------------
# Load sys\Drive files
# -----------------------------------------------------------------------------

. ("$m_DIR_SYS\inc\Drive\Drive.ps1")

# -----------------------------------------------------------------------------
# Load sys\Executable files
# -----------------------------------------------------------------------------

. ("$m_DIR_SYS\inc\Exec\Program.ps1")
. ("$m_DIR_SYS\inc\Exec\Adapter\Interface.ps1")
. ("$m_DIR_SYS\inc\Exec\Adapter\Abstract.ps1")
. ("$m_DIR_SYS\inc\Exec\Adapter\SystemDiagnosticsProcess.ps1")
. ("$m_DIR_SYS\inc\Exec\Robocopy.ps1")
. ("$m_DIR_SYS\inc\Exec\Contig.ps1")

# -----------------------------------------------------------------------------
# Load sys config
# -----------------------------------------------------------------------------

. ("$m_DIR_SYS\cfg\main.ps1")

# -----------------------------------------------------------------------------
# Load app files and config
# -----------------------------------------------------------------------------

$sCfgPath = "$m_DIR_APP\saveto\cfg\$cfg.cfg.ps1"
if( ! [File]::new().exists( [Path]::new( $sCfgPath ))) {
    $pWriter.error( "$sCfgPath is missing! Aborting ..." )
    Exit
} else {
    . ($sCfgPath)
}
. ("$m_DIR_APP\saveto\cfg\SaveTo.ps1")
. ("$m_DIR_APP\saveto\inc\SaveTo.ps1")

# -----------------------------------------------------------------------------
#  Save to
# -----------------------------------------------------------------------------

if( -not $appConfirmed ) {
    Exit
}

# Creates Adaptater
try {
    [SystemDiagnosticsProcess] $pAdapter = [SystemDiagnosticsProcess]::new()
} catch {
    $pWriter.error( "Exception raised while creating Exec\Adapter\SystemDiagnosticsProcess:  $_" )
    Exit
}

# Create SaveTo
try {
    [SaveTo] $pSaveTo = [SaveTo]::new( $pAdapter, [Path]::new( 'C:\Temp' ) )
} catch {
    $pWriter.error( "Exception raised while creating SaveTo:  $_" )
    Exit
}

foreach( $item in $appDrivesCollection ) {

    $pWriter.separateLine()

    # Set source and destination
    try {
        $null = $pSaveTo.setSource( [Path]::new( $item.theSource ), $item.theSourceLabel )
        $null = $pSaveTo.setDestination( [Path]::new( $item.theDestination ), $item.theDestinationLabel )
    } catch {
        $pWriter.error( "Exception raised while setting source or destination:  $_" )
        Exit
    }

    # Trace
    $pWriter.notice( [string]$pSaveTo )

    # Robocopy
    try {
        $pWriter.noticel( 'Start robocopy ... ' )
        $null = $pAdapter.noOutput()
        $bRun = $pSaveTo.robocopy()
    } catch {
        $pWriter.error( "Exception raised while robocopying:  $_" )
        Exit
    }

    if( $bRun ) {
        $pWriter.success( "Exit code: $( $pSaveTo.error.code )" )
    } else {
        $pWriter.error( "Exit code:  $( $pSaveTo.error.code )" )
    }

    # Contig
    try {
        $pWriter.noticel( 'Start contig ... ' )
        $null = $pAdapter.saveOutput()
        $bRun = $pSaveTo.contig()
    } catch {
        $pWriter.error( "Exception raised while contigering:  $_" )
        Exit
    }

    if( $bRun ) {
        $pWriter.success( "Exit code: $( $pSaveTo.error.code )" )
    } else {
        $pWriter.error( "Exit code:  $( $pSaveTo.error.code )" )
    }

}

$pSaveTo = $null
$pAdapter = $null

Set-StrictMode -Off
