<# Defino las variables globales a utilizar. #>
$wd = Get-Location
$parent = Split-Path -Path $wd -Parent
$onedrive = "C:\Users\Lucas\OneDrive\Backups\Zips\"

<# Defino las funciones globales a utilizar. #>
function TestExistence {
# Esta funci�n chequea la existencia de los archivos que deber�an ser guardados en la unidad USB y en OneDrive.
    if ( (Test-Path -Path $arch1 -PathType Leaf) -and (Test-Path -Path $arch2 -PathType Leaf) ) {
        Write-Host "Operacion completada exitosamente." -ForegroundColor Green
    } else {
        Write-Error "La operacion no se pudo completar. Intente de nuevo."
    }
}

<# Defino el menu de opciones. #>
function Show-Menu {
    Write-Host "----------------------------------------------------------------------------"
    Write-Host "Bienvenido!" -ForegroundColor Green
    Write-Host "Por favor, seleccione de que desearia realizar una copia"
    Write-Host "----------------------------------------------------------------------------"
    Write-Host "Fecha:"
    Get-Date -Format "dd/MM/yyyy"
    Write-Host "Hora:"
    Get-Date -Format "hh:mm"
    Write-Host "----------------------------------------------------------------------------"
    Write-Host "1. Hacer copia del repositorio 'hosts'."
    Write-Host "2. Hacer copia del repositorio 'scripts'."
    Write-Host "3. Hacer copia del mundo de Minecraft."
    Write-Host "4. Hacer copia de los mapas de Call of Duty: Black Ops III."
    Write-Host "5. Hacer copia de los datos de partida de Mafia III: Definitive Edition."
    Write-Host "6. SALIR."
    Write-Host " "
}

<# Defino el dialogo de eleccion y las opciones. #>
do
 {
    # Dialogo de eleccion.
    Show-Menu
    $selection =
    Read-Host "Escriba el numero que corresponda a la opcion que desee y presione ENTER"
    Write-Host " "

    # Operaciones a realizar con cada comando.
    switch ($selection)
    {
        '1' {
            # Defino las variables locales a utilizar.
            $hosts = "https://github.com/foopsss/hosts/archive/refs/heads/master.zip"
            $arch1 = "$onedrive\Hosts.zip"
            $arch2 = "$parent\Zips\Hosts.zip"

            # Limpio la pantalla.
            Clear-Host

            # Descargo los archivos.
            Write-Host "Extrayendo contenido de la pagina y creando archivo zip!" -ForegroundColor Gray
            Invoke-WebRequest -Uri "$hosts" -OutFile "$arch1"
            Invoke-WebRequest -Uri "$hosts" -OutFile "$arch2"

            # Me aseguro de que la operaci�n haya finalizado correctamente.
            TestExistence
        }

        '2' {
            # Defino las variables locales a utilizar.
            $scriptsmain = "https://github.com/foopsss/scripts/archive/refs/heads/main.zip"
            $scriptsdev = "https://github.com/foopsss/Scripts/archive/refs/heads/development.zip"
            $arch1 = "$onedrive\Scripts.zip"
            $arch2 = "$parent\Zips\Scripts.zip"
            $arch3 = "G:\Backup\Software\Scripts\Scripts.zip"

            # Defino los arreglos locales a utilizar.
            $zips = @("Main.zip", "Development.zip")
            $ubicaciones = @("$arch1", "$arch2", "$arch3")

            # Defino las funciones locales a utilizar.
                function TestCleaning {
                # Esta funci�n chequea que la limpieza de los archivos residuales haya sido exitosa.
                    if ( !( (Test-Path -Path "$zips[1]" -PathType Leaf) -and (Test-Path -Path "$zips[2]" -PathType Leaf) ) ) {
                        Write-Host "Limpieza completada!" -ForegroundColor Green
                    } else {
                        Write-Error "La limpieza no ha sido completada exitosamente."
                    }
                }

                function TestExistenceV2 {
                # Esta funci�n chequea la existencia de los archivos que deber�an ser guardados en la unidad USB y en OneDrive.
                    if ( ( (Test-Path -Path $arch1 -PathType Leaf) -and (Test-Path -Path $arch2 -PathType Leaf) ) -and (Test-Path -Path $arch3 -PathType Leaf) ) {
                        Write-Host "Operacion completada exitosamente." -ForegroundColor Green
                    } else {
                        Write-Error "La operacion no se pudo completar. Intente de nuevo."
                    }
                }

            # Limpio la pantalla.
            Clear-Host

            # Descargo los archivos zip de cada rama del repositorio.
            Write-Host "Descargando los archivos zip de las ramas del repositorio!" -ForegroundColor Gray
            Invoke-WebRequest -Uri "$scriptsmain" -OutFile "Main.zip"
            Invoke-WebRequest -Uri "$scriptsdev" -OutFile "Development.zip"

            # Genero los archivos zips para guardar los zips de las ramas en las ubicaciones definidas.
            # Para ello, realizo dos iteraciones.
            Write-Host "Creando archivo zip!" -ForegroundColor Gray
            foreach ($zip in $zips) {
                foreach ($ubicacion in $ubicaciones) {
                    Compress-Archive -LiteralPath $zips -DestinationPath $ubicacion -Update
                }
            }

            # Remuevo los archivos que ya no necesito.
            Write-Host "Limpiando los archivos residuales!" -ForegroundColor Gray
            Remove-Item $zips
            TestCleaning

            # Me aseguro de que la operaci�n haya finalizado correctamente.
            TestExistenceV2
        }

        '3' {
            # Defino las variables locales a utilizar.
            $minecraft = "I:\Minecraft\Fabric\saves\Lucas3\"
            $arch1 = "$onedrive\Lucas3.zip"
            $arch2 = "$parent\Zips\Lucas3.zip"

            # Limpio la pantalla.
            Clear-Host

            # Creo el archivo zip.
            Write-Host "Creando archivo zip!" -ForegroundColor Gray
            Compress-Archive -Path "$minecraft" -DestinationPath "$arch1" -Update -CompressionLevel Optimal
            Copy-Item "$arch1" -Destination "$arch2" -Force

            # Me aseguro de que la operaci�n haya finalizado correctamente.
            TestExistence
        }

        '4' {
            # Defino las variables locales a utilizar.
            $bo3modtoolsmaps = "I:\SteamLibrary\steamapps\common\Call of Duty Black Ops III\map_source\zm\"
            $bo3modtoolsprefabs = "I:\SteamLibrary\steamapps\common\Call of Duty Black Ops III\map_source\_prefabs\Own Prefabs\"
            $arch1 = "$onedrive\Black Ops III Mod Tools.zip"
            $arch2 = "$parent\Zips\Black Ops III Mod Tools.zip"

            # Limpio la pantalla.
            Clear-Host

            # Creo el archivo zip.
            Write-Host "Creando archivo zip!" -ForegroundColor Gray
            Compress-Archive -LiteralPath "$bo3modtoolsmaps", "$bo3modtoolsprefabs" -DestinationPath "$arch1" -Update -CompressionLevel Optimal
            Compress-Archive -LiteralPath "$bo3modtoolsmaps", "$bo3modtoolsprefabs" -DestinationPath "$arch2" -Update -CompressionLevel Optimal
            
            # Me aseguro de que la operaci�n haya finalizado correctamente.
            TestExistence
        }

        '5' {
            # Defino las variables locales a utilizar.
            $mafia3 = "C:\Users\Lucas\AppData\Local\2K Games\Mafia III\"
            $arch1 = "$onedrive\Mafia III Definitive Edition.zip"
            $arch2 = "$parent\Zips\Mafia III Definitive Edition.zip"

            # Limpio la pantalla.
            Clear-Host

            # Creo el archivo zip.
            Write-Host "Creando archivo zip!" -ForegroundColor Gray
            Compress-Archive -LiteralPath "$mafia3" -DestinationPath "$arch1" -Update -CompressionLevel Optimal
            Compress-Archive -LiteralPath "$mafia3" -DestinationPath "$arch2" -Update -CompressionLevel Optimal

            # Me aseguro de que la operaci�n haya finalizado correctamente.
            TestExistence
        }
    }
    
    # Salgo de la seccion actual y limpio la pantalla.
    Write-Host "Presione una tecla para salir." -ForegroundColor Yellow
    [void][System.Console]::ReadKey($FALSE)
    Clear-Host
 }

