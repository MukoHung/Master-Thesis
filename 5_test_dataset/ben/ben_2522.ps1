Function ActualizarVersion2013R2{
    $VersionNAV                  = '2013 R2'
    $RutaApplication             = '\\tipsa.local\tipsa\CD Producto NAV\2013R2\RU\' + $CUNueva2013R2 + '\APPLICATION\*' 
    foreach ($Fichero in (Get-Item -path $RutaApplication -Filter *.fob))
      {
      $IdCompilacion = $Fichero.Name.Split(".")[3]
      }
    $RutaAccesos                 = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\Links\NAV\NAV 2013R2\'
    $RutaRTCVersionAnterior      = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\71\RoleTailored Client ' + $CUAnterior2013R2
    $RutaRTCVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\71\RoleTailored Client ' + $CUNueva2013R2
    $RutaRTCProductoVersionNueva = '\\tipsa.local\tipsa\CD Producto NAV\2013R2\RU\' + $CUNueva2013R2 + '\RTC'
    $FicheroObjetosOrigenFob     = '\\Tipsa.local\tipsa\CD Producto NAV\2013R2\RU\' + $CUNueva2013R2 + '\APPLICATION\NAV.7.1.' + $IdCompilacion +'.ES.CUObjects.fob'
    $FicheroObjetosOrigenTxt     = '\\Tipsa.local\tipsa\CD Producto NAV\2013R2\RU\' + $CUNueva2013R2 + '\APPLICATION\NAV.7.1.' + $IdCompilacion +'.ES.CUObjects.txt'
    $FicheroObjetosDestinoTxt    = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\PowerShell\Migracion\Objetos\2013 R2 ' + $CUNueva2013R2 + '.txt'
    $NombreServidor              = 'HOTH\SQL2K14'
    $NombreBBDD                  = 'CRONUS2013R2'
    $RutaNavModelToolPS1         = 'C:\Program Files (x86)\Microsoft Dynamics NAV\80\RoleTailored Client\NavModelTools.ps1'
    $RutaFinSQL                  = 'C:\Program Files (x86)\Microsoft Dynamics NAV\71\RoleTailored Client ' + $CUAnterior2013R2 + '\Finsql.exe'

    Write-Host ''
    Write-Host -foregroundcolor Yellow 'ACTUALIZANDO VERSION 2013 R2'
    CopiarDirectorio $RutaRTCVersionAnterior $RutaRTCVersionNueva    
    CopiarDirectorio $RutaRTCProductoVersionNueva $RutaRTCVersionNueva
    ActualizarAccesosDirectosNAV $CUAnterior2013R2 $CUNueva2013R2 $RutaAccesos
    ActualizarAccesosDirectosCronus $CUAnterior2013R2 $CUNueva2013R2 $MesAnterior $AnoAnterior $MesNuevo $AnoNuevo $RutaAccesosCronus
    ActualizarFicheroVersiones $VersionNAV $CUNueva2013R2 $IdCompilacion $MesNuevo $AnoNuevo
    CopiarFicheroApplicacionAPowerShell $FicheroObjetosOrigenTxt $FicheroObjetosDestinoTxt
    # ActualizarObjetos $FicheroObjetosOrigenFob $NombreServidor $NombreBBDD $RutaNavModelToolPS1 $RutaFinSQL
}
Function ActualizarVersion2015{
    $VersionNAV                  = '2015'
    $RutaApplication             = '\\tipsa.local\tipsa\CD Producto NAV\2015\CU\' +$CUNueva2015 + '\APPLICATION\*' 
    foreach ($Fichero in (Get-Item -path $RutaApplication -Filter *.fob))
      {
      $IdCompilacion = $Fichero.Name.Split(".")[3]
      }
    $RutaAccesos                 = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\Links\NAV\NAV 2015\'
    $RutaRTCVersionAnterior      = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\80\RoleTailored Client ' + $CUAnterior2015
    $RutaRTCVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\80\RoleTailored Client ' + $CUNueva2015
    $RutaRTCProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\2015\CU\' + $CUNueva2015 + '\DVD\RoleTailoredClient\program files\Microsoft Dynamics NAV\80\RoleTailored Client'
    $FicheroObjetosOrigenFob     = '\\Tipsa.local\tipsa\CD Producto NAV\2015\CU\' + $CUNueva2015 + '\APPLICATION\NAV.8.0.' + $IdCompilacion +'.ES.CUObjects.fob'
    $FicheroObjetosOrigenTxt     = '\\Tipsa.local\tipsa\CD Producto NAV\2015\CU\' + $CUNueva2015 + '\APPLICATION\NAV.8.0.' + $IdCompilacion +'.ES.CUObjects.txt'
    $FicheroObjetosDestinoTxt    = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\PowerShell\Migracion\Objetos\2015 ' + $CUNueva2015 + '.txt'
    $NombreServidor              = 'HOTH\SQL2K14'
    $NombreBBDD                  = 'CRONUS2015'
    $RutaNavModelToolPS1         = 'C:\Program Files (x86)\Microsoft Dynamics NAV\80\RoleTailored Client\NavModelTools.ps1'
    #$RutaFinSQL                 = 'C:\Program Files (x86)\Microsoft Dynamics NAV\80\RoleTailored Client ' + $CUAnterior2015 + '\Finsql.exe'
    $RutaFinSQL                  = 'C:\Program Files (x86)\Microsoft Dynamics NAV\80\RoleTailored Client ' + $CUAnterior2015 + '\'
    $RutaSTXProductoVersionNueva = '\\tipsa.local\tipsa\CD Producto NAV\2015\CU\' + $CUNueva2015 + '\DVD\Installers\ES\RTC\PFiles\Microsoft Dynamics NAV\80\RoleTailored Client\ESP'
    $RutaSTXVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\80\RoleTailored Client ' + $CUNueva2015 +'\ESP'

    Write-Host ''
    Write-Host -foregroundcolor Yellow 'ACTUALIZANDO VERSION 2015'
    CopiarDirectorio $RutaRTCVersionAnterior $RutaRTCVersionNueva    
    CopiarDirectorio $RutaRTCProductoVersionNueva $RutaRTCVersionNueva
    CopiarDirectorio $RutaSTXProductoVersionNueva $RutaSTXVersionNueva
    ActualizarAccesosDirectosNAV $CUAnterior2015 $CUNueva2015 $RutaAccesos
    ActualizarAccesosDirectosCronus $CUAnterior2015 $CUNueva2015 $MesAnterior $AnoAnterior $MesNuevo $AnoNuevo $RutaAccesosCronus
    ActualizarFicheroVersiones $VersionNAV $CUNueva2015 $IdCompilacion $MesNuevo $AnoNuevo
    CopiarFicheroApplicacionAPowerShell $FicheroObjetosOrigenTxt $FicheroObjetosDestinoTxt
    # ActualizarObjetos $FicheroObjetosOrigenFob $NombreServidor $NombreBBDD $RutaNavModelToolPS1 $RutaFinSQL
}
Function ActualizarVersion2016{
    $VersionNAV                  = '2016'
    $RutaApplication             = '\\tipsa.local\tipsa\CD Producto NAV\2016\' +$CUNueva2016 + '\APPLICATION\*' 
    foreach ($Fichero in (Get-Item -path $RutaApplication -Filter *.fob))
      {
      $IdCompilacion = $Fichero.Name.Split(".")[3]
      }
    $RutaAccesos                 = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\Links\NAV\NAV 2016\'
    $RutaRTCVersionAnterior      = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\90\RoleTailored Client ' + $CUAnterior2016
    $RutaRTCVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\90\RoleTailored Client ' + $CUNueva2016
    $RutaRTCProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\2016\' + $CUNueva2016 + '\DVD\RoleTailoredClient\program files\Microsoft Dynamics NAV\90\RoleTailored Client'
    $FicheroObjetosOrigenFob     = '\\Tipsa.local\tipsa\CD Producto NAV\2016\' + $CUNueva2016 + '\APPLICATION\NAV.9.0.' + $IdCompilacion +'.ES.CUObjects.fob'
    $FicheroObjetosOrigenTxt     = '\\Tipsa.local\tipsa\CD Producto NAV\2016\' + $CUNueva2016 + '\APPLICATION\NAV.9.0.' + $IdCompilacion +'.ES.CUObjects.txt'
    $FicheroObjetosDestinoTxt    = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\PowerShell\Migracion\Objetos\2016 ' + $CUNueva2016 + '.txt'
    $NombreServidor              = 'HOTH\SQL2K14'
    $NombreBBDD                  = 'CRONUS2016'
    $RutaNavModelToolPS1         = 'C:\Program Files (x86)\Microsoft Dynamics NAV\90\RoleTailored Client\NavModelTools.ps1'
    $RutaSTXProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\2016\' + $CUNueva2016 + '\DVD\Installers\ES\RTC\PFiles\Microsoft Dynamics NAV\90\RoleTailored Client\ESP'
    $RutaSTXVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\90\RoleTailored Client ' + $CUNueva2016 +'\ESP'

    Write-Host ''
    Write-Host -foregroundcolor Yellow 'ACTUALIZANDO VERSION 2016'
    CopiarDirectorio $RutaRTCVersionAnterior $RutaRTCVersionNueva    
    CopiarDirectorio $RutaRTCProductoVersionNueva $RutaRTCVersionNueva
    CopiarDirectorio $RutaSTXProductoVersionNueva $RutaSTXVersionNueva
    ActualizarAccesosDirectosNAV $CUAnterior2016 $CUNueva2016 $RutaAccesos
    ActualizarAccesosDirectosCronus $CUAnterior2016 $CUNueva2016 $MesAnterior $AnoAnterior $MesNuevo $AnoNuevo $RutaAccesosCronus
    ActualizarFicheroVersiones $VersionNAV $CUNueva2016 $IdCompilacion $MesNuevo $AnoNuevo
    CopiarFicheroApplicacionAPowerShell $FicheroObjetosOrigenTxt $FicheroObjetosDestinoTxt
    # ActualizarObjetos $FicheroObjetosOrigenFob $NombreServidor $NombreBBDD $RutaNavModelToolPS1 $RutaFinSQL
}
Function ActualizarVersion2017{
    $VersionNAV                  = '2017'
    $RutaApplication             = '\\tipsa.local\tipsa\CD Producto NAV\2017\CU\' +$CUNueva2017 + '\APPLICATION\*' 
    foreach ($Fichero in (Get-Item -path $RutaApplication -Filter *.fob))
      {
      $IdCompilacion = $Fichero.Name.Split(".")[3]
      }
    $RutaAccesos                 = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\Links\NAV\NAV 2017\'
    $RutaRTCVersionAnterior      = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\100\RoleTailored Client ' + $CUAnterior2017
    $RutaRTCVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\100\RoleTailored Client ' + $CUNueva2017
    $RutaRTCProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\2017\CU\' + $CUNueva2017 + '\DVD\RoleTailoredClient\program files\Microsoft Dynamics NAV\100\RoleTailored Client'
    $FicheroObjetosOrigenFob     = '\\Tipsa.local\tipsa\CD Producto NAV\2017\CU\' + $CUNueva2017 + '\APPLICATION\NAV.10.0.' + $IdCompilacion +'.ES.CUObjects.fob'
    $FicheroObjetosOrigenTxt     = '\\Tipsa.local\tipsa\CD Producto NAV\2017\CU\' + $CUNueva2017 + '\APPLICATION\NAV.10.0.' + $IdCompilacion +'.ES.CUObjects.txt'
    $FicheroObjetosDestinoTxt    = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\PowerShell\Migracion\Objetos\2017 ' + $CUNueva2017 + '.txt'
    $NombreServidor              = 'HOTH\SQL2K14'
    $NombreBBDD                  = 'CRONUS2017'
    $RutaNavModelToolPS1         = 'C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\NavModelTools.ps1'
    $RutaSTXProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\2017\CU\' + $CUNueva2017 + '\DVD\Installers\ES\RTC\PFiles\Microsoft Dynamics NAV\100\RoleTailored Client\ESP'
    $RutaSTXVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\100\RoleTailored Client ' + $CUNueva2017 +'\ESP'

    Write-Host ''
    Write-Host -foregroundcolor Yellow 'ACTUALIZANDO VERSION 2017'
    CopiarDirectorio $RutaRTCVersionAnterior $RutaRTCVersionNueva    
    CopiarDirectorio $RutaRTCProductoVersionNueva $RutaRTCVersionNueva
    CopiarDirectorio $RutaSTXProductoVersionNueva $RutaSTXVersionNueva
    ActualizarAccesosDirectosNAV $CUAnterior2017 $CUNueva2017 $RutaAccesos
    ActualizarAccesosDirectosCronus $CUAnterior2017 $CUNueva2017 $MesAnterior $AnoAnterior $MesNuevo $AnoNuevo $RutaAccesosCronus
    ActualizarFicheroVersiones $VersionNAV $CUNueva2017 $IdCompilacion $MesNuevo $AnoNuevo
    CopiarFicheroApplicacionAPowerShell $FicheroObjetosOrigenTxt $FicheroObjetosDestinoTxt
    # ActualizarObjetos $FicheroObjetosOrigenFob $NombreServidor $NombreBBDD $RutaNavModelToolPS1 $RutaFinSQL
}
Function ActualizarVersion2018{
    $VersionNAV                  = '2018'
    $RutaApplication             = '\\tipsa.local\tipsa\CD Producto NAV\2018\CU\' +$CUNueva2018 + '\APPLICATION\*' 
    foreach ($Fichero in (Get-Item -path $RutaApplication -Filter *.fob))
      {
      $IdCompilacion = $Fichero.Name.Split(".")[3]
      }
    $RutaAccesos                 = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\Links\NAV\NAV 2018\'
    $RutaRTCVersionAnterior      = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\110\RoleTailored Client ' + $CUAnterior2018
    $RutaRTCVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\110\RoleTailored Client ' + $CUNueva2018
    $RutaRTCProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\2018\CU\' + $CUNueva2018 + '\DVD\RoleTailoredClient\program files\Microsoft Dynamics NAV\110\RoleTailored Client'
    $FicheroObjetosOrigenFob     = '\\Tipsa.local\tipsa\CD Producto NAV\2018\CU\' + $CUNueva2018 + '\APPLICATION\NAV.11.0.' + $IdCompilacion +'.ES.CUObjects.fob'
    $FicheroObjetosOrigenTxt     = '\\Tipsa.local\tipsa\CD Producto NAV\2018\CU\' + $CUNueva2018 + '\APPLICATION\NAV.11.0.' + $IdCompilacion +'.ES.CUObjects.txt'
    $FicheroObjetosDestinoTxt    = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\PowerShell\Migracion\Objetos\2018 ' + $CUNueva2018 + '.txt'
    $NombreServidor              = 'HOTH\SQL2K14'
    $NombreBBDD                  = 'CRONUS2018'
    $RutaNavModelToolPS1         = 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\NavModelTools.ps1'
    $RutaSTXProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\2018\CU\' + $CUNueva2018 + '\DVD\Installers\ES\RTC\PFiles\Microsoft Dynamics NAV\110\RoleTailored Client\ESP'
    $RutaSTXVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\NAV\110\RoleTailored Client ' + $CUNueva2018 +'\ESP'

    Write-Host ''
    Write-Host -foregroundcolor Yellow 'ACTUALIZANDO VERSION 2018'
    CopiarDirectorio $RutaRTCVersionAnterior $RutaRTCVersionNueva    
    CopiarDirectorio $RutaRTCProductoVersionNueva $RutaRTCVersionNueva
    CopiarDirectorio $RutaSTXProductoVersionNueva $RutaSTXVersionNueva
    ActualizarAccesosDirectosNAV $CUAnterior2018 $CUNueva2018 $RutaAccesos
    ActualizarAccesosDirectosCronus $CUAnterior2018 $CUNueva2018 $MesAnterior $AnoAnterior $MesNuevo $AnoNuevo $RutaAccesosCronus
    ActualizarFicheroVersiones $VersionNAV $CUNueva2018 $IdCompilacion $MesNuevo $AnoNuevo
    CopiarFicheroApplicacionAPowerShell $FicheroObjetosOrigenTxt $FicheroObjetosDestinoTxt
    # ActualizarObjetos $FicheroObjetosOrigenFob $NombreServidor $NombreBBDD $RutaNavModelToolPS1 $RutaFinSQL
}
Function ActualizarVersionBC365130{
    $VersionNAV                  = 'BC365'
    $RutaApplication             = '\\tipsa.local\tipsa\CD Producto NAV\BC365\CU\' +$CUNuevaBC365 + '\APPLICATION\*' 
    foreach ($Fichero in (Get-Item -path $RutaApplication -Filter *.fob))
      {
      $IdCompilacion = $Fichero.Name.Split(".")[3]
      }
    $RutaAccesos                 = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\Links\NAV\BC130\'
    $RutaRTCVersionAnterior      = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\BC365\130\RoleTailored Client ' + $CUAnteriorBC365
    $RutaRTCVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\BC365\130\RoleTailored Client ' + $CUNuevaBC365
    $RutaRTCProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\BC365\CU\' + $CUNuevaBC365 + '\DVD\RoleTailoredClient\program files\Microsoft Dynamics NAV\130\RoleTailored Client'
    $FicheroObjetosOrigenFob     = '\\Tipsa.local\tipsa\CD Producto NAV\BC365\CU\' + $CUNuevaBC365 + '\APPLICATION\Dynamics.365.BC.' + $IdCompilacion +'.ES.CUObjects.fob'
    $FicheroObjetosOrigenTxt     = '\\Tipsa.local\tipsa\CD Producto NAV\BC365\CU\' + $CUNuevaBC365 + '\APPLICATION\Dynamics.365.BC.' + $IdCompilacion +'.ES.CUObjects.txt'
    $FicheroObjetosDestinoTxt    = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\PowerShell\Migracion\Objetos\BC365 ' + $CUNuevaBC365 + '.txt'
    $NombreServidor              = 'VORTEX\SQL2K17'
    $NombreBBDD                  = 'CRONUSBC365'
    $RutaNavModelToolPS1         = 'C:\Program Files (x86)\Microsoft Dynamics NAV\130\RoleTailored Client\NavModelTools.ps1'
    $RutaSTXProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\BC365\CU\' + $CUNuevaBC365 + '\DVD\Installers\ES\RTC\PFiles\Microsoft Dynamics NAV\130\RoleTailored Client\ESP'
    $RutaSTXVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\BC365\130\RoleTailored Client ' + $CUNuevaBC365 +'\ESP'

    Write-Host ''
    Write-Host -foregroundcolor Yellow 'ACTUALIZANDO VERSION BC365 130'
    CopiarDirectorio $RutaRTCVersionAnterior $RutaRTCVersionNueva    
    CopiarDirectorio $RutaRTCProductoVersionNueva $RutaRTCVersionNueva
    CopiarDirectorio $RutaSTXProductoVersionNueva $RutaSTXVersionNueva
    ActualizarAccesosDirectosNAV $CUAnteriorBC365 $CUNuevaBC365 $RutaAccesos
    ActualizarAccesosDirectosCronus $CUAnteriorBC365 $CUNuevaBC365 $MesAnterior $AnoAnterior $MesNuevo $AnoNuevo $RutaAccesosCronus
    ActualizarFicheroVersiones $VersionNAV $CUNuevaBC365 $IdCompilacion $MesNuevo $AnoNuevo
    CopiarFicheroApplicacionAPowerShell $FicheroObjetosOrigenTxt $FicheroObjetosDestinoTxt
    # ActualizarObjetos $FicheroObjetosOrigenFob $NombreServidor $NombreBBDD $RutaNavModelToolPS1 $RutaFinSQL
}
Function ActualizarVersionBC365140{
    $VersionNAV                  = 'BC140'
    $RutaApplication             = '\\tipsa.local\tipsa\CD Producto NAV\BC140\' +$CUNuevaBC140 + '\APPLICATION\*' 
    foreach ($Fichero in (Get-Item -path $RutaApplication -Filter *.fob))
      {
      $IdCompilacion = $Fichero.Name.Split(".")[3]
      }
    $RutaAccesos                 = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\Links\NAV\BC140\'
    $RutaRTCVersionAnterior      = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\BC365\140\RoleTailored Client ' + $CUAnteriorBC140
    $RutaRTCVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\BC365\140\RoleTailored Client ' + $CUNuevaBC140
    $RutaRTCProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\BC140\' + $CUNuevaBC140 + '\DVD\RoleTailoredClient\program files\Microsoft Dynamics NAV\140\RoleTailored Client'
    $FicheroObjetosOrigenFob     = '\\Tipsa.local\tipsa\CD Producto NAV\BC140\' + $CUNuevaBC140 + '\APPLICATION\Dynamics.365.BC.' + $IdCompilacion +'.ES.CUObjects.fob'
    $FicheroObjetosOrigenTxt     = '\\Tipsa.local\tipsa\CD Producto NAV\BC140\' + $CUNuevaBC140 + '\APPLICATION\Dynamics.365.BC.' + $IdCompilacion +'.ES.CUObjects.txt'
    $FicheroObjetosDestinoTxt    = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\PowerShell\Migracion\Objetos\BC140 ' + $CUNuevaBC140 + '.txt'
    $NombreServidor              = 'VORTEX\SQL2K17'
    $NombreBBDD                  = 'CRONUS140'
    $RutaNavModelToolPS1         = 'C:\Program Files (x86)\Microsoft Dynamics NAV\140\RoleTailored Client\NavModelTools.ps1'
    $RutaSTXProductoVersionNueva = '\\Tipsa.local\tipsa\CD Producto NAV\BC140\' + $CUNuevaBC140 + '\DVD\Installers\ES\RTC\PFiles\Microsoft Dynamics NAV\140\RoleTailored Client\ESP'
    $RutaSTXVersionNueva         = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\BC365\140\RoleTailored Client ' + $CUNuevaBC140 +'\ES'

    Write-Host ''
    Write-Host -foregroundcolor Yellow 'ACTUALIZANDO VERSION BC365 140'
    CopiarDirectorio $RutaRTCVersionAnterior $RutaRTCVersionNueva    
    CopiarDirectorio $RutaRTCProductoVersionNueva $RutaRTCVersionNueva
    CopiarDirectorio $RutaSTXProductoVersionNueva $RutaSTXVersionNueva
    ActualizarAccesosDirectosNAV $CUAnteriorBC140 $CUNuevaBC140 $RutaAccesos
    ActualizarAccesosDirectosCronus $CUAnteriorBC140 $CUNuevaBC140 $MesAnterior $AnoAnterior $MesNuevo $AnoNuevo $RutaAccesosCronus
    ActualizarFicheroVersiones $VersionNAV $CUNuevaBC140 $IdCompilacion $MesNuevo $AnoNuevo
    CopiarFicheroApplicacionAPowerShell $FicheroObjetosOrigenTxt $FicheroObjetosDestinoTxt
    # ActualizarObjetos $FicheroObjetosOrigenFob $NombreServidor $NombreBBDD $RutaNavModelToolPS1 $RutaFinSQL
}
Function CopiarDirectorio{
    Param([string]$DirectorioOrigen,
          [string]$DirectorioDestino)

    Write-Host -foregroundcolor Yellow '  Copiando ' $DirectorioOrigen 
    foreach ($dir in (Get-ChildItem -Path $DirectorioOrigen))
    {
        $Destino = join-path $DirectorioDestino $dir.Name
        if (Test-Path -path $Destino -PathType Container)
        {
            foreach ($subItem in (Get-ChildItem -Path $dir.FullName))
            {
                Copy-Item -Path $subItem.FullName -Destination $Destino -Recurse -Force
            }
        }
        else
        {
            Copy $dir.FullName -Destination $Destino -Recurse
        }
    }
}
Function ActualizarAccesosDirectosNAV{
    Param([string]$CUAnterior,
          [string]$CUNueva,
          [string]$RutaAccesos)
    
    Write-Host -foregroundcolor Yellow '  Actualizando Links Estandar ' $RutaAccesos
    $AccesoDirectoAnterior = $RutaAccesos + $VersionNAV + ' ' + $CUAnterior + ' Dev.lnk'
    $AccesoDirectoNuevo    = $RutaAccesos + $VersionNAV + ' ' + $CUNueva + ' Dev.lnk'
    if (Test-Path -path $AccesoDirectoAnterior)
        {
        Copy-Item $AccesoDirectoAnterior $AccesoDirectoNuevo -Force
        ModificarAccesoDirecto $AccesoDirectoNuevo $CUAnterior $CUNueva
        }
    
    $AccesoDirectoAnterior = $RutaAccesos + $VersionNAV + ' ' + $CUAnterior + '.lnk'
    $AccesoDirectoNuevo    = $RutaAccesos + $VersionNAV + ' ' + $CUNueva + '.lnk'
    if (Test-Path -path $AccesoDirectoAnterior)
        {
        Copy-Item $AccesoDirectoAnterior $AccesoDirectoNuevo -Force
        ModificarAccesoDirecto $AccesoDirectoNuevo $CUAnterior $CUNueva
        }
}
Function ActualizarAccesosDirectosCronus{
    Param([string]$CUAnterior,
          [string]$CUNueva,
          [string]$MesAnterior,
          [string]$AnoAnterior,
          [string]$MesNuevo,
          [string]$AnoNuevo,
          [string]$RutaAccesos)

    Write-Host -foregroundcolor Yellow '  Actualizando Links Cronus ' $RutaAccesos
    $AccesoDirectoAnterior = $RutaAccesos + 'Cronus ' + $VersionNAV + ' ' + $CUAnterior + ' ' + $MesAnterior + $AnoAnterior + ' Dev.lnk'
    $AccesoDirectoNuevo    = $RutaAccesos + 'Cronus ' + $VersionNAV + ' ' + $CUNueva + ' ' + $MesNuevo + $AnoNuevo + ' Dev.lnk'
    if (Test-Path -path $AccesoDirectoAnterior)
       {
       Copy-Item $AccesoDirectoAnterior $AccesoDirectoNuevo -Force
       Remove-Item $AccesoDirectoAnterior
       ModificarAccesoDirecto $AccesoDirectoNuevo $CUAnterior $CUNueva
       }
    
    $AccesoDirectoAnterior = $RutaAccesos + 'Cronus ' + $VersionNAV + ' ' + $CUAnterior + ' ' + $MesAnterior + $AnoAnterior + '.lnk'
    $AccesoDirectoNuevo    = $RutaAccesos + 'Cronus ' + $VersionNAV + ' ' + $CUNueva + ' ' + $MesNuevo + $AnoNuevo + '.lnk'
    if (Test-Path -path $AccesoDirectoAnterior)
       {
        Copy-Item $AccesoDirectoAnterior $AccesoDirectoNuevo -Force
        Remove-Item $AccesoDirectoAnterior
        ModificarAccesoDirecto $AccesoDirectoNuevo $CUAnterior $CUNueva
       }
}
Function ModificarAccesoDirecto{
    Param([string]$RutaAccesoDirecto,
          [string]$CUAnterior,
          [string]$CUNueva)

    $Shell = New-Object -COM WScript.Shell
    $Shortcut = $shell.CreateShortcut($RutaAccesoDirecto)  # Open the lnk
    $Shortcut.TargetPath = $Shortcut.TargetPath -replace $CUAnterior,$CUNueva
    $Shortcut.Description =  $Shortcut.Description -replace $CUAnterior,$CUNueva
    $Shortcut.Save()

}
Function ActualizarFicheroVersiones{
    Param([string] $VersionNAV,
          [string] $CU,
          [string] $IdCompilacion,
          [string] $Mes,
          [string] $Ano)
    $FicheroVersiones = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\Links\Desarrollo\Versiones NAV.txt'
    Write-Host -foregroundcolor Yellow '  Actualizando Fichero de versiones ' $FicheroVersiones
    Add-Content $FicheroVersiones ($IdCompilacion + ' ' + $VersionNAV + ' ' + $CU + ' ' + $Mes + $Ano)

}
Function ActualizarObjetos{
    Param([string]$FicheroObjetos,
          [string]$NombreServidor,
          [string]$NombreBBDD,
          [string]$RutaNavModelToolPS1,
          [string]$RutaFinSQL)

    Write-Host -foregroundcolor Yellow '  Actualizando objetos ' + $FicheroObjetos
    $null = Import-Module $RutaNavModelToolPS1
    $NavIde = $RutaFinSQL
    Import-NAVApplicationObject -DatabaseServer $NombreServidor -DatabaseName $NombreBBDD -Path $FicheroObjetos -ImportAction Overwrite
}
Function CopiarFicheroApplicacionAPowerShell{
    Param([string]$FicheroOrigen,
          [string]$FicheroDestino)
    Copy-Item -Path $FicheroOrigen -Destination $FicheroDestino
}

