# Hieronder alle PowerShell commando's die ik handig vindt en uit het genoemde boek komen.

powershell -nologo
$PSVersionTable.psversion
PowerShell -version 3
PowerShell -psconsolefile myconsole.ps1

Common Parameter Meaning: 
-whatif Tells the cmdlet to not execute, but to tell you what would happen if the cmdlet were to run.
-confim Tells the cmdlet to prompt before executing the command.
-verbose Instructs the cmdlet to provide a higher level of detail than a cmdlet not using the verbose parameter.
-debug Instructs the cmdlet to provide debugging information.
-ErrorAction Instructs the cmdlet to perform a certain action when an error occurs. Allowed actions are continue, stop, silentlyContinue, and inquire.
-ErrorVariable Instructs the cmdlet to use a specifi variable to hold error information. This is in addition to the standard $error variable.
-OutVariable Instructs the cmdlet to use a specifi variable to hold the output information.
-OutBuffer Instructs the cmdlet to hold a certain number of objects before calling the next cmdlet in the pipeline.

# Help
Update-Help

Get-Help Get-PSDrive -examples

Get-Service | Where-Object {$_.Status -eq "Running"}

get-command -Name Get-Service
 
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Cmdlet          Get-Service                                        3.1.0.0    Microsoft.PowerShell.Management

Get-Help Get-Help -Detailed | more

Get-Help Get-Help -full

Get-Help Get-Help -examples

typeperf "\memory\available bytes"

get-date

# List formatting
Get-ChildItem c:\
Get-ChildItem | Format-List
Get-ChildItem C:\ | Format-List -property name, length
Get-ChildItem C:\ | Format-Wide
Get-ChildItem | Format-Wide -Column 3 -Property name
Get-ChildItem | Format-Wide -Property name –AutoSize
Get-ChildItem | Format-Wide -Property name -Column 8

Get-ChildItem C:\Windows
Get-ChildItem C:\Windows -recurse -include *.txt –ea 0
Get-ChildItem C:\Windows -recurse -include *.txt –ea 0| Format-Wide -column 3
Get-ChildItem C:\Windows -recurse -include *.txt -ea 0 | Format-Wide -Column 3 -GroupBy length
 
Get-ChildItem C:\Windows -recurse -include *.txt -ea 0
Get-ChildItem C:\Windows -recurse -include *.txt –ea 0 | Format-Table

# Gridview
gps | out-gridview
gps | ogv
Get-ChildItem C:\Windows -recurse -include *.txt –ea 0 | Out-GridView
Get-Process | ogv

Get-Process | Get-Member
Get-Process | sort-Object cpu
Get-Process | sort-Object cpu -descending
Get-Process | sort-Object cpu -descending | ogv

#Get command
Get-Command *

Get-process winword,explorer
get-process w*
Get-Process | Select-Object name,fileversion,productversion,company
Get-Process explorer | Select-Object name,fileversion,productversion,company


#show aliasses of commands
get-alias g*
gcm get-command
(gcm Get-Command).Definition

# show all commands where the verb starts with se*
gcm -verb se*
# show all commands where the noun starts with o*
gcm -noun o*

gcm -Syntax gcm
gal g* | Sort-Object -property definition

# The Get-Member cmdlet retrieves information about the members of objects. 
Get-ChildItem C:\ | Get-Member
get-alias g*
gci | gm

# Om eigenschappen van een object te kunnen zien, gebruik je de -property attribute
Get-ChildItem -Force | Get-Member -membertype property

# Om methodes/commando's van een object te kunnen zien, gebruik je de -method attribute
Get-ChildItem -Force | Get-Member -membertype Method

# Tellen van verbs
(get-verb | measure-object).count

# Overzicht van gebruikelijke werkwoorden
Get-Verb | where group -match 'common' | Format-Wide verb -auto

# Groeperingen van verbs in specifieke gebieden
Get-Verb | select group -Unique

# Overzicht van alle aantallen verbs en gebruikelijke commando's
Get-Command -CommandType cmdlet | group verb | sort count –Descending
Count Name
----- ----
  256 Get
  142 Set
   94 Remove
   76 New
   64 Add
   25 Enable
   25 Disable
   22 Export
   18 Import
   14 Clear
   13 Invoke
   12 Test
   
