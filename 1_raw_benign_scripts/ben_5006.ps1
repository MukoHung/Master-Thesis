<#
OS01_General
filelocation : \\172.16.220.29\c$\Users\administrator.CSD\SkyDrive\download\ps1\OS01_General.ps1
\\192.168.112.124\c$\Users\administrator.CSD\OneDrive\download\PS1\OS01_General.ps1
CreateDate: Jan.02.2013
LastDate : APR.27.2014
Author :Ming Tseng  ,a0921887912@gmail.com
remark 
 
fdrgt  
math
string
Time
other
variable  (array,,


$ps1fS=gi C:\Users\administrator.CSD\OneDrive\download\ps1\OS01_General.ps1

foreach ($ps1f in $ps1fS)
{
    start-sleep 1
    $ps1fname         =$ps1fS.name
    $ps1fFullname     =$ps1fS.FullName 
    $ps1flastwritetime=$ps1fS.LastWriteTime
    $getdagte         = get-date -format yyyyMMdd
    $ps1length        =$ps1fS.Length

    Send-MailMessage -SmtpServer  '172.16.200.27'  -To "a0921887912@gmail.com","abcd12@gmail.com" -from 'a0921887912@gmail.com' `
    -attachment $ps1fFullname  `
    -Subject "ps1source  -- $getdagte      --        $ps1fname       --   $ps1flastwritetime -- $ps1length " `
    -Body "  ps1source from:me $ps1fname   " 


}
#>

get-eventlog -LogName Application

Test-Path $profile

New-Item -path $profile -type file -force
notepad $profile
##Reload-Profile 
. $profile

# 1   88  Enable Powershell ISE  & telnet
# 2  150  math
# 3  300  String
# 4  400  time
# 5  500  File
# 6   550  executionPolicy syntax V3  
# 7   600  flow control
#   8  700 variable & object  Hashtable
# 9   750 Get-PSDrive
#(10) 800 Install PowerShell V3.V4
#(11) 750 PSSnapin  vs modules
#(12) 800 mixed assembly error
#(13) 850 Get-Command  filter Service2
#(14) 900 Function 
#(15)  900 Out-GridView  Out-null 
#(16) 1000 Measure-object
#(17)  900  Group item find out count(*)
#(18)  950  select-object ExpandProperty
#(19)  950  system  variables  env:   PSVersionTable Automatic Variables
#(20)  pass  parameter to ps1 file 
#(21) 1050運算子
#(22) 1600   $env
#(1777) NoNewline or next line
#  1777 expression  @{Name="Kbytes";Expression={$_.Length / 1Kb}} 
#  1916 Run a Dos command in Powershell  Aug.26.2015
#  1966 try catch  Aug.30.2015
#  2150 runas  administrator start-process execute program
#  2184 command . shortcut 




<# ####################################################  
#dir env:\
#$env:COMPUTERNAME
#. $profile
Set-Alias gh  Get-Help

function stf {"StartTime  " + (get-date)};Set-Alias st stf
function ttf {"Stop Time  " + (get-date)};Set-Alias tt ttf 
function tt1 {"Stop Time  " + (get-date)};Set-Alias t1 tt1 

#function FindDefaultPrinter
#{
#   Get-WMIObject -query "Select * From Win32_Printer Where Default = TRUE"
#}


Set-Alias excel "C:\Program Files\Microsoft Office\Office12\Excel.exe"

#$NIC=Get-WmiObject Win32_NetworkAdapterConfiguration


if ( get-PsSnapIn | ? { $_.name  -eq  "Microsoft.sharepoint.PowerShell"} )
{write 'SharePoint.PowerShell loaded' } 
    else
{Add-PsSnapIn Microsoft.SharePoint.PowerShell } 


write "Reload Profile Finish "
#########################################>

$x=Test-Connection sql2012x; $x |gm  ;$x.StatusCode
$y=Test-Connection spmccc; $x |gm  ;$x.StatusCode

if ($x.StatusCode -eq '0'){"online"} else {"offline"}


if ($y.StatusCode -eq '0'){"online"} else {"offline"}

Show-EventLog
Get-HotFix
Get-EventLog
shutdown -r


$cred = get-credential csd\administrator

@{ Name="Size";
Expression={ ($_ | Get-ChildItem -Recurse |
Measure-Object -Sum Length).Sum + 0 } }
#-----------------------------------------------------------------------------------
# 1   88  Enable Powershell ISE  & telnet
#-----------------------------------------------------------------------------------
{
## Get
Get-WindowsFeature


##
set-executionPolicy RemoteSigned 
Import-Module ServerManager 
Add-WindowsFeature PowerShell-ISE


Add-WindowsFeature  RSAT-AD-PowerShell # Install State (Available) to  (Installed)

Import-Module servermanager
Add-WindowsFeature telnet-client





}


#-------------------------
# 2  86  math
#-------------------------
{
##
[math] | Get-Member -Static -MemberType method

## add , -and ,= , -or ,-xor
$a = 2 + 2
$a = 23 -gt 12 -and 12 -gt 40
$a = 1 + 2 + 3
$a = 23 -lt 12 -or 12 -gt 40
$a = 22018 - 1915 #Subtraction 
$a = 23 -gt 12 -xor 12 -lt 40

##absolute 
$a = [math]::abs(-15)

##array
$a = 1..100 
$a[99]

$a = "red","orange","yellow","green","blue","indigo","violet"
$a[5]

$a = 22,5,10,8,12,9,80
$b = $a -is [array]

#dynamically add elements to arrays
$t='sp2013'
$x='a','b','c','d','e','f','g'
$xc =@()
for ($i = 0; $i -lt $x.count  ; $i++)
{ 
     $xc += $i
     $xc[$i]='\\'+$t+'\'+$x[$i]

}
$xc


$cd=($e2S.Links.href).count
$xc = 1..$cd+1 
$i = 1
foreach ($e2 in ($e2S.Links.href)) 
{
$xc[$i]=$e2
$i++
}
$xc[41]



##Returns the ANSI character 
$a = [byte][char] "A"

##cos
 $a = [math]::cos(45)
 $a = [math]::sin(45)


##  Currency
$a = "{0:C}" -f 13

## FormatCurrency
$a = 1000
$a = "{0:C}" -f $a


##   Double
$a = "11.45"
$a = [double] $a

## eval
$a = 2 + 2 -eq 45

$a = 348 
"{0:N2}" -f $a   348.00
"{0:D8}" -f $a   00000348  D:Decimal
"{0:C2}" -f $a   $348.00  C:Currency  C
"{0:P0}" -f $a   34,800 %  P:Percentage
"{0:X0}" -f $a   15C  X:  Hexadecimal

## 64 vs 32
if([Environment]::Is64BitProcess) {   #p.29         
 $bitness = "64"
}#p.29   
else {#p.29   
$bitness = "32"
}#p.29 

## call 

multiplynumbers 25 67

## Dim
$a = [string]




##FormatNumber
$a = 11
$a = "{0:N6}" -f $a  # 11.000000

##FormatPercent
$a = .113   
$a = "{0:P1}" -f $a   #11.3 %

##Format   https://technet.microsoft.com/en-us/library/ee692795.aspx
$a = 348 

"{0:N2}" -f $a  #
"{0:D8}" -f $a  # Decimal     00000348
"{0:C2}" -f $a  # Currency    $348.00
"{0:P0}" -f $a  # Percentage  34,800 %
"{0:X0}" -f $a  # Hexadecimal 15C

"{0:N0}" -f 554.22272 #554 
"{0:N1}" -f 554.22272 #554.2
"{0:N2}" -f 554.22272 #554.22

##log
$a = [math]::log(100)


##logarithms
$a = [math]::exp(2) #
7.38905609893065
##long integers range -2,147,483,648 to 2,147,483,647.
$a = "123456789.45"
$a = [long] $a

##specified number of decimal places.
$a = [math]::round(45.987654321, 2)
45.99


##specified number of decimal places.
$a =15.97
$a = [math]::round($a)
16

## smallest 
$a = 8,2,3,4,5,6,7,8,9
$b = $a.getlowerbound(0)


## truncate
$a = 11.98
$a = [math]::truncate($a)

## mod
$a = 28 % 5

## numeric value to byte
$a = "11.45"
$a = [byte] $a

## numeric value to string
$a = 17 ;$a.GetType() 
$a = [string] $a; $a.GetType() 

##Multiplication 
$a = 45 * 334

##multiplynumbers
38*99 
multiplynumbers 38 99

##Not
$a = -not (10 * 7.7 -eq 77)
False


## random

Get-Random
Get-Random -Minimum 1 -Maximum 101
($a = "Dasher","Dancer","Prancer","Vixen","Comet","Cupid","Donder","Blitzen" ) | Get-Random
Get-Random -input "Dasher","Dancer","Prancer","Vixen","Comet","Cupid","Donder","Blitzen"
($a = "Dasher","Dancer","Prancer","Vixen","Comet","Cupid","Donder","Blitzen" ) | Get-Random -count 3

$a = new-object random
$b = $a.next(1,100) # between 1 and 100 in 
$b = $a.next()

$set = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
$result += $set | Get-Random

function Get-randomstring ($Length)
{

$set    = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
$result = ""
for ($x = 0; $x -lt $Length; $x++) {
    $result += $set | Get-Random
    }
return $result  
}

Get-randomstring  38



## sqr
$a = [math]::sqrt(144)
12
## Tan
$a = [math]::tan(45)
1.61977519054386
##
[math]::pow(2,4) 
16
}

#-------------------------
# 3  300  String
#-------------------------
{

# check string null or empty

if (![string]::IsNullOrEmpty($targetServer))
{
    $targetServer not Null or empty
}


##Concatenation 
$sqlVariable = "DATABASEFILENAME='$DATABASEFILENAME'", "DATABASELOGNAME='$DATABASELOGNAME'", "DBUSEROWNER='$DBUSEROWNER'"
$a = "test" + " " + "value"

##char
$a = [char]37

## mid
$a="ABCDEFG"
$a = $a.substring(2,3)

## compare
$c = [String]::Compare($a,$b,$False)

$a = "dog"
$b = "DOG"
$c = [String]::Compare($a,$b,$True)

## contains  InStr 
$a = "wombat"
$b = $a.contains("m") ; True

##  charcter position 
$a = "woMbat"
$b = $a.indexof("m") ; 2

$a = "1234x6789x1234"
$b = $a.lastindexofany("x")
9
$a.IndexOf('9'); 8

int preFrom = value.IndexOf(prePrefix, System.StringComparison.CurrentCultureIgnoreCase);


##
$a = "Scripting Guys"
$d = $a.StartsWith("Script"); $d  ;True
$d = $a.EndsWith("Script") ; $d   :False
## isempty  or  isnull
$a = ""
$b = $a.length -eq 0

$a = $z -eq $null

## join
$a = "h","e","l","l","o"
$b = [string]::join("", $a)

$b = [string]::join("\", $a)
h\e\l\l\o

("ccc","dddd"-join "\")
ccc\dddd

$a="xy";$a += $a 
xyxy


## array + ","
$WindowsFeatures = @(
			"Net-Framework-Features",
			"Web-Server",
			"Web-WebServer",
			"Web-Common-Http",
			"Web-Static-Content",
			"Web-Default-Doc",
			"Web-Dir-Browsing",
			"Web-Http-Errors",
			"Web-App-Dev",
			"Web-Asp-Net",
			"Web-Net-Ext",
			"Web-ISAPI-Ext",
			"Web-ISAPI-Filter",
			"Web-Health",
			"Web-Http-Logging",
			"Web-Log-Libraries",
			"Web-Request-Monitor",
			"Web-Http-Tracing",
			"Web-Security",
			"Web-Basic-Auth",
			"Web-Windows-Auth",
			"Web-Filtering",
			"Web-Digest-Auth",
			"Web-Performance",
			"Web-Stat-Compression",
			"Web-Dyn-Compression",
			"Web-Mgmt-Tools",
			"Web-Mgmt-Console",
			"Web-Mgmt-Compat",
			"Web-Metabase",
			"Application-Server",
			"AS-Web-Support",
			"AS-TCP-Port-Sharing",
			"AS-WAS-Support",
			"AS-HTTP-Activation",
			"AS-TCP-Activation",
			"AS-Named-Pipes",
			"AS-Net-Framework",
			"WAS",
			"WAS-Process-Model",
			"WAS-NET-Environment",
			"WAS-Config-APIs",
			"Web-Lgcy-Scripting",
			"Windows-Identity-Foundation",
			"Server-Media-Foundation",
			"Xps-Viewer"
    )
 $windowsServer2012MediaPath ='C:\sxs'
 
 if($windowsServer2012MediaPath -ne "") {
           $source = ' -source ' + $windowsServer2012MediaPath
        }
#  -source c:\sxs

$myCommand = 'Add-WindowsFeature ' + [string]::join(",",$WindowsFeatures) + $source
        將array中 Item 全部在之間 加上 ',' 
<#
Add-WindowsFeature Net-Framework-Features,Web-Server,Web-WebServer,Web-Common-Http,Web-Static-Content,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,We
b-App-Dev,Web-Asp-Net,Web-Net-Ext,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Request-Monitor,Web-Http-Tracing,Web-S
ecurity,Web-Basic-Auth,Web-Windows-Auth,Web-Filtering,Web-Digest-Auth,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Mgmt-Tools,Web-Mgmt-Co
nsole,Web-Mgmt-Compat,Web-Metabase,Application-Server,AS-Web-Support,AS-TCP-Port-Sharing,AS-WAS-Support,AS-HTTP-Activation,AS-TCP-Activation,AS-Named-Pip
es,AS-Net-Framework,WAS,WAS-Process-Model,WAS-NET-Environment,WAS-Config-APIs,Web-Lgcy-Scripting,Windows-Identity-Foundation,Server-Media-Foundation,Xps-
Viewer -source C:\sxs


#>



##

"Hello","HELLO" | select-string -pattern "HELLO" -casesensitive

##
'Ziggy stardust' -match 'iggy'
True
'cat' -match 'c.t'
True
'Ziggy stardust' -match 'Z[xyi]ggy'
True
 'Ziggy stardust' -match 'Zigg[x-z] Star'
True


$d = $sourcepath0.Contains("H:\temp\b")


## substring
$a="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$a = $a.substring(0,3)
ABC

$a = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$a = $a.substring($a.length - 9, 9)
RSTUVWXYZ

$e = "CN=Ken Myer" ;$e = $e.Substring(3) ;$e  #Ken Myer

##len
$a = "abcdefghijklmnopqrstuvwxyz"
$b = $a.length

## trailing spaces
$a = "..........123456789.........." 
$a = $a.TrimStart()


$a = "..........123456789.........." 
$a = $a.TrimEnd()

$a = "             123456789         "; $a.Length
$b  = $a.Trim(); $b.Length


## Returns a specified number of characters 
$a="ABCDEFG"
$a = $a.substring(2,3)
CDE

##Replace
$sourcepath='H:\temp\a'
$sourcepath.Replace("H:\temp\a", "\\172.16.220.61\h$\temp\a")


$a = "bxnxnx"
$a = $a -replace("x","a")



#reversed
$a = "Scripting Guys"
for ($i = $a.length - 1; $i -ge 0; $i--) 
{$b = $b + ($a.substring($i,1))}
syuG gnitpircS


## string to integer
$a = "11.47" ;$a.GetType() 
$a = [int] $a ;$a.GetType() ;

## string to Date
$a = "12/23/2013"
$a = [datetime] $a ;$a.GetType() ; $a.Month


##  Space
$a = " " * 25
$a = $a + "x"
                     x

##
$a = "=" * 20
$a

## Removing Characters From the Beginning of a String
$d = "HIJK_111112.jpg"
$e = $d.TrimStart("HIJK_") ;111112.jpg


##Turning a String Into an Array
$e = "9BY6742W"
$d = $e.ToCharArray()
$d[0]

$e = "9BY6742W"
$d = $e.ToCharArray()
$d[1] ;B

## string to array
$e = "I","love","you"
$e[2]: you

$e=$e+"today"
$e[3]

## split
$a = "atl-ws-01,atl-ws-02,atl-ws-03,atl-ws-04"
$b = $a.split(",");$b[2]
<#
atl-ws-01
atl-ws-02
atl-ws-03
atl-ws-04
#>

$b[2]  # atl-ws-03

$x="15.0.4454.1000" -split "\." ;$x

$y,$null="15.0.4454.1000" -split "\." 

$z ="15.0.4454.1000" -split "\." 

($y,$null).Length
$y.Length

$y |gm
$z |gm

(systeminfo | Select-String '實體記憶體總計:').ToString().Split(':')[1].Trim()
(systeminfo | Select-String '虛擬記憶體: 使用中:').ToString().Split(':')[2].Trim()

##  String to integer
$str="123"
$int=[int]$str;$int ; $int.GetType()

[int]$arr[2].Column1-[int]$arr[1].Column1

##   integer to string
$int=456
$str=[string]$int;$str ; $str.GetType()


## count character in string 

$test='\\172.16.220.33\f$\WorkLog\ARMY國軍\1000622\3_deploy\報表模型專案1\報表模型專案1'

$char = '\'
$result = 0..($test.length - 1) | ? {$test[$_] -eq $char}
 
# how many?
$result.count     9
 
# indices
$result
 
# verify
$result | % {$test[$_]}


}
#-------------------------
#  4 400 time
#-------------------------
{






##   date
$a = get-date –format F
get-date –format D  #Wednesday, January 8, 2014
get-date –format d #1/8/2014
Get-Date -format yyyy.M.d #2014.1.8
get-date –format yyyy.MM.dd.hh.mm.fff 
get-date –format hh.mm.ss.fffff 
get-date –format yyyy.MM.dd.hh.mm.ffffff  #2014.01.08.10.17.568886
Get-Date -Format o #2014-01-08T10:27:54.3976320+08:00
Get-Date -format "yyyy MMM d"  #2014 Jan 8
get-date -uformat %y%m%d%h%m%s%
$a = (get-date).hour
$a.hour ;$a.Millisecond

$a = 11/2/2006 
$a -is [datetime]


##  dateAdd
$current = get-date;$current
$oldDate = $current.adddays(-80);$oldDate

$yesterday = (Get-Date) - (New-TimeSpan  -Day  1)

$a = (get-date).AddDays(37)
(get-date).AddHours(37)
(get-date).AddMilliseconds(37)
(get-date).AddMinutes(37)
(get-date).AddMonths(37)
(get-date).AddSeconds(37)
(get-date).AddTicks(37)
(get-date).AddYears(37)

## DateDiff
$a = New-TimeSpan $(Get-Date) $(Get-Date –month 12 -day 31 -year 2006 -hour 23 -minute 30)
$a.Days

## Getting a persons age
[datetime]$birthday = "12/22/2012 03:22:00"
$span = [datetime]::Now - $birthday
$age = New-Object DateTime -ArgumentList $Span.Ticks
Write-Host "My daughter's age is:" $($age.Year -1) Years $($age.Month -1) Months $age.Day "days" ($age.Hour) "hours" ($age.Minute) "minutes" ($age.second) "seconds"


## date minus
$t1=Get-Date
sleep 1
$t2=Get-Date
$t2-$t1  # 
($t2-$t1).TotalSeconds

##DateSerial ;Returns a Variant of subtype Date for a specified year, month, and day
$MyDate1 = DateSerial(2006, 12, 31)
$a = get-date -y 2006 -mo 12 -day 31

## FormatDateTime
$a = (get-date).tolongdatestring()
$a = (get-date).toshortdatestring()
$a = (get-date).tolongtimestring()
$a = (get-date).toshorttimestring()

##MonthName
$a = get-date -f "MMMM"
December


$a = get-date -displayhint time


##Timer
measure-command {
    for ($a = 1; $a -le 100000; $a++) 
        {write-host $a}
                 }

##Returns a Variant of subtype Date containing the time for a specific hour, minute, and second.
$a = get-date -h 17 -Minute 10 -s 45 -displayhint time

$a = [datetime] "1:45 AM"

##Weekday
$a=(Get-Date).DayOfWeek.value__ 
(Get-Date).DayOfWeek.value__ + 1


$a = (get-date).dayofweek
Monday
$a = (get-date "02/09/2005").dayofweek

##
Measure-Command{gps}  # 測量命令執行時間

##  New-TimeSpan
$t1=(get-date)
$timespan = new-timespan -hour 4  # 
$t2= $t1+ $timespan
$t1;$t2
}
##  time to go


$th='13' ;$tm='40'
[datetime]$b1 =  $th+':'+$tm+':00' ;$b1
do{   $d=get-date ; start-sleep 1  } until ($d -gt $b1); '              now ' + (get-date).ToString()



#-------------------------
# 5   500  File
#-------------------------
$runFile="C:\perfmon\TestSQL.ps1"
Get-Content $runFile
remove-item $runFile

$a = get-content "c:\scripts\test.txt"
foreach ($i in $a)
{get-wmiobject win32_bios -computername $i | select-object __Server, name }

##  Out-File
#calc
$filename="H:\scripts\time_"+ (get-date -Format yyyyMMdd-HHmm).ToString() +  ".txt" 
(Get-date).ToString() + "    -   "+$env:COMPUTERNAME  |  Out-File  $filename  -Append

## edit to file
$filename="H:\scripts\time_"+ (get-date -Format yyyyMMdd-HHmm).ToString() +  ".ps1" 
$y=123
$Filecontent='
<#
a0921887912
#>
$t1=get-date;$t1
$x='+$y+'
$a=gps -name "*sql*"
'

$Filecontent |  Out-File  $filename  -force
Get-Content  $filename

. H:\scripts\time_20140718-0157.ps1

##
$table="AdventureWorks2008R2.Person.Person"
$curdate = Get-Date -Format "yyyy-MM-dd_hmmtt" ;
$foldername = "H:\Temp\Exports\"  ;$foldername 
$formatfilename = "$($table)_$($curdate).fmt" ;$formatfilename


##

Copy-Item -ComputerName sql2012x -Path h:\\scripts\GDx.ps1 -Destination h:\\scripts\GDx.ps1
$h='sql2012x'
cd c:\  ;cd sqlserver:\
Copy-Item h:\\scripts\GDx.ps1 -Destination "\\$h\C$\Program Files\Microsoft.NET\GD1.ps1" -force
$filedest='\\sql2012x\C$\PerfLogs\1.ps1'

## Deleting a File or Folder
Remove-Item c:\scripts\test.txt


#-------------------------
# 6   550  executionPolicy syntax V3  
#-------------------------

##
set-executionPolicy RemoteSigned 

#Change directory to where your script is stored and invoke your script in this way:
PS C:\>.\SampleScript.ps1 param1 param2

#Use the full qualified path to run the .ps1 file:
PS C:\>#if your path has no space
PS C:\>C:\MyScripts\SampleScript.ps1 param1 param2

PS C:\>#if your path has space
PS C:\>& "C:\My Scripts\SampleScript.ps1" param1 param2

#If you want to retain the functions and variables in your script throughout your session, you can dot source your file:
PS C:\>. .\SampleScript.ps1 param1 param2
PS C:\>. "C:\My Scripts\SampleScript.ps1" param1 param2

## 
Get-Process | Where-Object { $_.handles -gt 1000}

Get-Process | ? handles -gt 1000

##
New -in and -notin operator

In PowerShell 1 and 2, we have the -contains and -notcontainsoperator. In addition to this, we now have the -in and -notinoperators, which works similarly, but the opposite way around:
# Example 1:
$value = 3
if ($value -in (1,2,3)) {"The number $value is a member of the array"}
# Example 2: 
4 -notin (1,2,3) 
#prints True



## powershell ise version
$hostMajorVersion
$host





## GetObject
[reflection.assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
$a= [Microsoft.VisualBasic.Interaction]::GetObject("WinNT://atl-ws-01/Administrator")

##
$a = new-object -comobject wscript.shell
$b = $a.popup("This is a test",0,"Test Message Box",1)


##typeName
$a = 55.86768
$b = $a.gettype().name
Double


##
[Reflection.Assembly]::LoadWithPartialName("System.Web")
$a = [web.httputility]::urldecode($a)

#------------------------
#  (7)   600  flow control
#-------------------------

foreach ($i in $args)
{get-wmiobject win32_bios -computername $i | select-object __Server, name }

## Beep
Write-Warning "Error! `a"
## constant
set-variable -name b -value 3.14159265358979 -option constant

## Do...Loop
$a = 1
do {$a; $a++} while ($a -lt 10)

$a = 1
do {$a; $a++} until ($a -eq 10)

do
{   
    Invoke-Sqlcmd -Query ' sp_who'  -ServerInstance spm    | ? {$_.spid -ge 50}    |select dbname,spid,loginame, hostname  | sort dbname   | ft -AutoSize 
    $x=$x+1
    get-date
     sleep 5
   cls;
}
until ($x -eq 100)



##Erase 

for ($i = 0; $i -lt $a.length; $i++) {$a[$i] = 0}

## execute
$a = "Get-date"
invoke-expression $a

##exit   will exit Powershell 
## break  out of just the function or script
$a = 1,2,3,4,5,6,7,8,9

foreach ($i in $a) 
{
    if ($i -eq 3)
    {
        break 
    } 
    else 
    {
        $i
    }
}
#------------------------------------------
#  Exit  
#  Return 
#  Break
#------------------------------------------

Exit: This will "exit" the currently running context. If you call this command from a script it will exit the script. If you call this command from the shell it will exit the shell.

If a function calls the Exit command it will exit what ever context it is running in. So if that function is only called from within a running script it will exit that script. However, if your script merely declares the function so that it can be used from the current shell and you run that function from the shell, it will exit the shell because the shell is the context in which the function contianing the Exit command is running.

Note: By default if you right click on a script to run it in PowerShell, once the script is done running, PowerShell will close automatically. This has nothing to do with the Exit command or anything else in your script. It is just a default PowerShell behavior for scripts being ran using this specific method of running a script. The same is true for batch files and the Command Line window.

Return: This will return to the previous call point. If you call this command from a script (outside any functions) it will return to the shell. If you call this command from the shell it will return to the shell (which is the previous call point for a single command ran from the shell). If you call this command from a function it will return to where ever the function was called from.

Execution of any commands after the call point that it is returned to will continue from that point. If a script is called from the shell and it contains the Return command outside any functions then when it returns to the shell there are no more commands to run thus making a Return used in this way essentially the same as Exit.

Break: This will break out of loops and switch cases. If you call this command while not in a loop or switch case it will break out of the script. If you call Break inside a loop that is nested inside a loop it will only break out of the loop it was called in.

There is also an interesting feature of Break where you can prefix a loop with a label and then you can break out of that labeled loop even if the Break command is called within several nested groups within that labeled loop.

## Foreach
foreach ($i in get-childitem c:\scripts) {$i.extension}

$names = Invoke-Sqlcmd -Query "exec sp_helpdb" -ServerInstance spm -Database "DB"
ForEach ($row in $names) {$row.name}

#
$services = @("SQLBrowser","ReportServer")

$services | ForEach-Object {
$service = Get-Service -Name $_
if($service.Status -eq "Stopped")
{
Write-Verbose "Starting $($service.Name) ...."
Start-Service -Name $service.Name
 }
else {
Write-Verbose "Stopping $($service.Name) ...."
Stop-Service -Name $service.Name
 }
}


## GetLocale
$a = (get-culture).lcid
$a = (get-culture).displayname


## For
for ($a = 1; $a -le 10; $a++) {$a}

## if..Then
$a = "white"

if ($a -eq "red") 
    {"The color is red."} 
elseif ($a -eq "white") 
    {"The color is white."} 
else 
    {"The color is blue."}

## Public 
$Global:a = 199


## select case
$a = 5

switch ($a) 
    { 
        1 {"The color is red."} 
        2 {"The color is blue."} 
        3 {"The color is green."} 
        4 {"The color is yellow."} 
        5 {"The color is orange."} 
        6 {"The color is purple."} 
        7 {"The color is pink."}
        8 {"The color is brown."} 
        default {"The color could not be determined."}
    }


## while
$a = 1
while ($a -lt 10) {$a; $a++}



variable
#-------------------------
#   8  700 variable & object  Hashtable
#-------------------------

#array  ex1
$temp = "" | Select Server, WebSite, State
$temp.Server ="SP2"
$temp.WebSite ='website'
$temp.State = 'Started'


$x=$temp.Server

# arary ex2
$arrx='a','b','c'
$arrx[0]
$arrx[1]

#array ex3   Hashtable


$spYears =@{}
$spYears = @{"15" = "2010"; "16" = "2013" ; "14" = "2016"} ;$spYears 

$properties = @{'OSBuild'=$os.BuildNumber;
                'OSVersion'=$os.version;
                'BIOSSerial'=$bios.SerialNumber}
$object = New-Object –TypeNamePSObject –Prop $properties
Write-Output $object


$states = @{"台北" = "Taipei"; "台中" = "Taichung"; "台南" = "Tainan"}  ;$states 
$states.Add("高雄", "KaoHsiung");$states 
$states.Remove("高雄") ;$states 

$states.Set_Item("台北", "NewTaipei");$states 

$states.ContainsKey("Oregon")
$states.ContainsKey("台中") #True

$states.ContainsValue("Olympia")
$states.GetEnumerator() | Sort-Object Name
$states.GetEnumerator() | Sort-Object Value -descending

$states.Get_Item("台南")  
$states.Item('Alaska') 
$states.台北   # Juneau


foreach ($item in $states)
{
    $item.Keys
}
#--------------------------------------------------
#   9  750 Get-PSDrive
#--------------------------------------------------

Get-PSDrive |select *

Name           Used (GB)     Free (GB) Provider      Root                                             CurrentLocation
----           ---------     --------- --------      ----                                             ---------------
Alias                                  Alias                                                                         
C                  97.90        101.75 FileSystem    C:\                                      Users\administrator.CSD
Cert                                   Certificate   \                                                               
Env                                    Environment                                                                   
Function                               Function                                                                      
G                                      FileSystem    G:\                                                             
H                  96.65        103.35 FileSystem    H:\                                                             
HKCU                                   Registry      HKEY_CURRENT_USER                                               
HKLM                                   Registry      HKEY_LOCAL_MACHINE                                              
SQLSERVER                              SqlServer     SQLSERVER:\                                                     
Variable                               Variable                                                                      
WSMan                                  WSMan 




if ( Test-Path X  -eq $False)
{
    New-PSDrive -Name X -PSProvider FileSystem -Root $Dest -Credential $credential -Persist 
}

get-psdrive | ? name -eq K

#-----------------------------------------------------------------------------------
#(10) 800 Install /enable PowerShell V3.  V4
#-----------------------------------------------------------------------------------
http://learn-powershell.net/2013/10/25/powershell-4-0-now-available-for-download/


.Net 4.5 Needs to be installed!
http://www.microsoft.com/zh-TW/download/details.aspx?id=40855
Windows Management Framework 4.0 
包括 Windows PowerShell、Windows PowerShell ISE
、Windows PowerShell Web Services (Management OData IIS 擴充功能)
、Windows 遠端管理 (WinRM)
、Windows Management Instrumentation (WMI)
、伺服器管理員 WMI 提供者的更新，以及 
、4.0 的新功能 Windows PowerShell Desired State Configuration (DSC)。


準備安裝 Windows Management Framework 4.0：
為您的作業系統及架構下載正確的套件。 支援以下架構。
Windows 7 SP1
    x64： Windows6.1-KB2819745-x64-MultiPkg.msu
    x86： Windows6.1-KB2819745-x86.msu
Windows Server 2008 R2 SP1
    x64： Windows6.1-KB2819745-x64-MultiPkg.msu   #<--------here
Windows Server 2012
    x64： Windows8-RT-KB2799888-x64.msu
關閉所有 Windows PowerShell 視窗。

解除安裝 Windows Management Framework 4.0 的任何其他複本，包括任何發行前版本，或其他語言的複本。

從 Windows 檔案總管 (或 Windows Server 2012 內的檔案總管) 安裝 WMF 4.0
   瀏覽至已下載 MSU 檔案的資料夾。
   按兩下 MSU，執行 MSU。

使用命令提示字元安裝 WMF 4.0
在您已下載適用於電腦架構的正確套件之後，請使用提高的使用者權限 (以系統管理員身分執行) 開啟命令提示字元。 
在 Windows Server 2008 R2 SP1 或 Windows Server 2012 的伺服器核心安裝選項上，根據預設，命令提示字元會隨著提高的使用者權限開啟。

將目錄變更程已下載或複製 WMF 4.0 安裝套件的資料夾。
執行以下命令之一。
       在執行 Windows 7 SP1 或 Windows Server 2008 R2 SP1 的 x86 電腦上，執行 Windows6.1-KB2819745-x86.msu /quiet。
       在執行 Windows 7 SP1 或 Windows Server 2008 R2 SP1 的 x64 電腦上，執行 Windows6.1-KB2819745-x64-MultiPkg.msu /quiet。
在執行 Windows Server 2012 的電腦上，執行 Windows8-RT-KB2799888-x64.msu /quiet。

如需移難排解安裝的資訊，請參閱 WMF 4.0 版本資訊。 

解除安裝 Windows Management Framework 4.0： 
在 [控制台]\[程式集]\[程式和功能]\[ 解除安裝程式] 中，尋找然後安裝以下安裝的 Windows Update：
KB2819745 - 適用於 Windows 7 SP1 與 Windows Server 2008 R2 SP1
KB2799888 - 適用於 Windows Server 2012

________________________________________________________________________________________________________________________________________



Install Microsoft .NET Framework 4.0, if its not already there

To install PowerShell V3 on Windows 7 SP1, Windows Server 2008 SP2, or Windows Server 2008 R2 SP1:
Download and install Windows Management Framework 3.0, which contains
PowerShell V3. At the time of writing this book, the Release Candidate (RC)
is available from:
http://www.microsoft.com/en-us/download/details.aspx?id=29939

http://learn-powershell.net/2013/10/25/powershell-4-0-now-available-for-download/



#-----------------------------------------------------------------------------------
#(11) 750 PSSnapin  vs modules
#-----------------------------------------------------------------------------------
'PowerShell ships with many cmdlets and can be further extended if the shipped cmdlets are not sufficient for your purposes.legacy way of extending PowerShell is by registering additional snap-ins. A snap-in is a binary,
or a DLL, that contains cmdlets. You can create your own by building your own .NET source,
compiling, and registering the snap-in. You will always need to register snap-ins before you can
use them. Snap-ins are a popular way of extending PowerShell
'
#List loaded snap-ins
 Get-PSSnapin

#List installed snap-ins 
Get-PSSnapin -Registered

#Show commands in a snap-in 
Get-Command -Module "SnapinName"

#Load a specific snap-in 
Add-PSSnapin "SnapinName"


'When starting, PowerShell V2, modules are available as the improved and preferred method of extending PowerShell

A module is a package that can contain cmdlets, providers, functions, variables, and aliases. 
In PowerShell V2, modules are not loaded by default, so required modules need to be explicitly imported.
'

#List loaded modules 
Get-Module

#List installed modules 
Get-Module -ListAvailable

#Show commands in a module 
Get-Command -Module "ModuleName"

#Load a specific module 
Import-Module -Name "ModuleName"

'One of the improved features with PowerShell V3 is that it supports autoloading modules.
You do not need to always explicitly load modules before using the contained cmdlets. 
Using the cmdlet in your script is enough to trigger PowerShell to load the module that contains it.
The SQL Server 2012 modules are located in the PowerShell/Modules folder of the
Install directory: '


cd  'C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules'; ls

Mode                LastWriteTime     Length Name                                                                                                                                     
----                -------------     ------ ----                                                                                                                                     
d----         8/14/2013  11:37 AM            SQLASCMDLETS                                                                                                                             
d----         8/14/2013  11:38 AM            SQLPS                                                                                                                                    

#-----------------------------------------------------------------------------------
#(12)  800 mixed assembly error
#-----------------------------------------------------------------------------------

'Invoke-Sqlcmd: Mixed mode assembly is built against version V2.0.50727
of the runtime and cannot be loaded in the 4.0 runtime without additional
configuration information
'
1. Open Windows Explorer.
2. Identify the Windows PowerShell ISE install folder path. You can find this out by going
to Start | All Programs | Accessories | Windows | PowerShell, and then rightclicking
on the Windows PowerShell ISE menu item and choosing Properties.
For the 32-bit ISE, this is the default path:
%windir%\sysWOW64\WindowsPowerShell\v1.0\PowerShell_ISE.exe
For the 64-bit ISE, this is the default path:
%windir%\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe
3. Go to the PowerShell ISE Install folder.
4. Create an empty file called powershell_ise.exe.config.
5. Add the following snippet to the content and save the file:
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
<startup useLegacyV2RuntimeActivationPolicy="true">
<supportedRuntime version="v4.0" />
</startup>
<runtime>
<generatePublisherEvidence enabled="false" />
</runtime>
</configuration>
6. Reopen PowerShell ISE and retry the command that failed.





#-----------------------------------------------------------------------------------
#(13) 850 Get-Command  filter Service vs Service-related cmdlets
#-----------------------------------------------------------------------------------
Get-Command   gcm
Get-Command -Name *Service* -CommandType Cmdlet -ModuleName
gcm -CommandType All -Module sqlserver
gcm -ListImported | ? name -Like  *sql*|Out-GridView
$gcmall=gcm * ;$gcmall.count # 3408(in 216)

gcm -CommandType Function *


(Get-Command Get-sql).ModuleName


Service Methods Service-related cmdlets


Start()---- Start-Service 
Stop()---- Stop-Service
Continue()---- Resume-Service
Pause()---- Suspend-Service
Refresh()----  Restart-Service



#-----------------------------------------------------------------------------------
#(14 )  900 Function 
#-----------------------------------------------------------------------------------
#{<#
'If you are using the shell and you want this function to persist globally across different scopes,
save the script as a .ps1 file and dot source it. Another way is to prepend the function name
with global:
'
help about_functions

function global:Import-Person { }

function Import-Person {
param([string]$instanceName,[string]$dbName)
$query = @"
TRUNCATE TABLE Test.Person
GO
BULK INSERT AdventureWorks2008R2.Test.Person
FROM 'C:\Temp\Exports\AdventureWorks2008R2.Person.Person.csv'
WITH
(
FIELDTERMINATOR ='|',
ROWTERMINATOR ='\n'
)
SELECT COUNT(*) AS NumRecords
FROM AdventureWorks2008R2.Test.Person
"@;

#check number of records
Invoke-Sqlcmd -Query $query `
-ServerInstance "$instanceName" `
-Database $dbName
}


$instanceName = "SP2013"
$dbName = "AdventureWorks2008R2"
Import-Person $instanceName $dbName





function MyFunction ()
{
    $a="4"
    return $a
}

$r=MyFunction

if (  $r  -eq "4")
{
    'yes =4 '
}
#>}
#-----------------------------------------------------------------------------------
#(15)  900 Out-GridView  Out-null 
#-----------------------------------------------------------------------------------
Out-Default
out-file
out-host
Out-GridView
out

##Out-GridView as a generic selection dialog box. Add the parameter –passThru (added in PowerShell 3.0). 
##This parameter adds two new buttons to the lower right area of the grid view, and when you select something, it will be returned to you.
Get-Process | Where-Object MainWindowTitle | Out-GridView -Title 'Select Program To Kill' -PassThru | Stop-Process

#-----------------------------------------------------------------------------------
#(16)  900  Measure-Command  Measure-Object
#-----------------------------------------------------------------------------------
Aliases
Get-Counter -ListSet * | Measure-Object | Select-Object -ExpandProperty Count
Get-Counter -ListSet * | Measure-Object | select Count

Measure-Command
Measure-Object

get-childitem | measure-object
get-content h:\temp\t11.txt | measure-object -character -line -word
gc h:\temp\t11.txt | measure -character -line -word

#-----------------------------------------------------------------------------------
#(17)  900  Group item find out count(*)
#-----------------------------------------------------------------------------------
## Group  get count(*)
Get-Counter -ListSet * | Select-Object -Property CounterSetName,@{n='#Counters';e={$_.counter.count}} |
 Sort-Object -Property CounterSetName | Format-Table –AutoSize
#-----------------------------------------------------------------------------------
#(18)  950  select-object ExpandProperty
#-----------------------------------------------------------------------------------
Parameter Set: DefaultParameter
Select-Object [[-Property] <Object[]> ] 
[-ExcludeProperty <String[]> ] 
[-ExpandProperty <String> ] 
[-First <Int32> ] 
[-InputObject <PSObject> ] 
[-Last <Int32> ] 
[-Skip <Int32> ] 
[-Unique] [-Wait] 
[ <CommonParameters>]

Get-Counter -ListSet *disk*
Get-Counter -ListSet *disk* | Select  Paths
Get-Counter -ListSet *disk* | Select -ExpandProperty Paths
Get-Counter -ListSet *disk* | Select -ExcludeProperty Paths


gps | Select -Property ProcessName,@{Name="Start Day"; Expression = {$_.StartTime.DayOfWeek}}
gps | Select -Property ProcessName, Id, WS
Get-Process Explorer | Select-Object –Property ProcessName -ExpandProperty Modules | Format-List
gps | sort ws -Descending | select -Last 5
gps | sort ws -Descending | select -First 5



#-----------------------------------------------------------------------------------
#(19)  950  system  variable env:   PSVersionTable
#-----------------------------------------------------------------------------------
gi env:
$env:USERNAME
$PSVersionTable
$PID
$Variable:
Variables that store state information for PowerShell. These variables are created and maintained by Windows PowerShell.

$$	#Contains the last token in the last line received by the session.
$?	#Contains the execution status of the last operation. Equivalent to %errorlevel% in the CMD shell. See also $LastExitCode below.
    #It contains TRUE if the last operation succeeded and FALSE if it failed. ReadOnly, AllScope
$^	#Contains the first token in the last line received by the session.
$_	#Contains the current object in the pipeline object. You can use this variable in commands that perform an action on every object or on selected objects in a pipeline.
$Args	#Contains an array of the undeclared parameters and/or parameter values that are passed to a function, script, or script block. When you create a function, you can declare the parameters by using the param keyword or by adding a comma-separated list of parameters in parentheses after the function name.
$ConsoleFileName	#Contains the path of the console file (.psc1) that was most recently used in the session. This variable is populated when you start PowerShell with the PSConsoleFile parameter or when you use the Export-Console cmdlet to export snap-in names to a console file. 
                  #When you use the Export-Console cmdlet without parameters, it automatically updates the console file that was most recently used in the session. You can use this automatic variable to determine which file will be updated.
         #ReadOnly, AllScope
$Error	  #Contains an array of error objects that represent the most recent errors. Constant
$Error[0] #The most recent error is the first error object in the array ($Error[0]).

$Event	#Contains a PSEventArgs object that represents the event that is being processed. This variable is populated only within the Action block of an event registration command, such as Register-ObjectEvent. The value of this variable is the same object that the Get-Event cmdlet returns. Therefore, you can use the properties of the $Event variable, such as $Event.TimeGenerated , in an Action script block.
$EventSubscriber	#Contains a PSEventSubscriber object that represents the event subscriber of the event that is being processed. This variable is populated only within the Action block of an event registration command. The value of this variable is the same object that the Get-EventSubscriber cmdlet returns.
$ExecutionContext	#Contains an EngineIntrinsics object that represents the execution context of the Windows PowerShell host. You can use this variable to find the execution objects that are available to cmdlets. Constant, AllScope
$False	#Contains FALSE. You can use this variable to represent FALSE in commands and scripts instead of using the string "false". The string can be interpreted as TRUE if it is converted to a non-empty string or to a non-zero integer. Constant, AllScope
$ForEach	#Contains the enumerator of a ForEach-Object loop.
            #You can use the properties and methods of enumerators on the value of the $ForEach variable. 
            #This variable exists only while the For loop is running. It is deleted when the loop is completed.
$Home	#Contains the full path of the user's home directory. ReadOnly, AllScope This variable is the equivalent of the %HomeDrive%%HomePath% environment variables, typically C:\Users\<user>
$Host	#Contains an object that represents the current host application for Windows PowerShell. You can use this variable to represent the current host in commands or to display or change the properties of the host, such as $Host.version or $Host.CurrentCulture, or $host.ui.rawui.setbackgroundcolor("Red"). Constant, AllScope
$Input	#An enumerator that contains the input that is passed to a function. The $Input variable is case-sensitive and is available only in functions and in script blocks. (Script blocks are essentially unnamed functions.) In the Process block of a function, the $Input variable contains the object that is currently in the pipeline. When the Process block is completed, the value of $Input is NULL. If the function does not have a Process block, the value of $Input is available to the End block, and it contains all the input to the function.
$LastExitCode	#Contains the exit code of the last Windows-based program that was run.
$Matches	#The $Matches variable works with the -match and -not match operators. When you submit scalar input to the -match or -notmatch operator, and either one detects a match, they return a Boolean value and populate the $Matches automatic variable with a hash table of any string values that were matched. For more information about the -match operator, see about_comparison_operators.
$MyInvocation	#Contains an object with information about the current command, such as a script, function, or script block. 
               #You can use the information in the object, such as the path and file name of the script ($myinvocation.mycommand.path) 
               #or the name of a function ($myinvocation.mycommand.name) to identify the current command. See also $PSScriptRoot
$NestedPromptLevel	#Contains the current prompt level. A value of 0 indicates the original prompt level. The value is incremented when you enter a nested level and decremented when you exit it. For example, Windows PowerShell presents a nested command prompt when you use the $Host.EnterNestedPrompt method. Windows PowerShell also presents a nested command prompt when you reach a breakpoint in the Windows PowerShell debugger. When you enter a nested prompt, Windows PowerShell pauses the current command, saves the execution context, and increments the value of the $NestedPromptLevel variable. To create additional nested command prompts (up to 128 levels) or to return to the original command prompt, complete the command, or type "exit". The $NestedPromptLevel variable helps you track the prompt level. You can create an alternative Windows PowerShell command prompt that includes this value so that it is always visible.
$NULL	#Contains a NULL or empty value. A scalar value that contains nothing.
$PID	#Contains the process identifier (PID) of the process that is hosting the current Windows PowerShell session. Constant, AllScope
$Profile	#Contains the full path of the Windows PowerShell profile for the current user and the current host application. You can use this variable to represent the profile in commands. For example, you can use it in a command to determine whether a profile has been created: test-path $profile Or, you can use it in a command to create a profile: new-item -type file -path $pshome -force You can also use it in a command to open the profile in Notepad: notepad $profile
$PSBoundParameters	#Contains a dictionary of the active parameters and their current values. This variable has a value only in a scope where parameters are declared, such as a script or function. You can use it to display or change the current values of parameters or to pass parameter values to another script or function. For example: function test { param($a, $b) # Display the parameters in dictionary format. $psboundparameters # Call the Test1 function with $a and $b. test1 @psboundparameters }
$PsCmdlet	#Contains an object that represents the cmdlet or advanced function that is being run. You can use the properties and methods of the object in your cmdlet or function code to respond to the conditions of use. For example, the ParameterSetName property contains the name of the parameter set that is being used, and the ShouldProcess method adds the WhatIf and Confirm parameters to the cmdlet dynamically. For more information about the $PSCmdlet automatic variable, see about_Functions_Advanced.
$PsCulture	#Contains the name of the culture currently in use in the operating system. The culture determines the display format of items such as numbers, currrency, and dates. This is the value of the System.Globalization.CultureInfo.CurrentCulture.Name property of the system. To get the System.Globalization.CultureInfo object for the system, use Get-Culture. ReadOnly, AllScope
$PSDebugContext	#While debugging, this variable contains information about the debugging environment. Otherwise, it contains a NULL value. As a result, you can use it to indicate whether the debugger has control. When populated, it contains a PsDebugContext object that has Breakpoints and InvocationInfo properties. The InvocationInfo property has several useful properties, including the Location property. The Location property indicates the path of the script that is being debugged.
$PsHome	#Contains the full path of the installation directory for Windows PowerShell, Constant, AllScope
#Typically, %windir%\System32\WindowsPowerShell\v1.0 
#You can use this variable in the paths of Windows PowerShell files. For example, the following command searches the conceptual Help topics for the word "variable": select-string -pattern variable -path $pshome\*.txt
$PSitem	#This is exactly the same as $_ it just provides an alternative name to make your pipeline code easier to read.
$PSScriptRoot	#Contains the directory from which the script module is being executed. This variable allows scripts to use the module path to access other resources. In PowerShell 3.0+ this is available everywhere, not just in modules.
$PsUICulture	#Contains the name of the user interface (UI) culture that is currently in use in the operating system. The UI culture determines which text strings are used for user interface elements, such as menus and messages. This is the value of the System.Globalization.CultureInfo.CurrentUICulture.Name property of the system. To get the System.Globalization.CultureInfo object for the system, use Get-UICulture. ReadOnly, AllScope
$PsVersionTable	#Contains a read-only hash table (Constant, AllScope) that displays details about the version of PowerShell that is running in the current session. The table includes the following items:
  CLRVersion          The version of the common language runtime (CLR)
  BuildVersion        The build number of the current version
  PSVersion           The Windows PowerShell version number
  WSManStackVersion      The version number of the WS-Management stack
  PSCompatibleVersions   Versions of PowerShell that are compatible with the current version.
  SerializationVersion   The version of the serialization method
  PSRemotingProtocolVersion  The version of the PowerShell remote management protocol
$Pwd	#Contains a path object that represents the full path of the current directory.
$Sender	#Contains the object that generated this event. This variable is populated only within the Action block of an event registration command. The value of this variable can also be found in the Sender property of the PSEventArgs (System.Management.Automation.PSEventArgs) object that Get-Event returns.
$ShellID	#Contains the identifier of the current shell. Constant, AllScope
$SourceArgs #	Contains objects that represent the event arguments of the event that is being processed. This variable is populated only within the Action block of an event registration command. The value of this variable can also be found in the SourceArgs property of the PSEventArgs (System.Management.Automation.PSEventArgs) object that Get-Event returns.
$SourceEventArgs	#Contains an object that represents the first event argument that derives from EventArgs of the event that is being processed. This variable is populated only within the Action block of an event registration command. The value of this variable can also be found in the SourceArgs property of the PSEventArgs (System.Management.Automation.PSEventArgs) object that Get-Event returns.
$This	#In a script block that defines a script property or script method, the $This variable refers to the object that is being extended.
$True	#Contains TRUE. You can use this variable to represent TRUE in commands and scripts. Constant, AllScope
#-----------------------------------------------------------------------------------
#(20)  pass  parameter to ps1 file 
#-----------------------------------------------------------------------------------

#C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File "C:\myfile.ps1" arg1 arg2 arg3


Param(
  [string]$computerName,
  [string]$filePath
)

Param (
[parameter(Mandatory=$true )][string]$File,
[parameter(Mandatory=$false)][int]$interval = 5 # default value
)

#-----------------------------------------------------------------------------------
#(21)  Operators  運算子
#-----------------------------------------------------------------------------------

+=	Add right hand operand to value of variable and place result in variable.	            $x += 10
-=	Subtract right hand operand from value of variable and place result in variable.	    $x -= 10
*=	Multiply value of variable by right hand operand and place result in variable.	        $x *= 10
x /= y	Divide value of variable by right hand operand and place result in variable.	    $x /= 10
x %= y	Divide value of variable by right hand operand and place the remainder in variable.	$x % 10

-and      Perform a logical AND of the left and right operands
-or       Perform a logical OR of the left and right operands
-xor      Perform a logical XOR of the left and right operands
-not      Perform a logical NOT of the left and right operands
-band     Perform a logical binary AND of the left and right operands
-bor      Perform a logical binary OR of the left and right operands
-bxor     Perform a logical binary XOR of the left and right operands
-bnot     Perform a logical binary NOT of the left and right operands


$x++; Increment x by 1
$x--; Decrement x by 1

PS > $a = 10
PS > $a++ - 3   # 結果為 7，$a 的值為 11
PS > ++$a - 3   # 結果為 9，$a 的值為 12

PS > $b = 10
PS > $b-- - 3   # 結果為 7，$a 的值為 9
PS > --$b - 3   # 結果為 5，$a 的值為 8

#指定運算
$var += 5（寫法等同於 $var = $var + 5）
$var -= 5（寫法等同於 $var = $var - 5）
$var *= 5（寫法等同於 $var = $var * 5）
$var /= 5（寫法等同於 $var = $var / 5）
$var %= 5（寫法等同於 $var = $var % 5）


#KB、MB、GB。慣用的 KB、MB、GB 等位元組計量方式，也可以用在指定運算，
但是 Windows PowerShell 在將數值指定到變數之前，會先將值轉換成以位元組為計量的方式（K = 1024、M = 1024 * 1024、G = 1024 ^ 3）：

PS > $var = 10mb   # 小寫的 mb 亦可
PS > $var
10485760     # 10 * 1024 * 1024

PS > $var = 0.3kb
PS > $var
307.2    # 0.3 * 1024


#一行多個指定運算
# $i = 1; $j = 2; $k = 3
PS > $a, $b, $c = 1, 2, 3


# 變數的數量多過數值，相當於：
# $a = 1; $b = 2; $c = 3, 4, 5
PS > $a, $b, $c = 1, 2, 3, 4, 5

# 數值的數量多過變數，相當於：
# $n = 1; $o = 2; $p
# $p 沒有指定值，因此為 Null
PS > $n, $o, $p = 1, 2


# 一次將同一值指定給數個變數
PS > $d = $e = $f = 3


#比較運算
10 -le 10
"ABC" -le "abc"
"ABC" -cle "abc"
"ABC" -ile "abc"

相似（以萬用字元比較）
"One" -like "o*"
"o*" -like "One"
"One" -clike "o*"
"One" -ilike "o*" 

不相似（以萬用字元比較）
"One" -notlike "o*"
"o*" -notlike "One"
"One" -cnotlike "o*"
"One" -inotlike "o*" 

符合（以規則運算式比較）
"book" -match "[iou]"
"book" -cmatch "[iou]"
"book" -imatch "[iou]"


不相符（以規則運算式比較）

"n", "o", "e" -contains "O"
"n", "o", "e" -ccontains "O"

"n", "o", "e" -icontains "O" 

包含（運算子左邊含有右邊的值）
"n", "o", "e" -contains "O"
"n", "o", "e" -ccontains "O"
"n", "o", "e" -icontains "O" 


不包含（運算子左邊沒有右邊的值）
"n", "o", "e" -notcontains "O"
"n", "o", "e" -cnotcontains "O"
"n", "o", "e" -inotcontains "O" 


比較大、小、或相等與否：-eq / -ne、-gt / -ge、-lt / -le。
比較相似或包含與否：-like / -notlike、-match / -notmatch、-contains / -notcantains。
•原型（例如 -eq）：大小寫視為相同。
•c開頭（例如 -ceq）：大小寫視為不同。
•i開頭（例如 -ieq）：大小寫視為相同。

# -clike，大小寫需符合
PS > "Goodman" -clike "good*"
False

PS > "Goodman" -like "god*"
False

PS > "192.168.1.1" -like "192.168.1.*"
True



比較運算的型別轉換
使用 Windows PowerShell 的比較運算應該留意運算子左右的型別是否一致，不然就應該自行加入型別轉換，或者瞭解 Windows PowerShell 自動轉換的規則，否則可能得到出乎意料的結果。 
若比較運算子兩邊的運算元都是數值，則會根據寬度較大的運算元來擴大另一個運算元的數值寬度，例如一邊是整數、一邊是浮點數，就會先將整數擴大成浮點數，再行比較。將整數擴大成浮點數會加上小數點，並且將小數位數補 0，因此 678 -lt 678.9，其實是 678.0 -lt 678.9（雖然結果相同）。 
如果比較運算子兩邊運算元的型別不同，會先依據左邊運算元的型別來轉換右邊運算元的型別，再進行比較運算。例如以下簡單的範例： 
# 數值比較，因此會忽略 0
PS > 09 -eq 009
True

# 比較運算子兩邊運算元的型別不同，
# 因此會先依據左邊運算元的型別來轉換右邊運算元的型別，再進行比較運算，
# 故而等同於 09 -eq 009
PS > 09 -eq "009"
True

# 同上，先依據左邊運算元的型別來轉換右邊運算元的型別再進行比較運算，
# 因此等同於"09" -eq "009"
PS > "09" -eq 009
False

# 比較運算亦可自行型別轉換，
# 轉換之後等同於 09 -eq 009
PS > [int] "09" -eq 009
			
比較運算亦可自行加入型別轉換，例如以下簡單的範例： 
# 左邊的運算元先轉換成整數型別
# 根據左邊運算元的型別轉換右邊運算元的型別，
# 因此會將 678.4 四捨五入變成 678
# 故而等同於 678 -lt 678
PS > [int] "678" -lt "678.4"
False

# 同上，但 678.9 會進位成 679
# 故而等同於678 -lt 679
PS > [int] "678" -lt "678.9"
True

# 左邊的運算元先轉換成倍精度浮點數型別
# 根據左邊運算元的型別轉換右邊運算元的型別，
# 故而等同於678.0 -lt 678.4
PS > [double] "678" -lt "678.4"
True

# 將字串轉換成日期型別再比較
PS > [datetime] "1/1/2007" -gt [datetime] "1/1/2006"
True
			
陣列或集合的比較運算
Windows PowerShell 的陣列或集合也可以進行比較運算，其運算結果會傳回相符的值，例如以下簡單的範例： 
# 左運算元是陣列，此運算會以右運算元搜尋比較此陣列內容，
# 並找出「等於」右運算元的值；
# 結果共有兩個相等，因此列出兩個2。
PS > 2, 3, 4, 2, 3, 4 -eq 2
2
2

# 以右運算元搜尋比較此陣列內容，並找出「不等於」右運算元的值；
# 結果共有四個不相等，因此列出 1、3、4、5。
PS > 1, 2, 3, 4 -ne 2
1
3
4
5

# 以右運算元搜尋比較此陣列內容，並找出等於右運算元的值
# 比較時若兩邊的型別不同，就會根據之前所提：
# 「先依據左邊運算元的型別來轉換右邊運算元的型別，再進行比較運算」
PS > 1, "3", 5, 3 -eq "3"
3
3

# 之所以只有一個 3，是因為 "03" 並不等於 "3"
PS > 1, "03", 5, 3 -eq 3
3

# 以下是上例的小變化，請注意右運算元改成 "03"，結果也不相同
PS > 1, "03", 5, 3 -eq "03"
03
3
			
上述的比較運算不只能用在等於和不等於，例如以下使用小於的例子，會以右運算元搜尋比較左邊陣列內容，並找出「小於」右運算元的值，因此結果只有 1。 
PS > 1, "03", 5, 3 -lt "03"
1
			
-contains 和 -notcontains：陣列或集合的包含運算
陣列或集合的包含運算很類似上述的比較運算，但執行結果是 True 或 False，例如以下簡單的範例： 
PS > 1, "03", 5, 3 -contains "03"
True

PS > "a", "b", "c", "d" -ccontains "A"
False
			
-like 和 -notlike：利用萬用字元進行相似比較
相似比較的 -like 和 -notlike 運算子可以利用萬用字元進行範圍更大的比對，比對的方式是左運算元裡是不是有右運算元？例如我們想要知道某個字串裡沒有 good 開頭的字，就可以將某個字串放在左運算元，而將「比對範式」當作右運算元。同樣的，若是要進行字母大小寫符合的比對，要改用 c 開頭的 -clike 或 -cnotlike。以下是四種萬用字元的相似比較說明。 
星號（*）：可用來比對任何及任何數量的字元。例如 xy*，只要是 xy 開頭皆能符合，包括 xyz、xyw、xyx 等，但如果是 bao 或 cba 就不符合。例如以下簡單的範例： 
PS > "Goodman" -like "good*"
True

# -clike，大小寫需符合
PS > "Goodman" -clike "good*"
False

PS > "Goodman" -like "god*"
False

PS > "192.168.1.1" -like "192.168.1.*"
True

# 相似比較亦可用在陣列或集合，結果會傳回相符的元素
# 您可試著將 -like 改成 -notlike，並觀察運算結果
PS > "goodman", "guy", "goto", "good" -like "goo*"
goodman
good
			
#問號（？）：可用來比對任何的單一字元。例如 x?z，只要是 x 開頭、z 結尾的都符合，例如 xyz、xaz、xgz，但如果是 xz 就不符合。例如以下簡單的範例： 
PS > "goodman" -like "goodm?n"
True

PS > "192.168.1.1" -like "192.16?.1.*"
True
			
#字元範圍（[字元-字元]）：類似問號萬用字元，但可更精確的指定字元的範圍，例如 x[i-k]z，是指 x 開頭、z 結尾，且中間的字元是 i 到 k 的任一字元，因此只有 xiz、xjz、xkz 等三者符合。 
PS > "xkz" -like "x[i-k]z"
True

PS > "goodman" -like "g[n-p]odm[a-c]n"
True
			
特定字元（[字元…]）：類似字元範圍，但更精確的指定可能的字元，例如 x[iw]z，是指 x 開頭、z 結尾，且中間的字元是 i 或 w，因此只有 xiz、xwz 符合。 
PS > "xiz" -like "x[iw]z"
True

# 第二個字元是[a-cpmo]，
# 也就是第二個字元只要是 a 到 c 任一字元或 p 或 m 或 o 皆可。
PS > "goodman" -like "g[a-cpmo]odman"
True
			
# -match 和 -notmatch：比對部分內容
如果希望能更彈性的比對出部分內容，可以改用 -match 或 -notmatch 運算子，因為這些運算子支援規則運算式。例如想要找出某個字串變數裡有沒有 man 這個字，如果要找出的是 man 位於字尾的情況，可以利用前述的 -like 及星號萬用字元： 
PS > $var -like "*man"
但如果要找出的是 man 可以位於字串裡的任何位置，則可以改用 -match： 
PS > $var -match "man"
-match 也可以搭配一些符號來達到更便利的部分比對，例如： 
#• ^：表示開頭字元。
PS > "goodman" -match "^go"
True
					
#• $：表示結尾字元。
PS > "goodman" -match "man$"
True
					
此外，前述 -like 用來表示字元範圍的方式，也能用在 -match，例如以下簡單的範例： 
PS > "hat" -match "h[ao]t"
True

PS > "hot" -match "h[ao]t"
True

PS > "h3t" -match "h[1-5]t"
True

PS > "h9t" -match "h[1-5]t"
False
			



邏輯運算子

位元運算子

替代運算子

型別運算子

範圍運算子

格式運算子

結語
補述其他的運算子之前先提醒您，包括上一篇文章介紹的比較運算，以及本文即將說明的邏輯運算、型別運算，其結果都是 True 或 False 的布林值，因此在需要條件判斷的地方，經常會使用這類的運算；例如資料過濾的條件式，或者是迴圈、流程控制等。
邏輯運算子
如果要評估兩個以上的條件式，就是使用邏輯運算子的時機。例如：
•
2008 年 4 月 1 日產生「而且」識別碼為 672 的事件記錄
•
副檔名為 log「而且」512 KB 以上的檔案
•
使用者名稱為 SYSTEM「或者」NETWORK SERVICE 的行程
Windows PowerShell 提供了四種邏輯運算子，其中反閘有兩種表示法，可以用文字的 - not，或者是符號 !，不論哪一種，反閘的作用就是將 True 變成 False，或將 False 變成 True。這些運算子列表如下。
運算子
說明
簡例
結果
-and 
及閘，所有運算式都必須為 True，結果才會是 True。
(3 -eq 3) -and (2 -eq 5) 
False 
-or 
或閘，至少要有一個運算式為 True，結果就會是 True。
(3 -eq 3) -or (2 -eq 5) 
True 
-xor 
互斥閘，只有其中一個運算式為 True，結果才會是 True。
(3 -eq 3) -xor (2 -eq 2)
(3 -eq 3) -xor (2 -eq 5) 
False
True 
-not（!） 
反閘，逆轉運算結果。
(3 -eq 3) -and !(2 -eq 5)
或
(3 -eq 3) -and -not(2 -eq 5) 
True 
資料過濾應該算是比較運算和邏輯運算最實際的應用，我們在利用 Windows PowerShell 的 cmdlet 時，其執行結果經常會得到相當大量的資料，如果要以肉眼檢視結果，往往很困難，有時甚至會因為資料量實在太大而不可能以肉眼檢視。因此必須再藉由另一段指令碼來過濾資料。 
Where-Object（別名為 Where）是經常用來過濾資料的 cmdlet，而過濾資料的條件式就會用到（上一篇文章）介紹到的比較運算子；有些較為複雜的過濾，就需要用到這裡提及的邏輯運算子。 
例如以下兩個片段的例子，都各有兩個條件式，但第一個必須同時符合兩個條件式，第二個則只要符合其中一個條件式： 
# 找出日期為 2008 年 4 月 1 日，「而且」識別碼為 672 的事件記錄
date - match "2008/4/1" -and ID -eq "672"

# 使用者名稱為 SYSTEM「或者」NETWORK SERVICE 的行程
UserID -eq "SYSTEM" -or UserID -eq "NETWORK SERVICE"
            


位元運算子
如果需要位元運算，Windows PowerShell 也提供了四種基本的位元運算子，這些運算子都是以代表位元的 b 開頭，列表如下。
運算子
說明
簡例
結果
-band 
位元及閘運算，參與運算的兩邊位元都是 1，結果才是 1（只要一邊為 0，結果就是 0）。
10 -band 3 
2 
-bor 
位元或閘運算，參與運算的兩邊位元只要一邊是 1，結果就會是 1。
10 -bor 3 
11 
-bxor 
位元互斥閘運算，參與運算的兩邊位元只有一邊是 1，結果才會是 1。
10 -bxor 3 
9 
-bnot 
位元反閘，逆轉位元值。
-bnot 1 -band 1 
0 
位元運算是針對二進位的位元資料，雖然在 Windows PowerShell 可以如上述直接以十進位表示欲進行位元運算的資料，但改以二進位可能更有助於您理解運算過程： 
10 -band 3  轉換成二進位→  1010 -band 0011 = 0010  轉換成十進位→  2
10 -bor 3   轉換成二進位→   1010 -bor 0011 = 1011   轉換成十進位→  11
10 -xbor 3  轉換成二進位→   1010 -xbor 0011 = 1001  轉換成十進位→  9
-bnot 1 -band 1  →  0 -band 1 = 0
            


替代運算子
Windows PowerShell 還包括了一些特別且實用的運算子，這些運算子所能完成的功能，在其他語言通常需要好幾個運算子共同完成。首先介紹的是替代運算子，它的功能就如同我們經常會用到的「搜尋後取代」，它的用法如下：
            <"欲處理的字串"> -replace <"欲搜尋的字串">, <"欲替代的字串">
            
如同其他能比較字串的比較運算子，-replace 也另外有 c 開頭和 i 開頭的運算子：-replace 和 -ireplace 忽略大小寫，-creplace 不會忽略大小寫。以下是幾個關於 -replace 的例子。 
# 將 PowerShell 裡的 e 換成 5
PS > "PowerShell" -replace "e", "5"
Pow5rSh5ll
 
# 將 PowerShell 裡的 a 換成 z，就算沒有任何替代（因為 PowerShell 沒有 a），
# 也不會顯示錯誤訊息，依然顯示運算過的字串
PS > "PowerShell" -replace "a", "z"
PowerShell
 
# 再將替代後的結果指定給原變數
PS > $var = "PowerShell"
PS > $var = $var -replace -replace "e", "5"
 
# 亦可處理字串陣列
PS > $var = @("aaa","bbb","azaz","ccc")
PS > $var = $var -replace "a", "z"
PS > $var
zzz
bbb
zzzz
ccc
            
再次提醒，上述簡例都未處理字母大小寫，如果希望能處理大小寫，請使用 c 開頭的 -creplace。 


型別運算子
Windows PowerShell 也提供了檢查資料型別的運算子，可以用來檢查是不是某種型別，以及能用來轉換型別；這些運算子列表如下。 
運算子
說明
簡例
-is
是某種型別嗎？傳回 True 或 False。
$var -is [int]
-isnot
不是某種型別嗎？傳回 True 或 False。
$var -isnot [int]
-as
將物件轉成指定的型別
$var -as [string]
要注意的是，使用這些運算子時，運算子右邊必須是欲檢查或指定的運算子，運算子左邊可以是變數或值，例如以下的例子： 
# 檢查 123 是整數嗎？傳回 True 表示「是」。
PS > 123 -is [int]
True
 
# 檢查 123 不是字串嗎？傳回 True 表示「不是」。
PS > 123 -isnot [string]
True
 
# 將 123 轉成字串，並指定到 $var
PS > $var = 123 -as [string]
# 接著 $var 是字串嗎？傳回 True 表示「是」。
PS > $var -is [string]
True
           
此外，如果想要知道變數到底是哪一種型別，可以透過變數的 GetType() 方法，這個方法回傳會一個物件，物件的 Name 屬性存放著型別名稱。例如承上 $var 變數的例子（必須注意的是，GetType() 的小括號不能省略）： 
PS > $var.GetType()

IsPublic IsSerial Name     BaseType
---------- ---------- --------     --------------
True    True   String     System.Object
或
PS > $var.GetType().Name
String
           


範圍運算子
範圍運算子的符號是由兩個英文句點所構成（..）。之前的文章曾經使用過這個運算子，當時是將一段數值範圍指定給陣列，例如以下的例子： 
PS > $var = @(1..5)
			
必須注意的是，範圍運算子只能用在整數，如果用在字串會產生錯誤，如果用在浮點數，則會產生出乎意料的結果，例如以下的例子： 
# 不能用在字串，會產生錯誤
PS > $var = @("a" .. "i")
 
# 結果並非 1.1 到 1.9 的浮點數，而是 1、2 兩個整數
PS > $var = @(1.1 .. 1.9)
PS > $var
1
2
			


格式運算子
Windows PowerShell 提供了格式運算子（-f），這個運算子可以讓您將 .NET 提供的格式化機制用在 Windows PowerShell。.NET 格式化機制的細節本文暫且不表，細節可參考 MSDN 文件：（Formatting Overview）。 
格式運算子的使用方式如下： 
<格式< -f >欲格式化的字串>
			
也就是將欲格式化的字串，按照「格式」加以處理。以下以實例說明格式運算子所提供的功能。 

# 日期時間的格式化
# 格式化之前，$var 的內容包含了完整的日期及時間，並請留意其格式
PS > $var = Get-Date
PS > $var
2008 年 5 月 10 日  下午 03:39:01
 
# 格式化日期
PS > "{0:d}" -f $var
2008/5/10
 
# 格式化日期，請注意 D 是大小
PS > "{0:D}" -f $var
2008 年 5 月 10 日
 
# 格式化時間
PS > "{0:t}" -f $var
下午 03:39
 
# 格式化時間，請注意 T 是大小
PS > "{0:T}" -f $var
下午 03:39:01
 
# 數值的格式化
$val = 12345.6789
 
# 加上三位數逗號，且小數位數預設為兩位
PS > "{0:N}" -f $val
12,345.68
 
# 將小數位數指定成三位
PS > "{0:N3}" -f $val
12,345.679
 
# 與 "{0:N}" 相同，但不加三位數逗號
PS > "{0:F}" -f $val
12345.68
 
# 將小數位數指定成三位
PS > "{0:F3}" -f $var
12345.679
#-----------------------------------------------------------------------------------
#(22) 1600   $env  set $env:path add Path
#-----------------------------------------------------------------------------------

$env:computername
$env:APPDATA    #C:\Users\administrator.CSD\AppData\Roaming
$env:USERDNSDOMAIN  #CSD.SYSCOM
$env:USERDOMAIN_ROAMINGPROFILE   #CSD
$env:USERNAME     #Administrator
$env:CLIENTNAME    #my remote name  ex : W2K8R2-2013
$env:PUBLIC      #C:\Users\Public
$env:ComSpec     #C:\Windows\system32\cmd.exe
$env:HOMEDRIVE   #c
$env:USERPROFILE    #C:\Users\administrator.CSD
$env:Path


Clear-Host
$AddedLocation ="D:\Powershell"
$Reg = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
$OldPath = (Get-ItemProperty -Path "$Reg" -Name PATH).Path
$NewPath= $OldPath + ’;’ + $AddedLocation
Set-ItemProperty -Path "$Reg" -Name PATH –Value $NewPath


'
29
$env:Path
C:\Windows\system32
;C:\Windows
;C:\Windows\System32\Wbem
;C:\Windows\System32\WindowsPowerShell\v1.0\
;C:\Program Files\Microsoft Office Servers\15.0\Bin\
;C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\
;C:\Program Files\Microsoft SQL Server\110\Tools\Binn\
;C:\Program Files\Microsoft SQL Server\110\DTS\Binn\
;C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\
;C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\PrivateAssemblies\
;C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\
;C:\Program Files\Microsoft Network Monitor 3\
;C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\Bin;
'

'
61
C:\Windows\system32
;C:\Windows
;C:\Windows\System32\Wbem
;C:\Windows\System32\WindowsPowerShell\v1.0\
;C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\
;C:\Program Files\Microsoft SQL Server\110\Tools\Binn\
;C:\Program Files\Microsoft SQL Server\110\DTS\Binn\
;C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\
;C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\
;C:\Program Files\Microsoft Office Servers\15.0\Bin\
;C:\Program Files\Microsoft SQL Server\120\DTS\Binn\
;C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\
;C:\Program Files (x86)\Microsoft SQL Server\120\Tools\Binn\
;C:\Program Files\Microsoft SQL Server\120\Tools\Binn\
;C:\Program Files (x86)\Microsoft SQL Server\120\Tools\Binn\ManagementStudio\
;C:\Program Files (x86)\Microsoft SQL Server\120\DTS\Binn\
;C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\\Bin;'


#-----------------------------------------------------------------------------------
#(1777) NoNewline  next line `n
#-----------------------------------------------------------------------------------

$x='1111'
$y='2222'
$x
$y

Write-Host -NoNewline $x,$y

# " abc `n def  "
Write-Host -ForegroundColor Yellow " - SP2013 was specified in abcdefghijklmnopqrstvuw),`n - but abcd\2013\SharePoint\setup.exe was not found. Looking for SP2010..."



#-----------------------------------------------------------------------------------
#  1777 expression  @{Name="Kbytes";Expression={$_.Length / 1Kb}} 
#-----------------------------------------------------------------------------------
https://technet.microsoft.com/en-us/library/ff730948.aspx
@{Name="Kbytes"  ;Expression={ "{0:N0}" -f ($_.Length / 1Kb) }}
@{N=" "           ; E={ }        }
#{<#  

gci h:\temp2  
gci h:\temp2  |select  Name, CreationTime, Length

gci h:\temp2 | Select-Object Name, CreationTime,  @{Name="Kbytes";Expression={$_.Length / 1Kb}}
#used a .NET Framework formatting string to specify that we want 0 decimal places ({0:N0}) in our answer:

gci h:\temp2 | Select-Object Name, @{n="Kbytes";E={ "{0:N0}" -f ($_.Length / 1Kb) }} |FT -AutoSize

gci h:\temp2 | Select-Object Name, @{Name="UCaseName"; Expression={$_.Name.ToUpper()}}
gci h:\temp2 | Select-Object Name, @{Name="Age";Expression={ (((Get-Date) - $_.CreationTime).Days) }} | Sort-Object Age

#>}

#-----------------------------------------------------------------------------------
#  1916 Run a Dos command in Powershell  Aug.26.2015
#-----------------------------------------------------------------------------------

##  CMD.exe /C 

$MSIFilePath='C:\Demos\ActiveDirectory\PowerShell\'
cmd /c $MSIFilePath"ActiveRolesManagmentShell_x64.msi /quiet" <--直接可執行. 

##
function refilename ($foldername)
{
$FS=(Get-ChildItem $foldername -recurse -force)

foreach ($F in $FS)
{
       if ((($F.name).contains("[")) -eq $true )
  {
      $OF=$F.FullName;$OF
      $NF=$F.Name
      $NF=$NF.Replace('[','(')
      $NF=$NF.Replace(']',')')
      #$NF=$F.DirectoryName+'\'+$NF
      $NF

  # Rename $OF $NF
   $command = " CMD.EXE /C  Rename $OF $NF"

   $command

Invoke-Expression -Command $command 
  }

   
}#foreach

    
}


$command = " CMD.EXE /C  Rename c:\temp\etd-0705104-131541[1].pdf  f.pdf"

   $command

Invoke-Expression -Command $command 

#-----------------------------------------------------------------------------------
#  1966 try catch  Aug.30.2015
#-----------------------------------------------------------------------------------

try
{
    1/0
}
catch [DivideByZeroException]
{
    Write-Host "除數為零例外狀況"
}
catch [System.Net.WebException],[System.Exception]
{
    Write-Host "其他例外狀況"
}
finally
{
    Write-Host "正在清除..."
}


#-----------------------------------------------------------------------------------
#  2150 runas  administrator start-process execute program  & url IE  chrome
#-----------------------------------------------------------------------------------

start-process powershell -Verb runas -ArgumentList  { . C:\PerfLogs\TSQL005.ps1 -pTI PMD2016 -pGI PMD2016 -pTd SQL_inventory -pGd SQL_inventory -ptsecond 10 }

start-process powershell_ise -ArgumentList {open   C:\PerfLogs\TSQL005.ps1}

powershell_ise   C:\PerfLogs\TSQL005.ps1

# PowerShell Launch Internet Explorer
$Browser = "C:\Program Files (x86)\Internet Explorer\IEXPLORE.EXE"
"C:\Program Files\Internet Explorer\iexplore.exe"

$Browser64 = "C:\Program Files\Internet Explorer\iexplore.exe" 
Start-Process $Browser64  -ArgumentList www.udn.com
Start-Process $Browser64  http://rosatree.myweb.hinet.net/

#-----------------------------------------------------------------------------------
#  2184 command . shortcut 
#-----------------------------------------------------------------------------------

calc-----------啟動計算器
certmgr.msc----證書管理實用程序
charmap--------啟動字元對應表
chkdsk.exe-----Chkdsk磁牒檢查
chkdsk.exe-----Chkdsk磁牒檢查 
ciadv.msc------索引服務程序
cleanmgr-------磁碟清理
cliconfg-------SQL SERVER 客戶端網路實用程序
Clipbrd--------剪貼板檢視器 
cluadmin.msc
cmd.exe--------CMD命令提示字元
compmgmt.msc---電腦管理
conf-----------啟動
conf-----------啟動netmeeting
control	控制台
control admintools	系統管理工具
control nusrmgr.cpl	使用者帳戶控制(UAC)
control printers	印表機
control schedtasks	工作排程器
control userpasswords	
control userpasswords2	使用者帳戶(自動登入)
dcomcnfg-------開啟系統元件服務
ddeshare-------開啟DDE共享設定
desk.cpl	螢幕解析度
devmgmt.msc--- 裝置管理員
devmgmt.msc--- 裝置管理員 
dfrg.msc-------磁碟重組工具
dfrg.msc-------磁碟重組程式
diskmgmt.msc---磁牒管理實用程序
driverquery	查詢已安裝驅動程式
drwtsn32------ 系統醫生
dvdplay--------呼叫Microsoft Media Player
dvdplay--------DVD播放器
dxdiag---------檢查DirectX資訊
eudcedit-------造字程序
eventvwr.msc------------事件檢視器
excel
explorer-------開啟檔案總管
firewall.cpl	防火牆設定
fsmgmt.msc-----共用資料夾管理器
getmac	查詢網路卡實體位址
getmac /s {Remote IP}	查詢遠端電腦網路卡實體位址
gpedit.msc-----本機群組原則
gpedit.msc-----群組原則
iexpress-------木馬元件服務工具，系統原有的
iexpress-------木馬元件服務工具
logoff---------登出指令
logoff---------登出指令 
lpackager-------對像包裝程序
lusrmgr.msc----本機使用者及群組
magnify--------放大鏡
mem.exe--------顯示記憶體使用情況
mmc------------開啟控制台
mmc------------MMC
mobsync--------同步指令
mplayer2-------媒體播放機
Msconfig.exe---系統配置實用程序
mspaint--------小畫家
mstsc----------遠端桌面連接
narrator-------螢幕「講述人」
ncpa.cpl	網路連線
net start messenger----開始信使服務
net start messenger----開始net send 服務
net stop messenger-----停止信使服務
net stop messenger-----停止net send 服務
netmeeting compmgmt.msc---電腦管理
netmeeting dvdplay--------DVD播放器 
netplwiz	
netsh	網路裝置設定	
netstat -an----(TC)指令檢查連接
notepad--------開啟記事本
nslookup-------網路管理的工具嚮導
nslookup-------IP位址偵測器
ntbackup-------系統製作備份和還原
ntmsmgr.msc----移動存儲管理器
ntmsoprq.msc---移動存儲管理員操作請求
odbcad32-------ODBC資料來源管理器
oobe/msoobe /a----檢查XP是否啟動
osk------------開啟螢幕小鍵盤
packager-------對像包裝程序
perfmon.msc----電腦效能監測程序
perfmon.msc----電腦效能監測程序l
powercfg.cpl	電源選項
powerpnt
powershell	Power Shell
progman--------程序管理器
psndrec32-------錄音機
regedit.exe----註冊表
regedt32-------註冊表編輯器
regsvr32 /u *.dll----反註冊dll元件
regsvr32 /u *.dll----停止dll文件執行
regsvr32 /u zipfldr.dll------取消ZIP支持
rononce -p ----15秒關機
rsop.msc-------群組原則結果集
rsop.msc------------------原則的結果集
secpol.msc----------------本機安全性設定
services.msc---本機服務設定
sfc /scannow-----掃瞄錯誤並復原
sfc /scannow---windows文件保護
sfc.exe--------系統檔案檢查器
shrpubw--------新增共用資料夾
sigverif-------文件簽名驗證程序
sndrec32-------錄音機
Sndvol32-------音量控制程序
sontrol folders	資料夾選項
srononce -p ----15秒關機
ssms
syncapp--------新增一個公文包
sysdm.cpl	系統內容
sysedit--------系統配置編輯器
syskey---------系統加密，一旦加密就不能解開，保護windows xp系統的雙重密碼
systeminfo	查詢系統資訊
systeminfo  查詢系統資訊
systeminfo /s {Remote IP}	查詢遠端電腦系統資訊
taskkill /PID	中止運行中的工作
tasklist	列出目前工作項目
taskmgr--------工作管理器
taskschd.msc
tourstart------xp簡介（安裝完成後出現的漫遊xp程序）
tsshutdn-------60秒倒計時關機指令
Usyncapp--------新增一個公文包
utilman--------協助工具管理器
wiaacmgr-------掃瞄儀和照相機嚮導
widnows media player 
winchat--------XP原有的區域網路聊天
winmsd---------系統資訊
winver---------檢查Windows版本
winword
wmimgmt.msc----開啟windows管理體系結構(WMI)
write----------寫字板
wscript--------windows指令碼宿主設定
wuapp	Windows Updte
wupdmgr--------windows更新程序
