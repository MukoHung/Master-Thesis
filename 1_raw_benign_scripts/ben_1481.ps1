<#PSScriptInfo

.VERSION 1.3.0

.GUID 969dc39f-0001-4e61-9cfd-8e8df7ebebf6

.AUTHOR Olivier Jullien

.COMPANYNAME

.COPYRIGHT MIT License

.TAGS

.LICENSEURI https://github.com/ojullien/powershell/blob/master/LICENSE

.PROJECTURI https://github.com/ojullien/PowerShell

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS src\sys\inc\Writer\autoload.ps1, test\sys\inc\Filter\Path.ps1, test\sys\inc\Filter\Dir.ps1, test\sys\inc\Filter\File.ps1

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Date: 20180620
Require Powershell Version: 6.0.2
Require .NET Framework 4.7
Require .NET Core

#>

<#

.DESCRIPTION
 Filter\Dir tests

#>

Param(
    [switch] $verbose,
    [switch] $bequiet,
    [switch] $logtofile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'

# -----------------------------------------------------------------------------
# Load common sys files
# -----------------------------------------------------------------------------

. ("$PWD\..\src\sys\cfg\constant.ps1")
. ("$m_DIR_SCRIPT\test\sys\cfg\constant.ps1")
. ("$m_DIR_SYS\inc\Writer\autoload.ps1")

# -----------------------------------------------------------------------------
# Load Filter files
# -----------------------------------------------------------------------------

. ("$m_DIR_SYS\inc\Filter\FilterAbstract.ps1")

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------

. ("$m_DIR_TEST_SYS\inc\Filter\Path.ps1")
. ("$m_DIR_TEST_SYS\inc\Filter\File.ps1")
. ("$m_DIR_TEST_SYS\inc\Filter\Dir.ps1")

$ErrorActionPreference = "Continue"

Set-StrictMode -Off
