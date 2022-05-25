<#
.SYNOPSIS
a SYNOPSIS

.DESCRIPTION    
a description

.PARAMETER OptionalParam1
a parameter

.PARAMETER RequiredParam2
another parameter

.PARAMETER IntParam3
another parameter

.EXAMPLE
an example
#>

param
(
    [string]$OptionalParam1 = "https://test.example.com",
    [Parameter(Mandatory=$true)][string]$RequiredParam2,
    [int]$IntParam3 = 100
)

try
{

}
catch
{
    Write-Host "Error running test. $_";
    exit -1;
}
exit 0;