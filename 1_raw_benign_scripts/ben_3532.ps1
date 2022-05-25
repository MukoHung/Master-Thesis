#Requires -Version 4



# init.ps1
# 
# Код инициализации DCPT.
# 
# Дата последнего изменения: 30.11.2021
# 
# Этот файл должен быть сохранён как init.ps1 в кодировке UTF-8 с BOM
# 
# =================================================================
# !!! НЕ ИЗМЕНЯЙТЕ ЭТОТ ФАЙЛ, ЕСЛИ НЕ УВЕРЕНЫ В СВОИХ ДЕЙСТВИЯХ !!!
# =================================================================



# Аргументы

Param (
    [Parameter(
        Mandatory = $True,
        HelpMessage = "Path to the input file."
    )]
    [Alias("I")]
    [string]$File
)



# Проверить, существуют ли обязательные файлы

$iLibVariables = "$PSScriptRoot\variables.ps1"
$iLibFunctions = "$PSScriptRoot\functions.ps1"
$iLibLicenseLic = "$PSScriptRoot\license-lic.ps1"
$iLibMain = "$PSScriptRoot\main.ps1"
$iDirEtalons = "$PSScriptRoot\..\etalons"

if ((-not (Test-Path -Path "$iLibVariables" -PathType "Leaf")) -or `
    (-not (Test-Path -Path "$iLibFunctions" -PathType "Leaf")) -or `
    (-not (Test-Path -Path "$iLibLicenseLic" -PathType "Leaf")) -or `
    (-not (Test-Path -Path "$iLibMain" -PathType "Leaf")) -or `
    (-not (Test-Path -Path "$iDirEtalons" -PathType "Container")) -or `
    ((ls -Path "$iDirEtalons" -Recurse | Measure-Object).Count -eq 0))
{
    Write-Host "Error: Integrity check failed."
    Write-Host ""
    Write-Host "List of mandatory files:"
    Write-Host "variables.ps1, functions.ps1, license-lic.ps1, main.ps1"
    Write-Host ""
    Write-Host "List of mandatory directories:"
    Write-Host "..\etalons (must not be an empty directory)"
    exit 1
}



# Импортировать variables.ps1 и проверить наличие обязательных переменных

. "$iLibVariables"

if ((-not (Test-Path variable:local:vPathTo7zExe)) -or `
    (-not (Test-Path variable:local:vPathToSignToolExe)) -or `
    (-not (Test-Path variable:local:vPathToProductBuilderExe)) -or `
    (-not (Test-Path -Path "$vPathTo7zExe" -PathType "Leaf")) -or `
    (-not (Test-Path -Path "$vPathToSignToolExe" -PathType "Leaf")) -or `
    (-not (Test-Path -Path "$vPathToProductBuilderExe" -PathType "Leaf")))
{
    Write-Host "Error: One or more variables are not set"
    Write-Host "or paths they link to are not valid."
    Write-Host ""
    Write-Host "List of mandatory variables (variables.ps1):"
    Write-Host "vPathTo7zExe, vPathToSignToolExe, vPathToProductBuilderExe"
    exit 1
}



# Импортировать functions.ps1 и проверить наличие обязательных переменных

. "$iLibFunctions"

if ((-not (Test-Path variable:local:fLogDateTimeFormat)) -or `
    (-not (Test-Path variable:local:fReportData)) -or `
    (-not (Test-Path variable:local:fReportCellDelimeter)) -or `
    (-not (Test-Path variable:local:fReportDir)) -or `
    (-not (Test-Path variable:local:fReportFileExtension)) -or `
    (-not (Test-Path variable:local:fHashAlgorithm)) -or `
    (-not (Test-Path -Path "$fReportDir" -IsValid)))
{
    Write-Host "Error: One or more variables are not set"
    Write-Host "or paths they link to are not valid."
    Write-Host ""
    Write-Host "List of mandatory variables (functions.ps1):"
    Write-Host "fLogDateTimeFormat, fReportData, fReportCellDelimeter,"
    Write-Host "fReportDir, fReportFileExtension, fHashAlgorithm"
    exit 1
}



# Импортировать license-lic.ps1 и проверить наличие обязательных переменных

. "$iLibLicenseLic"

if ((-not (Test-Path variable:local:lLicenseLicKeys)))
{
    Write-Host "Error: One or more variables are not set."
    Write-Host ""
    Write-Host "List of mandatory variables (license-lic.ps1):"
    Write-Host "lLicenseLicKeys"
    exit 1
}



# Получить объект ФС из пути, переданного в скрипт
# Подготовить имя для файла отчёта
# Get-Date - чтобы повторный запуск не перезаписывал оригинальный файл

$InputFile = (Get-Item -Path "$File")

$iReportName = $InputFile.BaseName + `
"_" + $InputFile.LastWriteTime.toString("dd-MM-yyyy_HH-mm") + `
"_" + $(Get-Date -Format "HH-mm-ss") + `
$fReportFileExtension



# Вызвать "Main"

. "$iLibMain"
