<#
.SYNOPSIS
    VC Build analysis.
.DESCRIPTION
    VC Build analysis.
.EXAMPLE
    C:\PS>bldperf.ps1 -start
    [...Build from msvc...]
    C:\PS>bldperf.ps1 -stop -timetrace -compilescore -cppbldanalyze
.NOTES
    Author: ikrima
    Date:   September 11, 2020
#>

[CmdletBinding()]

param(
  #start vcperf trace capture
  [switch]$start,
  #stop vcperf trace capture
  [switch]$stop,
  #Runs vcperf time trace [https://devblogs.microsoft.com/cppblog/introducing-vcperf-timetrace-for-cpp-build-time-analysis/]
  [switch]$timetrace,
  #Runs CppBuildAnalyzer on vcperf trace [https://github.com/MetanoKid/cpp-build-analyzer]
  [switch]$cppbldanalyze,
  #Runs CompileScorer on vcperf trace [https://github.com/Viladoman/CompileScore]
  [switch]$compilescore,
  #Output directory for analysis files
  [ValidateScript({if ($_){  Test-Path $_}})]
  [string]$outdir = "$PSScriptRoot\..\..\.bin-int\bldperf",
  #Tools directory containing vcperf.exe, ScoreDataExtractor.exe, CppBuildAnalyzer.exe
  [ValidateScript({if ($_){  Test-Path $_}})]
  [string]$tooldir = "$PSScriptRoot\..\..\tools\bldperf",
  #Output directory for analysis files
  [string]$seshname = "tolva"
)

$ErrorActionPreference = "Stop"

if ( $PSBoundParameters.Values.Count -eq 0 -and $args.count -eq 0 ) {
  Get-Help $MyInvocation.MyCommand.Definition -detailed
  return
}
$tooldir         = (Resolve-Path $tooldir).Path
$outdir          = (Resolve-Path $outdir).Path
$vcperfExe       = "$tooldir\vcperf.exe"
$compilescoreExe = "$tooldir\ScoreDataExtractor.exe"
$cppbldanalExe   = "$tooldir\CppBuildAnalyzer.exe"
$etlrawFile      = "$outdir\vcperf_raw_$seshname.etl"
$cmplScoreFile   = "$outdir\compileData.scor"
$timetrcFile     = "$outdir\vcperf_timetrc_$seshname.json"

Set-ExecutionPolicy Bypass -Scope Process -Force

if ($start) {
  $cmd = @($vcperfExe, '/start', '/level3 ', $seshname)
  Write-host "Starting vcperf trace capture:" -ForegroundColor Green -NoNewline
  Write-host "  $cmd" -ForegroundColor DarkCyan
  gsudo cache on
  gsudo $cmd
  # Start-Process powershell @('-command', '&', $vcperfExe, '/start', '/level3 ', $seshname, '*>', "$outdir\vcperfscriptlog.txt") -Wait -Verb RunAs
  # Get-Content "$outdir\vcperfscriptlog.txt"
}
elseif ($stop) {
  $cmd = @($vcperfExe, '/stopnoanalyze', $seshname, $etlrawFile)
  Write-host "Stopping vcperf trace capture:" -ForegroundColor Green -NoNewline
  Write-host "  $cmd" -ForegroundColor DarkCyan
  gsudo $cmd
  # Start-Process powershell @('-command', '&', $vcperfExe, '/stopnoanalyze', $seshname, $etlrawFile, '*>', "$outdir\vcperfscriptlog.txt") -Wait -Verb RunAs
  # Get-Content "$outdir\vcperfscriptlog.txt"
}


Switch ($PSBoundParameters.GetEnumerator().
  Where({$_.Value -eq $true}).Key)
{
  'timetrace' {
    $cmd = @($vcperfExe,'/analyze','/templates', $etlrawFile, '/timetrace', $timetrcFile)
    Write-host "Running vcperf timetrace:" -ForegroundColor Green -NoNewline
    Write-host "  $cmd" -ForegroundColor DarkCyan
    gsudo $cmd
  }
  'cppbldanalyze' {
    $cmd = @('-i', $etlrawFile, '--analyze_all')
    Write-host "Running CppBuildAnalyzer:" -ForegroundColor Green -NoNewline
    Write-host "  $cppbldanalExe $cmd" -ForegroundColor DarkCyan
    Push-Location -Path $outdir
    & $cppbldanalExe $cmd
    Pop-Location
  }
  'compilescore' {
    $cmd = @('-msvc', '-i', $etlrawFile, '-o', $cmplScoreFile, '-v', '2')
    Write-host "Running CompileScorer:" -ForegroundColor Green -NoNewline
    Write-host "  $compilescoreExe $cmd" -ForegroundColor DarkCyan
    Push-Location -Path $outdir
    & $compilescoreExe $cmd
    Write-host ""
    Pop-Location
  }
}