$NoMesNuevo        = 7
$NoAnoNuevo        = 20

# $NoCUNueva2015     = 63
# $NoCUNueva2016     = 56 # 56 = Junio 2020
# $NoCUNueva2017     = 43 # 43 = Junio 2020
# $NoCUNueva2018     = 30 # 30 = Junio 2020
# $NoCUNuevaBC365    = 18
$NoCUNuevaBC140    = 17 

# Variables comunes ===============================================================================================================================================================
$FicheroVersiones  = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\Links\Desarrollo\Versiones NAV.txt'
$RutaAccesosCronus = '\\tipsa.local\tipsa\CD Producto NAV\Utilidades\RoleTailored Clients\Links\Estándar\Cronus\'

$CUNueva2015       = 'CU' + $NoCUNueva2015
$CUAnterior2015    = 'CU' + ($NoCUNueva2015 - 1)

$CUNueva2016       = 'CU' + $NoCUNueva2016
$CUAnterior2016    = 'CU' + ($NoCUNueva2016 - 1)

$CUNueva2017       = 'CU' + $NoCUNueva2017
$CUAnterior2017    = 'CU' + ($NoCUNueva2017 - 1)

if ($NoCUNueva2018 -lt 10)
    {
    $CUNueva2018       = 'CU0' + $NoCUNueva2018
    $CUAnterior2018    = 'CU0' + ($NoCUNueva2018 - 1)
    }
