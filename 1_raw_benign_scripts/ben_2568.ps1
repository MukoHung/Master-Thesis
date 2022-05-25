function New-Password ($Length=60) {
    $characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $random = 1..$Length | ForEach-Object { Get-Random -Maximum $characters.Length }
    $characters[$random] -join ''
}
