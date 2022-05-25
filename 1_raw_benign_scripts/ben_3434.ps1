<#
.DESCRIPTION
  Copies the Windows Spotlight lock screen images in Windows 10 to a "Windows Spotlight" folder in My Pictures.
  
  This script will intelligently sort through the temporary directory and will only copy images
  that are 1920x1080. Since the filenames of the images can change, the script will also compare
  SHA1 hashes of the existing so we don't copy duplicates.

.NOTES
  Version:        1.0.2
  Author:         jcefoli
  Creation Date:  3/14/2016
  
  Only tested in Powershell 4 on Windows 10

.EXAMPLE
  Run from the Command Prompt (As Admin) like so:

  Straight from GitHub:
    @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://gist.githubusercontent.com/jcefoli/8a7c59e9a5ed3ce9840b/raw/SaveSpotlightImages.ps1'))"

  Local Path (assumes you download the script to the C:\ root)"
    @powershell -NoProfile -ExecutionPolicy Bypass C:\SaveSpotlightImages.ps1
#>
$StartTime = Get-Date

###------------------------------------------------------------------------------------------###
###                SET IMAGE COPY LOCATION HERE                                              ###
###   Defaults to "Windows Spotlight" folder in your Pictures                                ###
$imageRestorePath = "$env:systemdrive\Users\$Env:username\Pictures\Windows Spotlight"
###------------------------------------------------------------------------------------------###


#Clear terminal and add loading message
Clear-Host
Write-Host ""
Write-Host " Working some magic. Please wait! "
Write-Host ""

#Load system.drawing Assembly
[void][reflection.assembly]::loadwithpartialname("system.drawing")


#Function to Get Image Metadata
function Get-Image{ 
  process {
    $file = $_
    [Drawing.Image]::FromFile($_.FullName)  |
    ForEach-Object{           
      $_ | Add-Member -PassThru NoteProperty FullName ('{0}' -f $file.FullName)
      $_.Dispose()
    }
  }
}


#Create Temporary Directory
$checkDir = Test-Path $env:TEMP\bgtempimages
If ($checkDir -eq $False){
  New-Item $env:TEMP\bgtempimages -Type directory | Out-Null
}
Else {
  $fso = New-Object -ComObject scripting.filesystemobject
  $fso.DeleteFolder("$env:TEMP\bgtempimages*")
}


#Copy Assets from Windows Location to Temp Directory
Copy-Item $env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets\* -Destination $env:TEMP\bgtempimages\


#Add .jpg Extension to Files
Get-ChildItem -Path "$env:TEMP\bgtempimages" | Rename-Item -newname  { $_.Name + ".jpg" }


#Detect and Remove Rogue XML Files
$tempFileList = Get-ChildItem -Path "$env:TEMP\bgtempimages" | select FullName
ForEach ($file in $tempFileList) { 
  $isXML = [bool]((Get-Content $file.FullName) -as [xml])
  if ($isXML -eq $True) {
    Remove-Item $file.FullName
  }
}


#Create Permanent Background Images Directory if it Doesn't Exist
$checkDir = Test-Path $imageRestorePath
If ($checkDir -eq $False){
  New-Item $imageRestorePath -Type directory | Out-Null
}
Else {
  #Folder Exists, so grab the SHA1 hashes of all the existing images so we don't copy duplicate backgrounds with different filenames
  $existingImageObjects = Get-ChildItem -Path $imageRestorePath | select -expa Fullname

  #Add all hashes in the permanent image directory to $existingHashesArray
  $existingHashesArray = @()
  ForEach ($filepath in $existingImageObjects ) {
    $existingHashesArray += Get-FileHash -Path $filepath -Algorithm SHA1
  }
}


#Detect images that are 1920x1080 (The background images we want to move)
$imageObjectsToCopy = Get-ChildItem -Path "$env:TEMP\bgtempimages" -Filter *.* -Recurse  | Get-Image | ? { $_.Width -eq 1920 -or $_.Height -eq 1080 } | select -expa Fullname


#Get the Hashes of those 1920x1080 images and store in $newImageHashArray
$newImageHashArray = @()
ForEach ($filepath in $imageObjectsToCopy ) { 
  $newImageHashArray += Get-FileHash -Path $filepath -Algorithm SHA1
}


#Loop through Temp Images To Copy
$i = 0
$newImageHashArray | foreach {
  if ($existingHashesArray.Hash -Contains $_.Hash){
    #Found duplicate hash in existing directory, do not copy new image over
  }
  Else {
    #New background found! Copy it over
    Copy-Item $_.Path -Destination $imageRestorePath
    $i = $i + 1
  }
}


#Status output
$FinishTime = Get-Date
$TotalTime = ($FinishTime - $StartTime).TotalMilliseconds

if ($i -eq 0) {
  Write-host "[Done] - No images copied. Took $TotalTime ms." -foregroundcolor "Yellow"
}
ElseIF ($i -eq 1){
  Write-host "[Done] - Copied $i image. Took $TotalTime ms." -foregroundcolor "Green"
}
Else{
  Write-host "[Done] - Copied $i images. Took $TotalTime ms." -foregroundcolor "Green"
}


#Delete Temp Folder
$fso = New-Object -ComObject scripting.filesystemobject
$fso.DeleteFolder("$env:TEMP\bgtempimages*")