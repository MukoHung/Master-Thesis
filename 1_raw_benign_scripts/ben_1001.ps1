function InstallAzModule{
  param(
      [string] $moduleName,
      [string] $scope
      
  
  )
  if(Get-Module -ListAvailable -Name $moduleName)
  {
      Import -Module $moduleName
   }
   else{
          Install-Module $moduleName -Scope $scope -Force
          Import-Module $moduleName
   }
  
 }

 Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser $DebugPreference
  
InstallAzModule -moduleName "Az" -scope "CurrentUser" -Repository PSGallery -Force  
 
 
function InstallGoogleChrome {

        mkdir -Path $env:temp\chromeinstall -erroraction $DebugPreference | Out-Null
      $Download = join-path $env:temp\chromeinstall chrome_installer.exe
      }
        Invoke-WebRequest 'https://raw.githubusercontent.com/AkhilV11/Custom-Script-Extension/main/Chrome-Extension.ps1'


        InstallAzModule
        InstallGoogleChrome
        
