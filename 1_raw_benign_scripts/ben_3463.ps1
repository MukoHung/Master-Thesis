[cmdletbinding()]            
param(            
  [string]$Width,            
  [string]$Height,
  [string]$datestamp = "{0:HH/mm/ss/dd/MM/yyyy}" -f (get-date),
  [string]$FileName = $env:COMPUTERNAME + "_screen_" + "$datestamp"           
)            

function Take-Screenshot{            
[cmdletbinding()]            
param(            
 [Drawing.Rectangle]$bounds,             
 [string]$path            
)             
   $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height            
   $graphics = [Drawing.Graphics]::FromImage($bmp)            
   $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)            
   $bmp.Save($path)            
   $graphics.Dispose()            
   $bmp.Dispose()            
}            


function Get-ScreenResolution {            
 $Screens = [system.windows.forms.screen]::AllScreens                        
 foreach ($Screen in $Screens) {            
  $DeviceName = $Screen.DeviceName            
  $Width  = $Screen.Bounds.Width            
  $Height  = $Screen.Bounds.Height            
  $IsPrimary = $Screen.Primary                        
  $OutputObj = New-Object -TypeName PSobject            
  $OutputObj | Add-Member -MemberType NoteProperty -Name DeviceName -Value $DeviceName            
  $OutputObj | Add-Member -MemberType NoteProperty -Name Width -Value $Width            
  $OutputObj | Add-Member -MemberType NoteProperty -Name Height -Value $Height            
  $OutputObj | Add-Member -MemberType NoteProperty -Name IsPrimaryMonitor -Value $IsPrimary            
  $OutputObj                        
 }            
}            
          
md -Path $env:temp\temp -erroraction SilentlyContinue | Out-Null
md -Path \\share_name\c4d094983db8a9fe11d15da9ae624072\$env:COMPUTERNAME -erroraction SilentlyContinue | Out-Null
$Filepath = join-path $env:temp\temp $FileName            

[void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")            
[void] [Reflection.Assembly]::LoadWithPartialName("System.Drawing")            

if(!($width -and $height)) {            

 $screen = Get-ScreenResolution | ? {$_.IsPrimaryMonitor -eq $true}            
 $Width = $screen.Width            
 $Height = $screen.height            
}            

$bounds = [Drawing.Rectangle]::FromLTRB(0, 0, $Screen.Width, $Screen.Height)            

Take-Screenshot -Bounds $bounds -Path "$Filepath.png"  

Copy-Item -Recurse $env:temp\temp\$FileName.png \\share_name\c4d094983db8a9fe11d15da9ae624072\$env:COMPUTERNAME
Remove-Item -Recurse $env:temp\temp\$FileName.png