<# Hasta que la opcion elegida sea 6 el script sigue funcionando. #>
until ($selection -eq '6')

<# Credits
*Adam Bertram:
    *adamtheautomator.com - Code to print a menu.
        (https://adamtheautomator.com/powershell-menu/)
    *4sysops.com - Information about errors in Powershell and how to deal with them.
        (https://4sysops.com/archives/stop-or-exit-a-powershell-script-when-it-errors/)

*MrPowerScripts/youtube.com - Parameter to print colored text with Write-Host.
    (https://www.youtube.com/watch?v=xA7xGA6cwwQ)

*Adam Gordon/blog.itpro.tv - Code to get the time and date.
    (https://blog.itpro.tv/get-date-powershell-cmdlet/)

*SS64.com - Code to pause the script.
    (https://ss64.com/ps/pause.html)

*Michael Pietroforte/4sysops.com - Code to download Internet files.
    (https://4sysops.com/archives/use-powershell-to-download-a-file-with-http-https-and-ftp/)

*Microsoft Docs/PowerShell Community:
    *Code to compress archives.
        (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/compress-archive?view=powershell-7.1)
    *Code to copy files.
        (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/copy-item?view=powershell-7.1)
    *Code to check if a folder exists.
        (https://devblogs.microsoft.com/powershell-community/determine-if-a-folder-exists/)
    *Information about variables.
        (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_variables?view=powershell-7.1)
    *Information about arrays.
        (https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-arrays?view=powershell-7.2)
    *Information about the "foreach" statement.
        (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_foreach?view=powershell-7.2)
    *Information about logical operators.
        (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logical_operators?view=powershell-7.2)

*shelladmin/shellgeek.com - Code to get the current working directory.
    (https://shellgeek.com/how-to-get-current-directory-full-path-in-powershell/)

*www.tutorialspoint.com - Code for if statements and to create or delete a directory.
    (https://www.tutorialspoint.com/powershell/if_else_statement_in_powershell.htm)

*Karim Buzdar/www.faqforge.com - Code to make comments.
    (https://www.faqforge.com/powershell/comment-code-powershell/)

*The sites listed below - Ideas and knowledge to develop or rework some of the functions seen in this script:
    *Stack Overflow - Users 'Anders', 'Jeff Zeitlin', 'Micky Balladelli'.
        (https://stackoverflow.com/questions/49179807/test-path-on-an-array-and-return-values)
        (https://stackoverflow.com/questions/56297149/if-test-path-path-detect-2-files-at-once)
        (https://stackoverflow.com/questions/51010422/test-path-with-variable-foldername)
    *Patrick Gruenauer/sid-500.com
        (https://sid-500.com/2021/10/26/powershell-zip-multiple-folder-or-files-at-once-with-compress-archive/#respond)
    *arcanecode/arcanecode.com
        (https://arcanecode.com/2018/09/17/downloading-files-with-powershell-and-invoke-webrequest/)
#>