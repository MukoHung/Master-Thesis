$files = Get-ChildItem "app*.config" -Recurse

$find = 'some-string-to-find'

$replace = 'some-string-to-replace-with'

Get-ChildItem $files -Recurse |
select -ExpandProperty fullname |
foreach {
     If(Select-String -Path $_ -SimpleMatch $find -quiet){
          (Get-Content $_) |
          ForEach-Object {$_ -replace $find, $replace } |
              Set-Content $_ 
              write-host "File Changed : " $_
          } 
     }