else 
    {
    if ($NoCUNueva2018 -eq 10)
        {
        $CUNueva2018       = 'CU' + $NoCUNueva2018
        $CUAnterior2018    = 'CU0' + ($NoCUNueva2018 - 1)
        }
    else
        {
        $CUNueva2018       = 'CU' + $NoCUNueva2018
        $CUAnterior2018    = 'CU' + ($NoCUNueva2018 - 1)
        }
    }

if ($NoCUNuevaBC365 -lt 10)
    {
    $CUNuevaBC365       = 'CU0' + $NoCUNuevaBC365
    $CUAnteriorBC365    = 'CU0' + ($NoCUNuevaBC365 - 1)
    }
else 
    {
    if ($NoCUNuevaBC365 -eq 10)
        {
        $CUNuevaBC365       = 'CU' + $NoCUNuevaBC365
        $CUAnteriorBC365    = 'CU0' + ($NoCUNuevaBC365 - 1)
        }
    else
        {
        $CUNuevaBC365       = 'CU' + $NoCUNuevaBC365
        $CUAnteriorBC365    = 'CU' + ($NoCUNuevaBC365 - 1)
        }
    }


if ($NoCUNuevaBC140 -lt 10)
    {
    $CUNuevaBC140       = 'CU0' + $NoCUNuevaBC140
    $CUAnteriorBC140    = 'CU0' + ($NoCUNuevaBC140 - 1)
    }
