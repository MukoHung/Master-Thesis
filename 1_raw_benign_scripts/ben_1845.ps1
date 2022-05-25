<# Defino las variables a utilizar. #>
$wd = Get-Location
$METAINF = 'META-INF\com\google\android'
$system = 'system\etc'
$updaterscript = 'https://raw.githubusercontent.com/foopsss/Scripts/main/Hosts/ZipGenerator/files/updater-script'
$updatebinary = 'https://raw.githubusercontent.com/foopsss/Scripts/main/Hosts/ZipGenerator/files/update-binary'
$hosts = 'https://raw.githubusercontent.com/foopsss/hosts/master/hosts-porn'

<# Código. #>

# Cambio el directorio de trabajo al actual.
Set-Location -Path "$wd"

# Imprimo una cabecera.
Write-Host "-----------------------------------" -ForegroundColor Yellow
Write-Host "Generador de archivos para flashear" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow

# Creo las carpetas.
Write-Host "Creando las carpetas necesarias..." -ForegroundColor Cyan
New-Item -Path "$METAINF" -ItemType Directory -Force | Out-Null
New-Item -Path "$system" -ItemType Directory -Force | Out-Null

# Chequeo si las carpetas existen.
if ( Test-Path "$METAINF", "$system" )
{
    Write-Host "Operación completada exitosamente." -ForegroundColor Green
}
else
{
    Write-Host "La operación no se pudo completar. Intente de nuevo." -ForegroundColor Red
}
Write-Host ""
    
# Descargo los archivos necesarios.
Write-Host "Descargando los archivos más nuevos..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "$updaterscript" -OutFile "$METAINF\updater-script"
Invoke-WebRequest -Uri "$updatebinary" -OutFile "$METAINF\update-binary"
Invoke-WebRequest -Uri "$hosts" -OutFile "$system\hosts"

# Chequeo si los archivos existen.
if ( Test-Path "$METAINF\updater-script", "$METAINF\update-binary", "$system\hosts" -PathType Leaf )
{
    Write-Host "Operación completada exitosamente." -ForegroundColor Green
}
else
{
    Write-Host "La operación no se pudo completar. Intente de nuevo." -ForegroundColor Red
}
Write-Host ""

# Indico los pasos a seguir a continuación.
Write-Host "Debido a problemas en el proceso de generación de comprimidos zip de Powershell, estos no se pueden usar para flashear archivos en Android."
Write-Host
Write-Host "Por favor, seleccione las carpetas 'META-INF' y 'system' generadas por el script en su ubicación actual, y comprimalas utilizando alguna herramienta como WinRAR o 7-Zip."
Write-Host
Write-Host "Gracias, y disculpe las molestias."
Write-Host

# Con esta función se simula el "Presiona una tecla para salir" y se cierra el programa.
Write-Host "Presione una tecla para salir." -ForegroundColor Yellow
[void][System.Console]::ReadKey($FALSE)
EXIT

<# Credits
•shelladmin/shellgeek.com - Code to get the current working directory.
 (https://shellgeek.com/how-to-get-current-directory-full-path-in-powershell/)
•www.tutorialspoint.com - Code to create and delete directories.
 (https://www.tutorialspoint.com/powershell/powershell_files_create_folders.htm)
 (https://www.tutorialspoint.com/powershell/powershell_files_delete_folders.htm)
•Stack Overflow - User 'ChiliYago' - Code to hide console output using Out-Null and the pipeline.
 (https://stackoverflow.com/questions/46586382/hide-powershell-output)
•Michael Pietroforte/4sysops.com - Code to download Internet files.
 (https://4sysops.com/archives/use-powershell-to-download-a-file-with-http-https-and-ftp/)
•Microsoft Docs/PowerShell Community - Code to change a script working directory, force directory creation with New-Item, for if statements and Test-Path.
 (https://docs.microsoft.com/en-us/powershell/scripting/samples/managing-current-location?view=powershell-7.2)
 (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item?view=powershell-7.2)
 (https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-if?view=powershell-7.2)
 (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-7.2)
•SS64.com - Code to pause the script.
 (https://ss64.com/ps/pause.html)
•Karim Buzdar/www.faqforge.com - Code to make comments.
 (https://www.faqforge.com/powershell/comment-code-powershell/)
•Dejan Mladenović/www.improvescripting.com - Instructions to debug code in Powershell ISE.
 (https://www.improvescripting.com/how-to-debug-powershell-scripts/)
#>
