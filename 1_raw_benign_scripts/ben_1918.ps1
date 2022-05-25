# Useful scripts for powershell.

## Links
https://stackify.com/powershell-commands-every-developer-should-know/
https://4sysops.com/archives/building-html-reports-in-powershell-with-convertto-html/

## Package management
`
Get-Module -ListAvailable                                                                           
Get-PackageProvider                                                                                 
Find-Package                                                                                        
Get-Module | get-member                                                                             
(Get-Module).RepositorySourceLocation                                                               
(Get-Module -name powershellget).RepositorySourceLocation                                           
Update-Module                                                                                       
Find-Module *ad*                                                                                    
Find-Module *powershell*                                                                            
Find-Module *powershellget*                                                                         
Find-PackageProvider                                                                                
Get-PackageSource                                                                                   
Find-Package -Source psgallery *ad*| Sort-Object -Property Name                                     
`
### Appstore-stuff
Lista bort saker från appstore.
`
Get-AppxPackage| select name
`
### Lista annat
` get-command get*windows* -Type Cmdlet

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Cmdlet          Get-WindowsCapability                              3.0        Dism
Cmdlet          Get-WindowsDeveloperLicense                        1.0.0.0    WindowsDeveloperLicense
Cmdlet          Get-WindowsDriver                                  3.0        Dism
Cmdlet          Get-WindowsEdition                                 3.0        Dism
Cmdlet          Get-WindowsErrorReporting                          1.0        WindowsErrorReporting
Cmdlet          Get-WindowsImage                                   3.0        Dism
Cmdlet          Get-WindowsImageContent                            3.0        Dism
Cmdlet          Get-WindowsOptionalFeature                         3.0        Dism
Cmdlet          Get-WindowsPackage                                 3.0        Dism
Cmdlet          Get-WindowsSearchSetting                           1.0.0.0    WindowsSearch 
`
