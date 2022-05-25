#
# A tool to roll up all the commands available in the solution
#

# USAGE:
#
#  .\tool <assemble | run | compile> (-quiet) Filename
#
#
#  Examples:
#  .\tool.ps1 assemble .\Asm\sum-two-ints-register-based.asm
#       Assemble .\Asm\sum-two-ints-register-based.asm to .\Asm\sum-two-ints-register-based.bin (and .sym)
#  .\tool.ps1 run .\Asm\sum-two-ints-register-based.bin
#       Run the code in the emulator bin file .\Asm\sum-two-ints-register-based.bin
#  .\tool.ps1 compile .\Asm\average-numbers.p
#       Compile the pascalish file .\Asm\average-numbers.p and produce .\Asm\average-numbers.asm
#
#  .\tool.ps1 assemble -quiet -filename .\Asm\sum-two-ints-register-based.asm
#       Assemble .\Asm\sum-two-ints-register-based.asm to .\Asm\sum-two-ints-register-based.bin (and .sym)
#   
param (
    # the command to run (assemble, compile or run)
    [Parameter(Mandatory=$true)]
    [string]$Command,

    # gthe file name
    [Parameter(Mandatory=$true)]
    [string]$Filename,

    # quiet mode (or verbose if not present)
    [switch]$Quiet
)


$DotNet = "dotnet.exe"
$AssemblerFolder = ".\Assembler"
$EmulatorFolder = ".\Emulator"
$CompilerFolder = ".\Compiler"

$ExecutableSubFolder="bin\Debug\net6.0"

$Assembler = "$AssemblerFolder\$ExecutableSubFolder\Assembler.exe"
$Emulator = "$EmulatorFolder\$ExecutableSubFolder\Emulator.exe"
$Compiler = "$CompilerFolder\$ExecutableSubFolder\Compiler.exe"


# we need dotnet installed
if (-Not (Get-Command $DotNet -ErrorAction SilentlyContinue)) 
{
        Write-Error "donet tool does not appear to be installed we need dotnet core 5."
        Exit
}

# test we are in the right place and the expected directories exist
if  ( -Not ((Test-Path $AssemblerFolder) -And (Test-Path $EmulatorFolder) -And (Test-Path $CompilerFolder)))
{
    Write-Error "Missing one of the expected folders relative to this script:  $AssemblerFolder , $EmulatorFolder, $CompilerFolder"
}

if  ( -Not (Test-Path $Assembler) )
{
    Write-Host -ForegroundColor Yellow "Building the assembler"
    & $DotNet build -v q --nologo "$AssemblerFolder\Assembler.csproj"
}

if  ( -Not (Test-Path $Emulator) )
{
    Write-Host -ForegroundColor Yellow "Building the emulator"
    & $DotNet build -v q --nologo "$EmulatorFolder\Emulator.csproj"
}

if  ( -Not (Test-Path $Compiler) )
{
    Write-Host -ForegroundColor Yellow "Building the compiler"
    & $DotNet build -v q --nologo "$CompilerFolder\Compiler.csproj"
}



if ($Quiet) {
    $AppArgs = "--quiet=true"
} else {
    $AppArgs = ""
}

Write-Host "$command $Filename $AppArgs"

switch ($Command.ToLowerInvariant()) {
    "assemble"  
    { 
        & $Assembler $AppArgs --input=$Filename 
    }
    "run"     
    { 
        & $Emulator $AppArgs --input=$Filename 
    }

    "compile"
    { 
        & $Compiler $AppArgs --input=$Filename 
    }

}
