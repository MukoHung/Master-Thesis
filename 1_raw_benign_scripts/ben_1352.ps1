{$_.Creationtime -lt (Get-Date).AddDays(-90)} | 
  ForEach-Object {
    Move-Item -Force -Recurse -Path $_.FullName -Destination $($_.FullName.Replace("C:\Application\Log","\\NASServer\Archives"))
    
  }