(Get-Command -CommandType cmdlet | measure).count

$count = 0 ; Get-Command -CommandType cmdlet | group verb | sort count -Descending | select -First 10 | % { $count += $_.count ; $count } 

# Leer de eerste 10 verbs en je hebt dan meer dan 50% van de mogelijkheden onder bereik

get-executionpolicy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Een profiel maken
Test-Path $profile
New-Item -path $profile -itemtype file -force
 Directory: C:\Users\Bas\Documents\WindowsPowerShell
ise $profile
# In het profiel zetten:
Set-Alias gh Get-Help
Function Set-Profile
{
 Ise $profile
}
Start-Transcript
# Bewaar het profiel

# cmdlets excersises
gal | where Definition -match "Get-ChildItem"
gci| where Length -gt 1000
cls
Get-ChildItem | Get-Member -MemberType Properties
Get-ChildItem | where LastAccessTime -gt "12/25/2016"

# Zoeken naar een bestand in een directory dat later is geschreven dan datum
Get-ChildItem "C:\windows"| Where LastWriteTime -gt "12/25/2011"
# Idem maar dan recursief in onderliggende directories
Get-ChildItem -Recurse C:\Windows | where lastwritetime -gt "12/12/11"

#Powershell providers
PS C:\Windows\system32> Get-PackageSource

Name                             ProviderName     IsTrusted  Location
----                             ------------     ---------  --------
nuget.org                        NuGet            False      https://api.nuget.org/v3/index.json
PSGallery                        PowerShellGet    False      https://www.powershellgallery.com/api/v2/

Get-Command Find-Package –Syntax

# Laat geinstalleerde software zien
get-package

$a = Find-Package
$a | Format-Table –Property Name, Summary -Autosize

Get-PackageProvider
register-packagesource -Name chocolatey -Provider Chocolatey -Trusted -Location http://chocolatey.org/api/v2/ -Verbose

Uninstall-Package -Name "7-Zip 16.04 (x64)"


# FILESYSTEM PROVIDER a.k.a. Bestandsbeheer met PowerShell
Set-Location c:\
# Toon huidige directory
gi
# Toon alle directory inhoud
gci
# Toon alleen directories in directory
GCI C:\ | where psiscontainer
# Laat alleen de bestanden zien in de directory
gci | ? {!($psitem.psiscontainer)}
# get childitem en get member
gci -path C:\ | gm
Get-ChildItem -path c:\ | Get-Member
# output bevat methods (methodes) properties (eigenschappen) en meer.

# Onderstaande commando vraag van alle childitems de members en filtert (where) deze in kolom membertype op property 
Get-ChildItem c:\ | Get-Member | where {$_.membertype -eq "property"}
# Idem hier maar dan in kolom Name op Mode
Get-ChildItem c:\ | Get-Member | where {$_.name -eq "mode"}
# hieronder kennelijk nog een andere eigenschap nl typename
gci -path C:\ | gm | where {$_.membertype -eq "property" -AND $_.typename -like "*file*"}
# zoek item van type directory en naam bevat Intel
gi * | where {$_.PsisContainer -AND $_.name -Like "*Intel*"}
# maak een nieuwe directory aan
New-Item -Path c:\ -Name Mytest -ItemType Directory
# maak een nieuw bestand aan
New-Item -path C:\Mytest\ -Name myfile.txt -Type File -Verbose
# maak een bestand met inhoud aan
New-Item -path C:\Mytest\ -Name myfile2.txt -Type File -Value "My file"
# toon de inhoud van het bestand
Get-Content C:\Mytest\myfile2.txt
# Addidionele content opnemen
Add-Content C:\Mytest\myfile2.txt -Value "DIT IS EXTRA"
Get-Content C:\Mytest\myfile2.txt
# oude informatie overschrijven
set-Content C:\Mytest\myfile2.txt -Value "DIT OVERSCHRIJFT"

# FUNCTIES
Set-Location function:\
# Toon alle functies
gci
gci | where definition -notlike "set"
gc pause

# REGISTRY PROVIDER
# Overzicht alle providers
Get-PSDrive
# alleen registry providers
Get-PSDrive -PSProvider registry | select name, root
# extra registry drives toevoegen
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
Set-Location HKCR:
Get-Location

