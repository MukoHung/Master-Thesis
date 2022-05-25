if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
Write-Host ""
Write-Host "Change DNS Server Settings for Wi-Fi"
Write-Host ""
Write-Host "Enter your Choice: "
Write-Host "1. AdGuard DNS"
Write-Host "2. AdGuard Family Protection DNS"
Write-Host "3. Reset DNS to default"
Write-Host "0. Exit"
Write-Host ""
$Input = Read-Host -Prompt 'Input your choice'
Write-Host ""
if($Input -eq 1){
   Set-DnsClientServerAddress -InterfaceAlias Wi-Fi -ServerAddresses "94.140.14.14","94.140.15.15"
   write-host("AdGuard DNS enabled.")
   Start-Sleep -s 1
}elseif($Input -eq 2){
   Set-DnsClientServerAddress -InterfaceAlias wi-fi -ServerAddresses "94.140.14.15","94.140.15.16"
   write-host("AdGuard Family DNS enabled.")
   Start-Sleep -s 1
}elseif($Input -eq 3){
   Set-DnsClientServerAddress -InterfaceAlias wi-fi -ResetServerAddresses
   write-host("DNS Reset")
   Start-Sleep -s 1
}elseif($Input -eq 0){
   Break
}else {
   write-host("Wrong Input")
   Start-Sleep -s 1
   Break
}