# --- INTEGRANTES ---
# Ibrahim Zavala Hernandez
# Julio Gerardo Cazarez Gonzalez
# Pedro Saldaña Vazquez

# --- OBJETIVO ---
# Crear un programa que emule el clasico juego 
# de Piedra, Papel o Tijeras para 2 Jugadores o
# jugar contra un CPU

# --- MODULOS ---
Import-Module -Name .\funciones.psm1

# --- MENU ---
do{
    Write-Host "--- PIEDRA PAPEL O TIJEARS ---"
    Write-Host "// Seleccionar Opcion // 
    [1] Jugador vs Jugador
    [2] Jugador vs CPU
    [3] Ver Estadisticas
    [4] Salir
    "
    $opcion = read-host "Opcion"
        switch ($opcion){
            1{
                Clear-Host
                j_vs_j
                Read-Host "Presiona Enter Para Continuar"
                Clear-Host
                break
            }
            2{
                Clear-Host
                j_vs_cpu
                Read-Host "Presiona Enter Para Continuar"
                Clear-Host
                break
            }
            3{
                Clear-Host
                ver_estadisticas
                Read-Host "Presiona Enter Para Continuar"
                Clear-Host
                break
            }
            4{
                break
            }
            default{
                Clear-Host
                Write-Host "Valor Invalido
                "
            }  
        }
} while($opcion -ne 4){  
}

archivo_estadisticas

# --- FUENTE DE CONSULTA ---
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-random?view=powershell-7.1
# https://docs.microsoft.com/es-es/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-7.1
# https://docs.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-module-manifest?view=powershell-7.1
# https://devblogs.microsoft.com/scripting/handling-errors-the-powershell-way/
# https://docs.microsoft.com/es-es/powershell/scripting/samples/redirecting-data-with-out---cmdlets?view=powershell-7.1