#Registerwaarden opzoeken
Get-Item .\.ps1 | fl *
Get-ItemProperty .\.ps1 | fl 

Get-ChildItem -Path HKLM:\SOFTWARE

# searching for software (overview of all installed software)
gci -path 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
# searching for name strings
gci -path 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' | where name -match 'office'

# een nieuwe registersleutel maken proces
Push-Location
Set-Location HKCR:
# testen of de key al bestaat
Test-Path .\software\Test
New-Item -Path .\software -Name test

#of geforceerd
New-Item -Path HKCU:\Software -Name test -value "test key" -Force
set-Item -Path HKCU:\Software -Name test -value "test key" -Force

#changing the itemproperty
Set-ItemProperty -Path HKCU:\Software -Name test -value "test key" -Force

#testen van een itemproperty alvorens deze te importeren
if(Get-ItemProperty HKCU:\Software\test -Name bogus -ea 0).bogus)
{'Propertyalready exists'}
ELSE { Set-ItemProperty -Path HKCU:\Software\test -Name bogus -Value 'initial value'}

# CMDLETS die bewerkingen op Variabelen uitvoeren
Get-Help *variable | Where-Object category -eq "cmdlet"
# of
Get-Help *variable | Where-Object {$_.category -eq "cmdlet"} | Format-List name, category, synopsis

Name
----
Clear-Variable
Get-Variable
New-Variable
Remove-Variable
Set-Variable

#hetzelfde als
sl variable:\
gci |sort name

# Nieuwe variable
Set-Variable administrator -value mred
Remove-Variable administrator

# CERTIFICATE PROVIDERS
Get-ChildItem |Get-Member | Where-Object {$_.membertype -eq "property"}
Get-PSDrive | where name -Like "*c*"
sl cert:\
gci -Recurse

# POWERSHELL REMOTING AND JOBS
# Welke commando's uit te voeren op een andere PC
get-help * -Parameter computername | sort name | ft name, synopsis -auto -wrap
Get-Help * -Parameter computername -Category cmdlet | ? modulename -match 'PowerShell.Management' | sort name | ft name, synopsis -AutoSize -Wrap

# Service status ophalen van computer hyperv (gebruikt echter de credentials van de huidige gebruiker)
Get-Service -ComputerName hyperv -Name bits
# open powershell met 'Run as different server' om dit te omzeilen

# Starten van Windows Remote management
Enable-PSRemoting -force
WinRM has been updated to receive requests.
WinRM service type changed successfully.
WinRM service started.

WinRM has been updated for remote management.
WinRM firewall exception enabled.

# use the Test-WSMan cmdlet to ensure that the WinRM remoting is properly confgured and is accepting requests
Test-WSMan -ComputerName GDKB162

# Creating a remote windows powershell session
Enter-PSSession -ComputerName GDKB162

# cmdlet maken die het mogelijk maakt om vaker op een bepaalde pc in te loggen
$dc1 = New-PSSession -ComputerName dc1 -Credential iammred\administrator
Enter-PSSession $dc1
Get-PSSession
Get-PSSession | Remove-PSSession

# Running a single command on a remote machine
Invoke-Command -ComputerName ex1 -Credential iammred\administrator -ScriptBlock {gps | select -Last 1}

# Running multiple commands op een remote computer zonder geheel in te loggen
$dc1 = New-PSSession -ComputerName dc1 -Credential iammred\administrator
Invoke-Command -Session $dc1 -ScriptBlock {hostname}
Invoke-Command -Session $dc1 -ScriptBlock {Get-EventLog application -Newest 1}
Remove-PSSession $dc1

# Using Invoke-Command, you can run the same command against a large number 
# of remote systems. The secret behind this power is that the -computername parameter from the Invoke-Command
# cmdlet accepts an array of computer names. 
$cn = "dc1","dc3","ex1","sql1","wsus1","wds1","hyperv1","hyperv2","hyperv3"
$cred = get-credential iammred\administrator
Invoke-Command -cn $cn -cred $cred -ScriptBlock {gwmi win32_bios}

