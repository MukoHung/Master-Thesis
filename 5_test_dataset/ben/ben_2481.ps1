function Get-AntiVMwithTemperature {
    $t = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi"

    $valorTempKelvin = $t.CurrentTemperature / 10
    $valorTempCelsius = $valorTempKelvin - 273.15

    $valorTempFahrenheit = (9/5) * $valorTempCelsius + 32

    return $valorTempCelsius.ToString() + " C : " + $valorTempFahrenheit.ToString() + " F : " + $valorTempKelvin + "K"  
}
#resource https://medium.com/@DebugActiveProcess