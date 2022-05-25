$Ruta = "c:\altadatos.csv"
Import-Csv -Path $Ruta | foreach-object {
  Remove-ADUser -identity $_.CUENTA -Confirm:$false
  $cuenta = $_.cuenta + "$"
  $ruta = "c:\Cuentas\" + $_.cuenta
  Remove-SmbShare -Name $cuenta -force
  remove-item -Path $ruta
}