# Code remote uitvoeren op een server waarbij gebruik wordt gemaakt van lokale credentials
$cn = $env:COMPUTERNAME,"localhost","127.0.0.1"
Invoke-Command -cn $cn -script {gwmi -Class win32_bios}

#Windows PowerShell jobs permit you to run one or more commands in the background.
Start-Job -ScriptBlock {get-process}
# Job een naam geven
Start-Job -Name getProc -ScriptBlock {get-process}
# Status
Get-Job -Name job10
Get-Job -Name getProc
Get-Job -Id 1
# Output krijgen van de achtergrond Job, hierna wordt de cache geleegd
Receive-Job -Name job10
# Job Id daarna verwijderen
Remove-Job -Name job10
# Alle jobs verwijderen
get-job | Remove-Job

# the transcript tool captures output from the remote Windows PowerShell session, as well as output from the local session.
Start-Transcript
Stop-Transcript

# piping naar 'where name equals bits'
gwmi win32_service | ? name  -eq 'bits'
# Zetten in een variabele
$a = gwmi win32_service | ? name  -eq 'bits'
$a | gm
# Nu kunnen we enkele properties opvragen van bits.
$a.state
# Of bewerken
$a.StopService()
$a = gwmi win32_service | ? {$_.name -eq 'bits'}
$a.state
$a.StartService

# USING POWERSHELL SCRIPTS
Get-ChildItem c:\ | Where-Object Length -gt 1000 | Sort-Object -Property name | more

# There are six levels that
# can be enabled by using the Set-ExecutionPolicy cmdlet. These options are displayed here:
# ■■ Restricted Does not load confguration fles such as the Windows PowerShell profle or run
# other scripts. Restricted is the default.
# ■■ AllSigned Requires that all scripts and confguration fles be signed by a trusted publisher,
# including scripts that you write on the local computer.
# ■■ RemoteSigned Requires that all scripts and confguration fles downloaded from the
# Internet zone be signed by a trusted publisher.
# ■■ Unrestricted Loads all confguration fles and runs all scripts. If you run an unsigned script
# that was downloaded from the Internet, you are prompted for permission before it runs.
# ■■ Bypass Blocks nothing and issues no warnings or prompts.
# ■■ Undefned Removes the currently assigned execution policy from the current scope. This
# parameter will not remove an execution policy that is set in a group policy scope.
# In addition to six levels of execution policy, there are three different scopes:
# ■■ Process The execution policy affects only the current Windows PowerShell process.
# ■■ CurrentUser The execution policy affects only the current user.
# ■■ LocalMachine The execution policy affects all users of the computer. Setting the
# LocalMachine execution policy requires administrator rights on the local computer. By default,
# a non-elevated user has rights to set the script execution policy for the CurrentUser user scope
# that affects their own execution policy.


# To view the execution policy for all scopes, use the -list parameter
Get-ExecutionPolicy -List

# Script eroraction codes:
Enumeration Value
Ignore 4
Inquire 3
Continue 2
Stop 1
SilentlyContinue 0

# Toepassing
Get-Process -name Notepad -erroraction silentlycontinue

# Scriptvoorbeeld met Loop
StopnotepadSilentlyContinuePassthru.ps1
$process = "notepad"
Get-Process -name $Process -erroraction silentlycontinue |
Stop-Process -passthru |
ForEach-Object { $_.name + ' with process ID: ' + $_.ID + ' was stopped.'}

# You can assign multiple process names (an array) to the $process
# variable, and when you run the script, each process will be stopped. 

$process= "notepad", "calc"

# Script to retreive service states
retrieveandSortServiceState.ps1
$args = "localhost","loopback"
foreach ($i in $args)
{Write-Host "Testing" $i "..."
Get-WmiObject -computer $args -class win32_service |
Select-Object -property name, state, startmode, startname |
Sort-Object -property startmode, state, name |
Format-Table *}

# Variables are used to hold information for use
# later in the script. Variables can hold any type of data, including text, numbers, and even objects.
# All variable names must be preceded with a dollar sign ($) when they are referenced. 
show-variable
# Voor tonen van vaste machinevariabelen