else 
    {
    if ($NoCUNuevaBC140 -eq 10)
        {
        $CUNuevaBC140       = 'CU' + $NoCUNuevaBC140
        $CUAnteriorBC140    = 'CU0' + ($NoCUNuevaBC140 - 1)
        }
    else
        {
        $CUNuevaBC140       = 'CU' + $NoCUNuevaBC140
        $CUAnteriorBC140    = 'CU' + ($NoCUNuevaBC140 - 1)
        }
    }
# Busqueda años y meses ===================================================================================================================================================

    switch ($NoMesNuevo)
    {
        1  {$MesNuevo = 'Ene'}
        2  {$MesNuevo = 'Feb'}
        3  {$MesNuevo = 'Mar'}
        4  {$MesNuevo = 'Abr'}
        5  {$MesNuevo = 'May'}
        6  {$MesNuevo = 'Jun'}
        7  {$MesNuevo = 'Jul'}
        8  {$MesNuevo = 'Ago'}
        9  {$MesNuevo = 'Sep'}
        10 {$MesNuevo = 'Oct'}
        11 {$MesNuevo = 'Nov'}
        12 {$MesNuevo = 'Dic'}
     }
    switch ($NoMesNuevo)
    {
        1  {$MesAnterior = 'Dic'}
        2  {$MesAnterior = 'Ene'}
        3  {$MesAnterior = 'Feb'}
        4  {$MesAnterior = 'Mar'}
        5  {$MesAnterior = 'Abr'}
        6  {$MesAnterior = 'May'}
        7  {$MesAnterior = 'Jun'}
        8  {$MesAnterior = 'Jul'}
        9  {$MesAnterior = 'Ago'}
        10 {$MesAnterior = 'Sep'}
        11 {$MesAnterior = 'Oct'}
        12 {$MesAnterior = 'Nov'}
    }
    if ($NoMesNuevo -eq 1) {
        $AnoNuevo = $NoAnoNuevo
        $AnoAnterior = $NoAnoNuevo - 1
    } else {
        $AnoNuevo = $NoAnoNuevo
        $AnoAnterior = $NoAnoNuevo
    }


# Proceso ========================================================================================================================================================================
CLS
$HoraComienzo = Get-Date

# ActualizarVersion2015
# ActualizarVersionBC365130

# ActualizarVersion2016 # Ultima Actualización Junio 2020
# ActualizarVersion2017 # Ultima Actualización Junio 2020
# ActualizarVersion2018 # Ultima Actualización Junio 2020
ActualizarVersionBC365140

$HoraFinal = Get-Date
echo ''
echo ("Actualización - Comienzo : " + $HoraComienzo)
echo ("Actualización - Final    : " + $HoraFinal)
