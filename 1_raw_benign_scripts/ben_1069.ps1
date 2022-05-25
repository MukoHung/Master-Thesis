<#
Este script elimina archivos después de X días de su fecha de creación
Filtra los archivos según la extensión y de forma recursiva en todos los subdirectorios
#>

#### Parámetros de Trabajo

$dias = [int]7   # 7 días
$path = "D:\MSSQL\MSSQL10.GCMEXSQL\MSSQL\Backup"

####

$bak = Get-ChildItem -Recurse -Path $path | Where-Object { ($_.Extension -eq ".7z") -and ($_.CreationTime -le $(Get-Date).AddDays(-$dias)) } | Remove-Item -Force