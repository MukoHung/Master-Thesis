




























































































































CISBenchmarksWindows10/CISBenchmarkWindows.ps1 at b065d28fe21263a792efa6555fc5b72f322f0fae · Anitalex/CISBenchmarksWindows10


















































Skip to content













 


 





























        In this repository
      

        All GitHub
      
↵


      Jump to
      ↵






No suggested jump to results





















        In this repository
      

        All GitHub
      
↵


      Jump to
      ↵





















        In this user
      

        All GitHub
      
↵


      Jump to
      ↵





















        In this repository
      

        All GitHub
      
↵


      Jump to
      ↵












 



        Dashboard


        Pull requests


      Issues



          Marketplace
 

      Explore


      Codespaces

Sponsors

      Settings



      MukoHung






        Sign out
      
























 



  New repository


    Import repository
  

  New gist


    New organization
  






















          Sorry, something went wrong.
        









































/  ...  /  
Anitalex  /  
CISBenchmarksWind...  /  













Clear





Tip:
                    Type # to search pull requests
                

                  Type ? for help and tips
                





Tip:
                    Type # to search issues
                

                  Type ? for help and tips
                





Tip:
                    Type # to search discussions
                

                  Type ? for help and tips
                





Tip:
                    Type ! to search projects
                

                  Type ? for help and tips
                





Tip:
                    Type @ to search teams
                

                  Type ? for help and tips
                





Tip:
                    Type @ to search people and organizations
                

                  Type ? for help and tips
                





Tip:
                    Type > to activate command mode
                

                  Type ? for help and tips
                





Tip:
                    Go to your accessibility settings to change your keyboard shortcuts
                

                  Type ? for help and tips
                





Tip:
                    Type author:@me to search your content
                

                  Type ? for help and tips
                





Tip:
                    Type is:pr to filter to pull requests
                

                  Type ? for help and tips
                





Tip:
                    Type is:issue to filter to issues
                

                  Type ? for help and tips
                





Tip:
                    Type is:project to filter to projects
                

                  Type ? for help and tips
                





Tip:
                    Type is:open to filter to open content
                

                  Type ? for help and tips
                









              We’ve encountered an error and some results aren't available at this time. Type a new search or try again later.
            


            No results matched your search
          



              Top result
            








              Commands
            

              Type > to filter
            






              Global Commands
            

              Type > to filter
            






              Files
            








              Pages
            








              Access Policies
            








              Organizations
            








              Repositories
            








              Issues, pull requests, and discussions
            

              Type # to filter
            






              Teams
            








              Users
            








              Projects
            











              Modes
            








              Use filters in issues, pull requests, discussions, and projects
            







































































Search for issues and pull requests

#



Search for issues, pull requests, discussions, and projects

#



Search for organizations, repositories, and users

@



Search for projects

!



Search for files

/



Activate command mode

>



Search your issues, pull requests, and discussions

# author:@me



Search your issues, pull requests, and discussions

# author:@me



Filter to pull requests

# is:pr



Filter to issues

# is:issue



Filter to discussions

# is:discussion



Filter to projects

# is:project



Filter to open issues, pull requests, and discussions

# is:open











































































Anitalex

/

CISBenchmarksWindows10

Public






 




              Unwatch
            




              Stop ignoring
            




              Watch
            

2





Notifications

















                      Participating and @mentions
                    

                      Only receive notifications from this repository when participating or @mentioned.
                    










                      All Activity
                    

                      Notified of all notifications on this repository.
                    










                      Ignore
                    

                      Never be notified.
                    











Custom







                    Select events you want to be notified of in addition to participating and @mentions.
                  









                    Get push notifications on iOS or Android.
                  















                  Custom
                








                  Custom
                




                    Select events you want to be notified of in addition to participating and @mentions.
                  






                      Issues
                    




                      Pull requests
                    




                      Releases
                    




                      Discussions
                    









                      Security alerts
                    



  Apply

  Cancel


 







 

Fork
          0








 


          Starred
 0



 


          Star
 0


 


 



































Code







Issues
0






Pull requests
0






Actions







Projects
0






Wiki







Security






Insights



 
 



More


 



                    Code
 


                    Issues
 


                    Pull requests
 


                    Actions
 


                    Projects
 


                    Wiki
 


                    Security
 


                    Insights
 







Open in github.dev
Open in a new github.dev tab

Permalink







b065d28fe2





Switch branches/tags










Branches
Tags















View all branches















View all tags









CISBenchmarksWindows10/CISBenchmarkWindows.ps1


        Go to file
      

 



 


Go to file
T
 

 
Go to line
L

 



    
                Copy path

 



Copy permalink

 


 





This commit does not belong to any branch on this repository, and may belong to a fork outside of the repository.









