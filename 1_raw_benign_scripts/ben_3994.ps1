  write-host "Remove unattended.xml"
  if ( Test-Path $Env:SystemRoot\\windows\\system32\\Sysprep\\unattend.xml ) { rm $Env:SystemRoot\\windows\\system32\\Sysprep\\unattend.xml -Force}
  & $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit
  
  write-host "SysPrep image"
  while ($true) { 
      $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState 
      if ($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') {
          Write-Output $imageState.ImageState
          Start-Sleep -s 10  
      }
      else { 
          break 
      } 
  }
  
  