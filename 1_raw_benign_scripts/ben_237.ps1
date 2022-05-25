<#
User Details
	Name
	Description
	Profile Path
	Home Drive
	Account Disabled
	Password Required
	User Changable Password
	Password Expires
	SmartCard Required
	Login Count
	Last Login (date)
	Last Password Change (date)
	Created (date)
	Modified (date)
	Script Configuration

Before running this script there is some minor configuration that must be done so it can communicate with your Active Directory setup.
	- Find objConnection.Open “Active Directory Server” change Active Directory Server to the name of your Domain Controller
	- Find objCommand.CommandText = “SELECT Name, description, profilePath, homeDrive, distinguishedName,userAccountControl FROM ‘LDAP://dc=subdomain,dc=domain,dc=suffix’ WHERE objectCategory=’user'” change subdomain, domain, and suffix to the name of your domain i.e. west consco com (respectively)
	- Find Set logStream = objFSO.opentextfile(“C:\domainusers.csv”, 8, True) and change C:\domainusers.csv to the location where you want the file saved. Be sure to save it with the extension CSV
#>

On Error Resume Next
Const ADS_SCOPE_SUBTREE = 2
 
Const ADS_UF_ACCOUNTDISABLE = &H0002
Const ADS_UF_PASSWD_NOTREQD = &H0020
Const ADS_UF_PASSWD_CANT_CHANGE = &H0040
Const ADS_UF_DONT_EXPIRE_PASSWD = &H10000
Const ADS_UF_SMARTCARD_REQUIRED = &H40000
  
Set objConnection = CreateObject("ADODB.Connection")
Set objCommand =   CreateObject("ADODB.Command")
objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Server"
Set objCommand.ActiveConnection = objConnection
 
objCommand.Properties("Page Size") = 1000
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE
 
objCommand.CommandText = _
    "SELECT Name, description, profilePath, homeDrive, distinguishedName,userAccountControl FROM 'LDAP://dc=subdomain,dc=domain,dc=suffix' WHERE objectCategory='user'" 
Set objRecordSet = objCommand.Execute
 
objRecordSet.MoveFirst
Set objFSO = CreateObject("scripting.filesystemobject")
Set logStream = objFSO.opentextfile("C:\domainusers.csv", 8, True)
logStream.writeline("Name,Description,Profile Path,Home Drive,Account Disabled,Password Required,User Changable Password,Password Expires,SmartCard Required,Login Count,Last Login,Last Password Change,Created,Modified")
Do Until objRecordSet.EOF
 
    strDN = objRecordset.Fields("distinguishedName").Value
    Set objUser = GetObject ("LDAP://" & strDN)
      
    If objRecordset.Fields("userAccountControl").Value AND ADS_UF_ACCOUNTDISABLE Then
        Text = "Yes"
    Else
        Text = "No"
    End If
    If objRecordset.Fields("userAccountControl").Value AND ADS_UF_PASSWD_NOTREQD Then
        Text = Text & ",No"
    Else
        Text = Text & ",Yes"
    End If
      
    If objRecordset.Fields("userAccountControl").Value AND ADS_PASSWORD_CANT_CHANGE Then
        Text = Text & ",No"
    Else
        Text = Text & ",Yes"
    End If  
    If objRecordset.Fields("userAccountControl").Value AND ADS_UF_DONT_EXPIRE_PASSWD Then
        Text = Text & ",No"
    Else
        Text = Text & ",Yes"
    End If
    If objRecordset.Fields("userAccountControl").Value AND ADS_UF_SMARTCARD_REQUIRED Then
        Text = Text & ",Yes"
    Else
        Text = Text & ",No"
    End If
     
    logStream.writeline(objRecordset.Fields("Name").Value & ","_
        & objRecordset.Fields("description").Value & ","_
        & objRecordset.Fields("profilePath").Value & ","_
        & objRecordset.Fields("homeDrive").Value & ","_
        & text & ","_
        & objUser.logonCount & ","_
        & objUser.LastLogin & ","_
        & objUser.PasswordLastChanged & ","_
        & objUser.whenCreated & ","_
        & objUser.whenChanged & ","_
        )
         
    objRecordSet.MoveNext
Loop
logStream.Close