# Data type aliases
# Alias Type
# [int] A 32-bit signed integer
# [long] A 64-bit signed integer
# [string] A fxed-length string of Unicode characters
# [char] A Unicode 16-bit character, UTF-16
# [bool] A true/false value
# [byte] An 8-bit unsigned integer
# [double] A double-precision 64-bit ﬂoating-point number
# [decimal] An 128-bit decimal value
# [single] A single-precision 32-bit ﬂoating-point number
# [array] An array of values
# [xml] An XML document
# [hashtable] A hashtable object (similar to a dictionary object)

# Constants in Windows PowerShell are like variables, with two important exceptions: their value never
# changes, and they cannot be deleted. Constants are created by using the Set-Variable cmdlet and
# specifying the -option argument to be equal to constant.

Get-Content -path c:\fso\TestFile.txt

# While statement
# A While loop continues to operate as long as a condition is evaluated as true.
#DemoWhileLessthan.ps1
$i = 0
While ($i -lt 5)
{
"`$i equals $i. This is less than 5"
$i++
} #end while $i lt 5

# The first thing you do is initialize the $i variable and set it equal to 0. You then use the Get-Content cmdlet to
# read the contents of testfle.txt and to store the contents into the $fleContents variable.

$i = 0
$fileContents = Get-Content -path C:\fso\testfile.txt
While ( $i -le $fileContents.length )
{
$fileContents[$i]
$i++
}

# You can further shorten the Get-Content command by using the gc alias 

# Do While loop
# As long as the value of the variable i is less than
# the number 5, you display the value of the variable i. 
# DemoDoWhile.ps1
$i = 0
$ary = 1..5
do
{
$ary[$i]
$i++
} while ($i -lt 5)
The
# While statement evaluates the value contained in the $i variable, not the value that is contained in the
# array. That is why you see the number 5 displayed.

# Arrey met letters
# Because you know that the $caps variable contains an array of numbers from 65 through 91, and
# that the variable $i will hold numbers from 0 through 26, you index into the $caps array, cast the integer to a char, and display the results, as follows:
# [char]$caps[$i]

# DisplayCapitalLetters.ps1
$i = 0
$caps = 65..91
do
{
[char]$caps[$i]
$i++
} while ($i -lt 26)

# Do Until statement
# Most of the scripts that do looping at the Microsoft Technet Script Center seem to use Do...While. The
# scripts that use Do...Until...Loop are typically used to read through a text fle (do something until the
# end of the stream) or to read through an ActiveX Data Object (ADO) recordset (do something until
# the end of the fle). 

$i = 0
$ary = 1..5
Do
{
$ary[$i]
$i ++
} Until ($i -eq 5)

# Verschil tussen While en Until
$i = 1
Do
{
"inside the do loop"
} While ($i -eq 5)
# Bovenstaande script eindigt gelijk omdat de conditie while niet wordt gehaald

$i = 1
Do
{
"inside the do loop"
} Until ($i -eq 5)
# Bovenstaande script blijft lopen totdat an de voorwaarde wordt voldaan (nooit, want er wordt niet opgeteld)

# the While statement is used to prevent unwanted execution
# If you have a situation where the script block must not execute if the condition is not true, you
# should use the While statement.

# The FOR statement
#  You use the For keyword, defne a variable to keep track of the count,
# indicate how far you will go, defne your action, and ensure that you specify the Next keyword. That
# is about all there is to it. 

For($i = 0; $i -le 5; $i++)
{
'$i equals ' + $i
}

# The FOREACH statement
# The For...Each block is entered as long
# as there is at least one item in the collection or array. When the loop is entered, all statements inside
# the loop are executed for the frst element. 
$ary = 1..5
Foreach ($i in $ary)
{
$i
}

# , you use the Break statement to leave the loop early

$ary = 1..5
ForEach($i in $ary)
{
if($i -eq 3) { break }
$i
}
"Statement following foreach loop"

# If you did not want to run the line of code after the loop statement, you would use the exit statement
# instead of the Break statement

$ary = 1..5
ForEach($i in $ary)
{
if($i -eq 3) { exit }
$i
}
"Statement following foreach loop"

# The IF statement
# In the Windows PowerShell version of the If...Then...End If statement, there is no Then keyword,
# nor is there an End If statement. The PowerShell If statement is easier to type. 
# The condition that is evaluated in the If statement is positioned
# between a set of parentheses. 
$a = 5
If($a -eq 5)
{
'$a equals 5'
}

