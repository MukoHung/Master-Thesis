
clear
Write-Output " _____________________________________________________________________________________________________"

Write-Output ""
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Host "                                   Script Creado por Franklin Gedler                                  " -ForegroundColor green -BackgroundColor Black
Write-Output "                                  ++++++++++++++++++++++++++++++++++++"
Write-Output ""

Write-Output " _____________________________________________________________________________________________________"


Write-Output ""
Write-host 'Preparando lo necesario . . . Espere' -ForegroundColor Yellow -BackgroundColor Black
Write-Output ""

function DownloadModules {
    param (
        $1
    )
    $token = "Token Generado por GitHub"
    $headers = @{Authorization = "token $($token)"}
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Headers $headers `
        -Uri "https://raw.githubusercontent.com/franklin-gedler/Scripts-Win10/main/Prepare-Win10/$1.ps1" `
        -UseBasicParsing -OutFile "C:\PrepareWin10\$1.ps1"
}

function OnScriptConfig {
    # Deshabilito el control de usuarios UAC
    Set-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Value 0 > NULL


    # seteo el script que se va a ejecutar
    New-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'PrepareWin10' -Value '"C:\PrepareWin10\SetupComplete.cmd"' > NULL
    #New-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'PrepareWin10' -Value '"C:\PrepareWin10\SetupComplete.cmd"' > NULL
}

function OffScriptConfig {
    # Habilito el control de usuarios UAC
    Set-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Value 1 > NULL
    
    # Remuevo el Script que se va a Ejecutar
    Remove-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'PrepareWin10' > NULL
    #Remove-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'PrepareWin10'
}

function PostRunConfig {
    
    mkdir C:\PrepareWin10 -Force > NULL

    Copy-Item -Path "C:\Windows\Setup\Scripts\*" -Destination C:\PrepareWin10 -Force -Recurse

    Start-Sleep -Seconds 15

    # Seteo el file SetupConfig.cmd
    (Get-Content C:\PrepareWin10\SetupComplete.cmd).Replace('%windir%\Setup\Scripts\process.ps1','C:\PrepareWin10\process.ps1') | Set-Content C:\PrepareWin10\SetupComplete.cmd

    # Seteo el file process.ps1
    (Get-Content "C:\PrepareWin10\process.ps1").Replace('Stop-Service wuauserv -Force','#Stop-Service wuauserv -Force') | Set-Content "C:\PrepareWin10\process.ps1"
    (Get-Content "C:\PrepareWin10\process.ps1").Replace('Set-Service wuauserv -StartupType Disabled','#Set-Service wuauserv -StartupType Disabled') | Set-Content "C:\PrepareWin10\process.ps1"
    (Get-Content "C:\PrepareWin10\process.ps1").Replace('Pause','timeout /t 10') | Set-Content "C:\PrepareWin10\process.ps1"
}

$Status= Get-ChildItem -Path C:\Users\adminuser\Desktop\ -Name Status.txt

if (!$Status){

    # Esto es Para que se ejecute despues del reinicio
    PostRunConfig

    # Ejecuto una sola vez ShowMenu ya que despues en los proximos reinicios con los archivos de estado se de que pais es.
    DownloadModules "Firma"
    DownloadModules "PowerAdapterStatus"
    DownloadModules "MainAction"
    DownloadModules "ValidateConnectAD"
    DownloadModules "VerifyCred"
    DownloadModules "ChangeName"
    DownloadModules "TimeSet"
    . C:\PrepareWin10\MainAction.ps1
    MainAction

    # Activo Bitlocker
    $Pais = Get-Content C:\PrepareWin10\Pais.txt
    DownloadModules "Bitlocker"
    . C:\PrepareWin10\Bitlocker.ps1
    Bitlocker $Pais

    # Configuro Windows para que ejecute el script al iniciar Windows
    OnScriptConfig

    Write-Output '1' > C:\Users\adminuser\Desktop\status.txt
    timeout /t 10
    Restart-Computer


}else{
    
    Set-Location -Path C:\PrepareWin10\
    $Status = Get-Content C:\Users\adminuser\Desktop\status.txt
    $Pais = Get-Content C:\PrepareWin10\Pais.txt
    $CodigoPais = Get-Content C:\PrepareWin10\CodigoPais.txt

    switch($Status){
    
        1{
            DownloadModules "PowerAdapterStatus"
            DownloadModules "UpdatingWindows"
            . C:\PrepareWin10\UpdatingWindows.ps1
            UpdatingWindows
            

            Write-Output '2' > C:\Users\adminuser\Desktop\status.txt
            
            timeout /t 10
            Restart-Computer
        }

        2{
            
            DownloadModules "PowerAdapterStatus"
            DownloadModules "DellCommandUpdate"
            . C:\PrepareWin10\DellCommandUpdate.ps1
            DellCommandUpdate

            #Write-Output '3' > C:\Users\adminuser\Desktop\status.txt # Esto lo setea el DellCommandUpdate
            #Pause
            timeout /t 10
            Restart-Computer
        }

        3{
            # Descargo he instalo el paquete de programas segun el Pais que hayan seleccionado
            switch ($Pais) {
                
                AR{
                    Write-Output "Programas Para AR"
                    DownloadModules "ARProgramPackages"
                    . C:\PrepareWin10\ARProgramPackages.ps1
                    ARProgramPackages
                }

                UY{
                    Write-Output "Programas Para UY"
                    DownloadModules "UYProgramPackages"
                    . C:\PrepareWin10\UYProgramPackages.ps1
                    UYProgramPackages
                }
                
                BR{
                    Write-Output "Programas Para BR"
                    DownloadModules "BRProgramPackages"
                    . C:\PrepareWin10\BRProgramPackages.ps1
                    BRProgramPackages
                }

                CO{
                    Write-Output "Programas Para CO"
                    DownloadModules "COProgramPackages"
                    . C:\PrepareWin10\COProgramPackages.ps1
                    COProgramPackages
                }

                CL{
                    Write-Output "Programas Para CL"
                    DownloadModules "CLProgramPackages"
                    . C:\PrepareWin10\CLProgramPackages.ps1
                    CLProgramPackages
                }

                MX{
                    Write-Output "Programas Para MX"
                    DownloadModules "MXProgramPackages"
                    . C:\PrepareWin10\MXProgramPackages.ps1
                    MXProgramPackages
                }

                PE{
                    Write-Output "Programas Para PE"
                    DownloadModules "PEProgramPackages"
                    . C:\PrepareWin10\PEProgramPackages.ps1
                    PEProgramPackages
                }
            }
            
            Write-Output '4' > C:\Users\adminuser\Desktop\status.txt
            #Pause
            timeout /t 10
            Restart-Computer
        }

        4{
            <#   Esto esta dentro de JoinAD
            DownloadModules "ChangePassadminuser"
            . C:\PrepareWin10\ChangePassadminuser.ps1
            ChangePassadminuser $CodigoPais
            #>
            
            # La agrego a Dominio
            DownloadModules "JoinAD"
            . C:\PrepareWin10\JoinAD.ps1
            JoinAD $Pais $CodigoPais
            
            <#    Este Bloque lo controla JoinAD.ps1
            Write-Output 'Lista Para Usar' > C:\Users\adminuser\Desktop\status.txt
            
            timeout /t 10

            OffScriptConfig   # Esto elimina en el registro la ejecucion del script al inicio

            # Limpio el Sistema de los archivos de instalacion
            DownloadModules "WipeSystem"
            . C:\PrepareWin10\WipeSystem.ps1
            WipeSystem
            #>
            
            Restart-Computer
            
        }
        
    }
    
}