Anitalex

Added a new script to install sysmon and run it with the config







Latest commit
b065d28
on 28 Apr 2021






History











1
        
        contributor
      








            Users who have contributed to this file
          















      322 lines (286 sloc)
      
    16.7 KB
  


  Raw
   Blame
 






























              View raw
            





                View blame
              












# This script needs to be run as administrator













# enable advanced auditing



Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\" -Name "SCENoApplyLegacyAuditPolicy" -Value 1













#region auditLogs








# Account Logon



Auditpol /set /subcategory:"Credential Validation" /success:enable /failure:enable



Auditpol /set /subcategory:"Kerberos Authentication Service" /success:disable /failure:disable



Auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:disable /failure:disable



Auditpol /set /subcategory:"Other Account Logon Events" /success:enable /failure:enable



# Account Management



Auditpol /set /subcategory:"Application Group Management" /success:enable /failure:enable



Auditpol /set /subcategory:"Computer Account Management" /success:enable /failure:enable



Auditpol /set /subcategory:"Distribution Group Management" /success:enable /failure:enable



Auditpol /set /subcategory:"Other Account Management Events" /success:enable /failure:enable



Auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable



Auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable



# Detailed Tracking



Auditpol /set /subcategory:"DPAPI Activity" /success:disable /failure:disable



Auditpol /set /subcategory:"Plug and Play Events" /success:enable 



Auditpol /set /subcategory:"Process Creation" /success:enable /failure:enabley



Auditpol /set /subcategory:"Process Termination" /success:disable /failure:disable



Auditpol /set /subcategory:"RPC Events" /success:enable /failure:enable



Auditpol /set /subcategory:"Token Right Adjusted Events" /success:enable



# DS Access



Auditpol /set /subcategory:"Detailed Directory Service Replication" /success:disable /failure:disable



Auditpol /set /subcategory:"Directory Service Access" /success:disable /failure:disable



Auditpol /set /subcategory:"Directory Service Changes" /success:enable /failure:enable



Auditpol /set /subcategory:"Directory Service Replication" /success:disable /failure:disable



# Logon/Logoff



Auditpol /set /subcategory:"Account Lockout" /success:enable



Auditpol /set /subcategory:"Group Membership" /success:enable 



Auditpol /set /subcategory:"IPsec Extended Mode" /success:disable /failure:disable



Auditpol /set /subcategory:"IPsec Main Mode" /success:disable /failure:disable



Auditpol /set /subcategory:"IPsec Quick Mode" /success:disable /failure:disable



Auditpol /set /subcategory:"Logoff" /success:enable 



Auditpol /set /subcategory:"Logon" /success:enable /failure:enable



Auditpol /set /subcategory:"Network Policy Server" /success:enable /failure:enable



Auditpol /set /subcategory:"Other Logon/Logoff Events" /success:enable /failure:enable



Auditpol /set /subcategory:"Special Logon" /success:enable /failure:enable



Auditpol /set /subcategory:"User / Device Claims" /success:disable /failure:disable



# Object Access



Auditpol /set /subcategory:"Application Generated" /success:enable /failure:enable



Auditpol /set /subcategory:"Certification Services" /success:enable /failure:enable



Auditpol /set /subcategory:"Central Policy Staging" /success:disable /failure:disable



Auditpol /set /subcategory:"Detailed File Share" /success:enable 



Auditpol /set /subcategory:"File Share" /success:enable /failure:enable



Auditpol /set /subcategory:"File System" /success:enable 



Auditpol /set /subcategory:"Filtering Platform Connection" /success:enable



Auditpol /set /subcategory:"Filtering Platform Packet Drop" /success:disable /failure:disable



Auditpol /set /subcategory:"Handle Manipulation" /success:disable /failure:disable



Auditpol /set /subcategory:"Kernel Object" /success:disable /failure:disable



Auditpol /set /subcategory:"Other Object Access Events" /success:disable /failure:disable



Auditpol /set /subcategory:"Removable Storage" /success:enable /failure:enable



Auditpol /set /subcategory:"Registry" /success:enable



Auditpol /set /subcategory:"SAM" /success:enable



# Policy Change



Auditpol /set /subcategory:"Audit Policy Change" /success:enable /failure:enable



Auditpol /set /subcategory:"Authentication Policy Change" /success:enable /failure:enable



Auditpol /set /subcategory:"Authorization Policy Change" /success:enable /failure:enable



Auditpol /set /subcategory:"Filtering Platform Policy Change" /success:enable



Auditpol /set /subcategory:"MPSSVC Rule-Level Policy Change" /success:disable /failure:disable



Auditpol /set /subcategory:"Other Policy Change Events" /success:disable /failure:disable