# Common comparison operators
# Operator Description Example Result
# -eq Equals $a = 5 ; $a -eq 4 False
# -ne Not equal $a = 5 ; $a -ne 4 True
# -gt Greater than $a = 5 ; $a -gt 4 True
# -ge Greater than or equal to $a = 5 ; $a -ge 5 True
# -lt Less than $a = 5 ; $a -lt 5 False
# -le Less than or equal to $a = 5 ; $a -le 5 True
# -like Wildcard comparison $a = "This is Text" ; $a -like "Text" False
# -notlike Wildcard comparison $a = "This is Text" ; $a -notlike "Text" True
# -match Regular expression comparison $a = "Text is Text" ; $a -match "Text" True
# -notmatch Regular expression comparison $a = "This is Text" ; $a -notmatch "Text$" False

# IF ELSE Statement
$a = 4
If ($a -eq 5)
{
'$a equals 5'
}
Else
{
'$a is not equal to 5'
}

# Of
$a = 4
If ($a -eq 5)
{
'$a equals 5'
}
ElseIf ($a -eq 3)
{
'$a is equal to 3'
}
Else
{
'$a does not equal 3 or 5'
}

# SWITCH Statement
# you generally avoid using the ElseIf type of construction
# The Switch statement is the most powerful statement in the Windows PowerShell language. The basic
# Switch statement begins with the Switch keyword, followed by the condition to be evaluated positioned inside a pair of parentheses. 

# DemoSwitchCase.ps1
$a = 2
Switch ($a)
{
1 { '$a = 1' }
2 { '$a = 2' }
3 { '$a = 3' }
Default { 'unable to determine value of $a' }
}
"Statement after switch"

# DemoSwitchMultiMatch.ps1
$a = 2
Switch ($a)
{
1 { '$a = 1' }
2 { '$a = 2' }
2 { 'Second match of the $a variable' }
3 { '$a = 3' }
Default { 'unable to determine value of $a' }
}
"Statement after switch"

# The Windows PowerShell Switch statement can handle an array in the variable $a without any modifcation. 
DemoSwitcharray.ps1
$a = 2,3,5,1,77
Switch ($a)
{
1 { '$a = 1' }
2 { '$a = 2' }
3 { '$a = 3' }
Default { 'unable to determine value of $a' }
}
"Statement after switch"

# If you do not want the multimatch behavior of the Switch statement, you can use the Break statement to change the behavior
DemoSwitcharrayBreak.ps1
$a = 2,3,5,1,77
Switch ($a)
{
1 { '$a = 1' ; break }
2 { '$a = 2' ; break }
3 { '$a = 3' ; break }
Default { 'unable to determine value of $a' }
}
"Statement after switch"

# WORKING WITH FUNCTIONS (CH 6)
# To create a function in Windows PowerShell, you begin with the Function keyword followed by the name of the function. As a best practice, use the Windows PowerShell verb-noun combination when creating functions. Pick the verb from the standard list of PowerShell verbs to make your functions easier to remember. 

# Overzicht van alle Get commando's
Get-Command -CommandType cmdlet | Group-Object -Property Verb |Sort-Object -Property count -Descending

Function Function-Name
{
#insert code here
}

# Output van functie wordt opgeroepen met $() code
Get-OperatingSystemVersion.ps1
Function Get-OperatingSystemVersion
{
(Get-WmiObject -Class Win32_OperatingSystem).Version
} #end Get-OperatingSystemVersion
"This OS is version $(Get-OperatingSystemVersion)"


Get-textStatistics Function
Function Get-TextStatistics($path)
{
Get-Content -path $path |
Measure-Object -line -character -word
}

# Variabelen die binnen een functie zijn gemaakt, zijn niet beschikbaar buiten deze functie. Ze kunnen wel hergebruikt worden door 'child functies' in de functie.
Get-textStatisticsCallChildFunction.ps1
Function Get-TextStatistics($path)
{
Get-Content -path $path |
Measure-Object -line -character -word
Write-Path
}
Function Write-Path()
{
"Inside Write-Path the `$path variable is equal to $path"
}
Get-TextStatistics("C:\fso\test.txt")
"Outside the Get-TextStatistics function `$path is equal to $path"

