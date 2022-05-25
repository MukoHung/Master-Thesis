Set-Alias iiscfg Edit-ApplicationHostsConfig

function Edit-ApplicationHostsConfig {
  $file = Get-ApplicationHostsConfig
  edit $file
}

function Get-ApplicationHostsConfig(){
  $appHostConfig = "C:\Windows\sysnative\inetsrv\config\applicationHost.config"
  $exists = Test-Path $appHostConfig
  if($exists -eq $false){
    $appHostConfig = "C:\Windows\system32\inetsrv\config\applicationHost.config"
  }
  $exists = Test-Path $appHostConfig
  if($exists -eq $false){
    throw "The file applicationHost.config could not be found!"
  }
  return $appHostConfig
}