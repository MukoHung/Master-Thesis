 # Configure SMB Share and Set permissions  
 New-Item -ItemType Directory -Force -Path "C:\tmp\Share"    
 if(!(Get-SMBShare -Name "Share" -ea 0)){        
     New-SMBShare -Name "Share" -Path "C:\tmp\Share" -Description "A Share"   
 }  
 Get-SmbShareAccess -Name "Share" | Grant-SmbShareAccess -AccountName Everyone -AccessRight Full -Force