# Lines Words Characters Property
# ----- ----- ---------- --------
#   223  2015      14008         
# Inside Write-Path the $path variable is equal to C:\Lucene.License.txt
# Outside the Get-TextStatistics function $path is equal to 

# When scripts are written using well-designed functions, it makes it easier to reuse them in other scripts, and to provide access to these functions from within the Windows PowerShell console. 

# With well-written functions, it is trivial to collect them into a single script—you just cut and paste. When you are done, you have created a function library.

# When pasting your functions into the function library script, pay attention to the comments at the end of the function. The comments at the closing curly bracket for each function not only point to the end of the script block, but also provide a nice visual indicator for the end of each function. This can be helpful when you need to troubleshoot a script. 

ConversionFunctions.ps1
Function Script:ConvertToMeters($feet)
{
"$feet feet equals $($feet*.31) meters"
} #end ConvertToMeters
Function Script:ConvertToFeet($meters)
{
"$meters meters equals $($meters * 3.28) feet"
} #end ConvertToFeet
Function Script:ConvertToFahrenheit($celsius)
{
"$celsius celsius equals $((1.8 * $celsius) + 32 ) fahrenheit"
} #end ConvertToFahrenheit
Function Script:ConvertTocelsius($fahrenheit)
{
"$fahrenheit fahrenheit equals $( (($fahrenheit - 32)/9)*5 ) celsius"
} #end ConvertTocelsius
Function Script:ConvertToMiles($kilometer)
{
"$kilometer kilometers equals $( ($kilometer *.6211) ) miles"
} #end convertToMiles
Function Script:ConvertToKilometers($miles)
{
"$miles miles equals $( ($miles * 1.61) ) kilometers"
} #end convertToKilometers

# One way to use the functions from the ConversionFunctions.ps1 script is to use the dot-sourcing operator to run the script so that the functions from the script are part of the calling scope. To dotsource the script, you use the dot-source operator (the period, or dot symbol), followed by a space, followed by the path to the script containing the functions you wish to include in your current scope. Once you do this, you can call the function directly, as shown here:
PS C:\> . C:\scripts\ConversionFunctions.ps1
PS C:\> convertToMiles 6
6 kilometers equals 3.7266 miles

# All of the functions from the dot-sourced script are available to the current session. This can be demonstrated by creating a listing of the function drive, as shown here:
PS C:\> dir function: | Where { $_.name -like 'co*'} |
Format-Table -Property name, definition -AutoSize

# ================
textFunctions.ps1
Function New-Line([string]$stringIn)
{
"-" * $stringIn.length
} #end New-Line
Function Get-TextStats([string[]]$textIn)
{
$textIn | Measure-Object -Line -word -char
} #end Get-TextStats

# The New-Line function will create a string of hyphen characters as long as the length of the input text. This is helpful when you want an underline for text separation purposes that is sized to the text.

Callnew-LinetextFunction.ps1
Function New-Line([string]$stringIn)
{
"-" * $stringIn.length
} #end New-Line
Function Get-TextStats([string[]]$textIn)
{
$textIn | Measure-Object -Line -word -char
} #end Get-TextStats
# *** Entry Point to script ***
"This is a string" | ForEach-Object {$_ ; New-Line $_}
When the script runs, it returns the following output:
This is a string
----------------

PS C:\> . C:\fso\TextFunctions.ps1
# Once you have included the functions in your current console, all the functions in the source script are added to the Function drive. 
dir function:

# You can improve the display of the information returned by the Get-CimInstance by pipelining the output to the New-Line function so that you can underline each computer name as it comes across the pipeline

Get-CimInstance win32_bios -ComputerName w8server8, w8client8 | ForEach-Object { $_.pscomputername ; New-Line $_.pscomputername ; $_ }


# To create a function that uses multiple input parameters, you use the Function keyword, specify the name of the function, use variables for each input parameter, and then defne the script block within the curly brackets. The pattern is shown here:

Function My-Function($Input1,$Input2)
{
#Insert Code Here
}

# Voorbeeld
Function Get-FreeDiskSpace($drive,$computer)