# Privilege Use



Auditpol /set /subcategory:"Non Sensitive Privilege Use" /success:disable /failure:disable



Auditpol /set /subcategory:"Other Privilege Use Events" /success:disable /failure:disable



Auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable



# System



Auditpol /set /subcategory:"IPsec Driver" /success:enable



Auditpol /set /subcategory:"Other System Events" /failure:enable



Auditpol /set /subcategory:"Security State Change" /success:enable /failure:enable



Auditpol /set /subcategory:"Security System Extension" /success:enable /failure:enable



Auditpol /set /subcategory:"System Integrity" /success:enable /failure:enable








#endregion








#region EventLogSizes



wevtutil sl Application /ms:67108864 /rt:false /ab:false



wevtutil sl System /ms:67108864 /rt:false /ab:false



wevtutil sl Security /ms:134217728 /rt:false /ab:false



wevtutil sl 'Windows PowerShell' /ms:67108864 /rt:false /ab:false



wevtutil sl PowerShellCore/Operational /ms:67108864 /rt:false /ab:false













<#



wevtutil gl Application



wevtutil gl System



wevtutil gl Security



wevtutil gl 'Windows PowerShell'



#>



#endregion













#region WindowsPowershellLogging



# Module Logging



if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging").EnableModuleLogging -eq 1){



 Write-Host "EnableModuleLogging already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging"){



 Write-Host "Powershell Module Logging registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name "EnableModuleLogging" -Value 1



}








if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames").'*' -eq '*'){



 Write-Host "Module Names logging already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging"){



 Write-Host "Powershell Module Logging registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames"){



 Write-Host "Powershell Module Names registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" -Name '*' -Value '*'



}













# Script Block Logging



if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging").EnableScriptBlockLogging -eq 1){



 Write-Host "EnableScriptBlockLogging already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"){



 Write-Host "Powershell Script Block Logging registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1



}













# Transcription








if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription").EnableTranscripting -eq 1){



 Write-Host "EnableTranscripting already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription"){



 Write-Host "Powershell Transcription registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription" -Name "EnableTranscripting" -Value 1



}








if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription").EnableInvocationHeader -eq 1){



 Write-Host "EnableInvocationHeader already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription"){



 Write-Host "Powershell Transcription registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription" -Name "EnableInvocationHeader" -Value 1



}








if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription").OutputDirectory -eq 1){



 Write-Host "OutputDirectory already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription"){



 Write-Host "Powershell Transcription registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription" -Name "OutputDirectory" -Value 'c:\Logs'



}








#endregion








#region PowershellCoreLogging








# Module Logging



if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging").EnableModuleLogging -eq 1){



 Write-Host "EnableModuleLogging already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging"){



 Write-Host "Powershell Module Logging registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging" -Name "EnableModuleLogging" -Value 1



}








if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging\ModuleNames").'*' -eq '*'){



 Write-Host "Module Names logging already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging"){



 Write-Host "Powershell Module Logging registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging\ModuleNames"){



 Write-Host "Powershell Module Names registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging\ModuleNames"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging\ModuleNames" -Name '*' -Value '*'



}








# Script Block Logging



if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ScriptBlockLogging").EnableScriptBlockLogging -eq 1){



 Write-Host "EnableScriptBlockLogging already is on for PowerShell Core"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"){



 Write-Host "PowershellCore registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ScriptBlockLogging"){



 Write-Host "PowershellCore ScriptBlockLogging registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ScriptBlockLogging"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1



}








# Transcription








if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription").EnableTranscripting -eq 1){



 Write-Host "EnableTranscripting already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription"){



 Write-Host "Powershell Transcription registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription" -Name "EnableTranscripting" -Value 1



}








if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription").EnableInvocationHeader -eq 1){



 Write-Host "EnableInvocationHeader already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription"){



 Write-Host "Powershell Transcription registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription" -Name "EnableInvocationHeader" -Value 1



}








if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription").OutputDirectory -eq 1){



 Write-Host "OutputDirectory already is on"



} else {



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"){



 Write-Host "Powershell registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore"



    }



 if(Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription"){



 Write-Host "Powershell Transcription registry key exists"



    } else {



 New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription"



    }



 New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\Transcription" -Name "OutputDirectory" -Value 'c:\Logs'



}








#endregion
















































            Copy lines
          



            Copy permalink
          

View git blame
Reference in new issue










  Go

 















 
        © 2022 GitHub, Inc.
        



Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About















    You can’t perform that action at this time.
  




You signed in with another tab or window. Reload to refresh your session.
You signed out in another tab or window. Reload to refresh your session.








