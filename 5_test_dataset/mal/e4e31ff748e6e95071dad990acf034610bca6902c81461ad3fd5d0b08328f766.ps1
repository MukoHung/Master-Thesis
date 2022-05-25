<#
SQLPS21_BI
filelocation :

\\192.168.112.124\c$\Users\administrator.CSD\OneDrive\download\PS1\SQLPS21_BI.ps1

CreateDate: APR.27.2014
LastDate :  Sep.08.2015
Author :Ming Tseng  ,a0921887912@gmail.com
remark 
 
$ps1fS=gi C:\Users\administrator.CSD\OneDrive\download\PS1\SQLPS21_BI.ps1

foreach ($ps1f in $ps1fS)
{
    start-sleep 1
    $ps1fname=$ps1f.name
    $ps1fFullname=$ps1f.FullName 
    $ps1flastwritetime=$ps1f.LastWriteTime
    $getdagte= get-date -format yyyyMMdd
    $ps1length=$ps1f.Length

    Send-MailMessage -SmtpServer  '172.16.200.27'  -To 'a0921887912@gmail.com' -from 'a0921887912@gmail.com' `
    -attachment $ps1fFullname  -Subject "ps1source  -- $getdagte      --        $ps1fname       --   $ps1flastwritetime -- $ps1length "  -Body "  ps1source from:me $ps1fname   " 
}
#>

report  list ( measure ,
ods 
fast prototype : ()

Brief 
     
     DSS to  BI  to   Big Data -- history vs Forecast

     SQL Team , Sharepoint Team  , Office Team  about BI 
     Sharepoint  BBCCPS

BI  BEVRPP

Business Connection Service
Excel service
Visio
Reporting Services
PerformancePoint
PowerPivotPowerView

Powershell for installed (security AD )

SQL (Self-services )SSI , SSAS ,SSRS

Multi-dimension
Tabular
MDX
DAX

ebook share


        



#  27   Analysis Services PowerShell
#  187  invoke-ascmd
#  204  Backup  & restore ASDatabase
#  230  SQL Server Analysis Services 教學課程
#  309  Using powerPivot  in excel 2013
#  333  Using power view
#  385   Troubleshooting    SSAS startup failure
#  396    SSISDB 目錄
#  407    SSIS configuration  deploy package   Dtutil 
#  474    SSIS run  package   Dtexec  log
#  575    SSDT for VS2013



#---------------------------------------------------------------
#  27 Analysis Services PowerShell
#---------------------------------------------------------------


https://msdn.microsoft.com/zh-tw/library/Hh213141(v=SQL.120).aspx
SQL Server 2014 Analysis Services (SSAS) 包含
 Analysis Services PowerShell (SQLAS) 提供者和指令程式，讓您可以使用 Windows PowerShell 來導覽、管理和查詢 Analysis Services 物件。

 (1)用於導覽分析管理物件 (AMO) 階層的 SQLAS 提供者。
 (2)用於執行 MDX、DMX 或 XMLA 指令碼的 Invoke-ASCmd 指令程式。
 (3)例行作業的工作特定指令程式，例如處理、角色管理、資料分割管理、備份和還原。

必須安裝包含 SQL Server PowerShell (SQLPS) 模組與用戶端程式庫的 SQL Server 功能。
最簡單的安裝方式是安裝 SQL Server Management Studio，其中就會自動包含 PowerShell 功能與用戶端程式庫。

SQL Server PowerShell (SQLPS) 模組包含所有 SQL Server 功能的 PowerShell 提供者和指令程式，
包括 SQLASCmdlets 模組和 SQLAS 提供者 (用於導覽 Analysis Services 物件階層)。

先匯入 SQLPS 模組，才能使用 SQLAS 提供者和指令程式。
SQLAS 提供者是 SQLServer 提供者的延伸模組。

啟用遠端管理和檔案共用，才能從遠端存取 Analysis Services 執行個體。如需詳細資訊，請參閱本主題的＜啟用遠端管理＞

<SQL Server 2014 Configuration Manager>
C:\Windows\SysWOW64\mmc.exe /32 C:\Windows\SysWOW64\SQLServerManager12.msc

#單獨載入工作專用的 Analysis Services 指令程式，而不載入 Analysis Services 提供者或 Invoke-ASCmd 指令程式，您可以用獨立作業的方式載入 SQLASCmdlets 模組。

#載入 Analysis Services 提供者和指令程式


 Import-Module  'C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS' -DisableNameChecking
 Import-module 'C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules\sqlascmdlets' -DisableNameChecking



if ( (get-module 'sqlps' ) -eq $false ) { Import-Module 'sqlps' -DisableNameChecking }

Import-module “sqlps”


if ( (get-module 'sqlps' ) -eq $false ) { 'hh' }

if ((get-module sqlascmdlets ) -eq $false) {Import-Module 'sqlascmdlets' -DisableNameChecking}

get-module SQLPS

#啟用遠端管理
   (1)在裝載 Analysis Services 執行個體的遠端伺服器上，於 Windows 防火牆中開啟 TCP 通訊埠 2383。
   將 Analysis Services 安裝成具名執行個體或者正在使用自訂通訊埠，此通訊埠編號將會不同

   telnet pmd2016 2383
   
   (2)遠端伺服器上，確認下列服務已啟動：

   遠端程序呼叫 (RPC) 服務、
   TCP/IP NetBIOS Helper 服務、
   Windows Management Instrumentation (WMI) 服務、
   Windows 遠端管理 (WS-Management) 服務。

   在具有用戶端工具的本機電腦上，使用下列指令程式來確認遠端管理，並以實際的伺服器名稱取代 remote-server-name 預留位置。如果 Analysis Services 安裝成預設執行個體，請省略執行個體名稱。您先前必須匯入 SQLPS 模組，才能讓此命令運作
   
   
   PS SQLSERVER:\>    cd sqlas
   'PS SQLSERVER:\sqlas> ls

    Host Name                                                                       
    ---------                                                                       
    HTTP_DS                                                                         
    PMD2016  '
   

   cd pmd2016 ;ls
   'PS SQLSERVER:\sqlas\pmd2016> ls

    Instance Name                                                                   
    -------------                                                                   
    SSASMD                                                                          
    SSASTR'

    cd SSASMD
    ls
    PS SQLSERVER:\sqlas\pmd2016>  
    'PS SQLSERVER:\sqlas\pmd2016\SSASMD>     ls
    Collections                                                                     
    -----------                                                                     
    Assemblies                                                                      
    Databases                                                                       
    Roles                                                                           
    Traces     '
    
    cd sqlserver:\  ; ls
    
    Get-PSDrive

   (3)



#連接到 Analysis Services 物件

    Analysis Services 的原生連接
     Provide Root  = >  SQLSERVER:\
     SQLAS  (延伸模組)
     CONNECTION(連接): MACHINE\INSTANCE 
     CONTAINS(容器)  : databases
      


#管理服務

確認服務正在執行。傳回 SQL Server 服務的狀態、名稱和顯示名稱，包括 Analysis Services (MSSQLServerOLAPService) 和 Database Engine。

gsv |? DisplayName -like *sql*

gsv 'MSOLAP$SSASMD' |select *
'
Name                : MSOLAP$SSASMD
RequiredServices    : {}
CanPauseAndContinue : True
CanShutdown         : False
CanStop             : True
DisplayName         : SQL Server Analysis Services (SSASMD)
DependentServices   : {}
MachineName         : .
ServiceName         : MSOLAP$SSASMD
ServicesDependedOn  : {}
ServiceHandle       : SafeServiceHandle
Status              : Running
ServiceType         : Win32OwnProcess
Site                : 
Container           : '

Get-process msmdsrv

#取得 Analysis Services PowerShell 的說明
Get-Command -Module sqlascmdlets
'PS SQLSERVER:\> Get-Command -Module sqlascmdlets

CommandType     Name                                               ModuleName                                                                                                        
-----------     ----                                               ----------                                                                                                        
Cmdlet          Add-RoleMember                                     SQLASCMDLETS                                                                                                      
Cmdlet          Backup-ASDatabase                                  SQLASCMDLETS                                                                                                      
Cmdlet          Invoke-ASCmd                                       SQLASCMDLETS                                                                                                      
Cmdlet          Invoke-ProcessCube                                 SQLASCMDLETS                                                                                                      
Cmdlet          Invoke-ProcessDimension                            SQLASCMDLETS                                                                                                      
Cmdlet          Invoke-ProcessPartition                            SQLASCMDLETS                                                                                                      
Cmdlet          Merge-Partition                                    SQLASCMDLETS                                                                                                      
Cmdlet          New-RestoreFolder                                  SQLASCMDLETS                                                                                                      
Cmdlet          New-RestoreLocation                                SQLASCMDLETS                                                                                                      
Cmdlet          Remove-RoleMember                                  SQLASCMDLETS                                                                                                      
Cmdlet          Restore-ASDatabase                                 SQLASCMDLETS                                                                                                      
'

get-help backup-asDatabases

backup-asdatabase awdb-20110930.abf “Adventure Works” -AllowOverwrite -ApplyCompression


#---------------------------------------------------------------
#    187 invoke-ascmd
#---------------------------------------------------------------
Get-help Invoke-ASCmd -Examples

讓資料庫管理員能夠針對 Microsoft SQL Server Analysis Services 執行個體執行 XMLA 指令碼、多維度運算式 (MDX) 查詢或資料採礦延伸 (DMX) 陳述式。

Invoke-ASCmd -Server:pmd2016\ssasmd `
-Query:"<Discover xmlns='urn:schemas-microsoft-com:xml-analysis'><RequestType>DBSCHEMA_CATALOGS</RequestType><Restrictions /><Properties /></Discover>" 

#---------------------------------------------------------------
#  204  Backup  & restore ASDatabase
#---------------------------------------------------------------

Import-Module  'C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS' -DisableNameChecking
Import-module 'C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules\sqlascmdlets' -DisableNameChecking


ls SQLSERVER:\SQLAS
ls SQLSERVER:\SQLAS\PMD2016\SSASMD\Databases
(ls SQLSERVER:\SQLAS\PMD2016\SSASMD\Databases).name

ls SQLSERVER:\SQLAS\PMD2016\SSASMD\Assemblies

    
Get-help backup-ASDatabase -Examples

Backup-ASDatabase ast.abf 'Analysis Services Tutorial' -AllowOverwrite -Server PMD2016\SSASMD
ii D:\SQLMD\Backup


Get-help restore-ASDatabase -Examples
Restore-ASDatabase ast.abf 'Analysis Services Tutorial' -Server PMD2016\SSASMD


   
#---------------------------------------------------------------
#  230  SQL Server Analysis Services 教學課程
#---------------------------------------------------------------
https://technet.microsoft.com/zh-tw/library/ms170208(v=sql.105).aspx

gsv | ? DisplayName -like *sql*
'PS SQLSERVER:\> gsv | ? DisplayName -like *sql*

Status   Name               DisplayName                           
------   ----               -----------                           
Running  MSOLAP$SSASMD      SQL Server Analysis Services (SSASMD) 
Running  MSOLAP$SSASTR      SQL Server Analysis Services (SSASTR) 
Running  MSSQL$SSDE         SQL Server (SSDE)                     
Stopped  MSSQL$SSDW         SQL Server (SSDW)                     
Stopped  SQLAgent$SSDE      SQL Server Agent (SSDE)               
Stopped  SQLBrowser         SQL Server Browser                    
Running  SQLWriter          SQL Server VSS Writer '

Lesson 1: Defining a Data Source View within an Analysis Services Project
Lesson 2: Defining and Deploying a Cube
Lesson 3: Modifying Measures, Attributes and Hierarchies
Lesson 4: Defining Advanced Attribute and Dimension Properties
Lesson 5: Defining Relationships Between Dimensions and Measure Groups
Lesson 6: Defining Calculations
Lesson 7: Defining Key Performance Indicators (KPIs)
Lesson 8: Defining Actions
Lesson 9: Defining Perspectives and Translations
Lesson 10: Defining Administrative Roles



Lesson 1: Defining a Data Source View within an Analysis Services Project
{<#
# 1 建立新的 Analysis Services 專案
Name: Analysis Services Tutorial 
Location  c:\users\infra1\documents\visual studio 2013\projects
Solution Name: Analysis Services Tutorial 

# 2 Defining a Data Source

Provider : Native OLE DB\SQL Server Native Client 11.0
On the Impersonation Information page of the wizard, you define the security credentials for Analysis Services to use to connect to the data source. 
Name : Adventure Works DW.ds

#3 Defining a Data Source View


Available objects list, select the following objects. You can select multiple tables by clicking each while holding down the CTRL key:
DimCustomer (dbo)
DimDate (dbo)
DimGeography (dbo)
DimProduct (dbo)
FactInternetSales (dbo)

Name : Adventure Works DW.dsv

#4 Modifying Default Table Names
To modify the default name of a table
#>}
Lesson 2: Defining and Deploying a Cube
{<#
Defining a Dimension
Defining a Cube
Adding Attributes to Dimensions
Reviewing Cube and Dimension Properties
Deploying an Analysis Services Project
'
C:\Users\infra1\Documents\Visual Studio 2013\projects\Analysis Services Tutorial\Analysis Services Tutorial\bin
Analysis Services Tutorial.asdatabase
Analysis Services Tutorial.configsettings
Analysis Services Tutorial.deploymentoptions
Analysis Services Tutorial.deploymenttargets
'


Browsing the Cube
#>}

#---------------------------------------------------------------
#  309 Using powerPivot 
#---------------------------------------------------------------

#in Execl 2013

C:\Users\infra1\Documents\My Data Sources

## enable PowerPivot in EXECL 2013

click File tab to display backstage  >  Option tab

> add ins  , in  manage : >  COM Add-Ins  GO  checked

(1)Microsoft office PowerPivot for Execl 2013

(2)power view

(3)Micoft Power Map for Execl 

you can  Powerpivt tab in excel 2013 


https://api.datamarket.azure.com/data.ashx/aml_labs/anomalydetection/v1/Score

#---------------------------------------------------------------
#  333 Using power view
#---------------------------------------------------------------

download  :　Silverlight_x64.exe　

appwiz.cpl
Microsoft Silverlight      42.0K   版本　1.0.0.0 

remember F5 on IE  Not Chromo

#---------------------------------------------------------------
#  385 Troubleshooting    SSAS startup failure
#---------------------------------------------------------------

eventID　：7038 -由於下列錯誤，MSOLAP$SSASMD 服務無法使用目前設定的密碼以 pmocsd\infraSSASMD 身分登入: 
此帳戶的密碼已到期。

若要確保正確設定該服務，請使用 Microsoft Management Console (MMC) 中的 [服務] 嵌入式管理單元。

#---------------------------------------------------------------
#  396    SSISDB 目錄
#---------------------------------------------------------------
at SSMS  -> Integration Services 目錄
--> Right 

select * from catalog.catalog_properties
select * from catalog.folders

SELECT * FROM catalog.projects;
SELECT * FROM catalog.packages;

SELECT * FROM catalog.environments;                 /*已設定的環境*/
SELECT * FROM catalog.environment_variables;        /*環境中的變數*/
SELECT * FROM catalog.environment_references;


SELECT * FROM catalog.operations; 
 select * from msdb.dbo.sysssispackagefolders
   select * from msdb.dbo.sysssispackages
      select * from [catalog].[dm_execution_performance_counters] (null)




#---------------------------------------------------------------
#  407    SSIS configuration  deploy package   Dtutil 
#---------------------------------------------------------------


##-- about MSDB  instance
C:\Program Files\Microsoft SQL Server\120\DTS\Binn\MsDtsSrvr.ini.xml  

<?xml version="1.0" encoding="utf-8"?>
<DtsServiceConfiguration xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <StopExecutingPackagesOnShutdown>true</StopExecutingPackagesOnShutdown>
  <TopLevelFolders>
    <Folder xsi:type="SqlServerFolder">
      <Name>MSDB</Name>
      <ServerName>.</ServerName>   #<-- 決定了 SSIS 存取位於本地上的那一個　instance 
    </Folder>
    <Folder xsi:type="FileSystemFolder">
      <Name>File System</Name>
      <StorePath>..\Packages</StorePath>  #<--FileSystem  path   C:\Program Files\Microsoft SQL Server\120\DTS\Packages
    </Folder>
  </TopLevelFolders>
</DtsServiceConfiguration>


  <ServerName>.</ServerName>  決定了 SSIS 存取位於本地上的那一個　instance 

##-- package in FileSystem
default folder =  C:\Program Files\Microsoft SQL Server\120\DTS\Packages
DBSSIS  =
   select * from msdb.dbo.sysssispackagefolders
   select * from msdb.dbo.sysssispackages



##-- import package
(1) use UI
(2) dtutil /?
'Microsoft (R) SQL Server SSIS 封裝公用程式
Version 12.0.2000.8 for 64-bit
Copyright (C) Microsoft Corporation 2014. 著作權所有，並保留一切權利。


使用方式: DTUtil /option [value] [/option [value]] ...
選項不區分大小寫。
連字號 (-) 可以用來取代斜線 (/)。
分隔號 (|) 是 OR 運算子，用於列出可能的值。
如需擴充說明，請使用 /help 配合選項。例如: DTUtil /help Copy

/C[opy]             {SQL | FILE | DTS};路徑
/Dec[rypt]          密碼
/Del[ete]
/DestP[assword]     密碼
/DestS[erver]       伺服器
/DestU[ser]         使用者名稱
/DT[S]              PackagePath
/Dump               處理序識別碼
/En[crypt]          {SQL | FILE | DTS};路徑;ProtectionLevel[;密碼]
/Ex[ists]
/FC[reate]          {SQL | DTS};ParentFolderPath;NewFolderName
/FDe[lete]          {SQL | DTS};ParentFolderPath;FolderName
/FDi[rectory]       {SQL | DTS}[;FolderPath[;S]]
/FE[xists]          {SQL | DTS};FolderPath
/FR[ename]          {SQL | DTS};ParentFolderPath;OldFolderName;NewFolderName
/Fi[le]             Filespec
/H[elp]             [選項]
/I[DRegenerate]
/M[ove]             {SQL | FILE | DTS};路徑
/Q[uiet]
/R[emark]           [Text]
/Si[gn]             {SQL | FILE | DTS};路徑;雜湊
/SourceP[assword]   密碼
/SourceS[erver]     伺服器
/SourceU[ser]       使用者名稱
/SQ[L]              PackagePath'

##-- deploy
SSIS 支援兩種部署模型：

專案部署模型（project deployment model）：透過「專案部署精靈」將 SSIS 專案部署到 SSISDB 目錄。
        (1) 由 SSDT 開發環境，直接叫用部署功能  有個叫 專案部署檔案 (副檔名 .ispac) 是在
        (2) 由 SSMS 中，在 SSISDB 目錄中，先建立Folder , then <Project>    執行部署功能 use <部署精靈>
封裝部署模型（package deployment model）：將封裝檔案安裝到 Integration Service 伺服器的檔案系統或 SQL Server 的執行個體。






#---------------------------------------------------------------
#  474    SSIS run  package   Dtexec  log
#---------------------------------------------------------------
#
Dtexec /?
'
PS SQLSERVER:\> Dtexec /?
Microsoft (R) SQL Server 執行封裝公用程式
Version 12.0.2000.8 for 64-bit
Copyright (C) Microsoft Corporation. 著作權所有，並保留一切權利。

使用方式: DTExec /option [value] [/option [value]] ...
選項不區分大小寫。
連字號 (-) 可以用來取代斜線 (/)。
/Ca[llerInfo]
/CheckF[ile]        [Filespec]
/Checkp[ointing]    [{On | Off}] (On 是預設值)
/Com[mandFile]      Filespec
/Conf[igFile]       Filespec
/Conn[ection]       IDOrName;ConnectionString
/Cons[oleLog]       [[DispOpts];[{E | I};List]]
                    DispOpts = N、C、O、S、G、X、M 或 T 的其中一個或多個。
                    List = {EventName | SrcName | SrcGuid}[;List]
/De[crypt]          密碼
/DT[S]              PackagePath
/Dump               code[;code[;code[;...]]]
/DumpOnErr[or]
/Env[Reference]     SSIS 目錄中環境的識別碼
/F[ile]             Filespec
/H[elp]             [選項]
/IS[Server]         SSIS 目錄中封裝的完整路徑
/L[ogger]           ClassIDOrProgID;ConfigString
/M[axConcurrent]    ConcurrentExecutables
/Pack[age]          在專案內部執行的封裝
/Par[ameter]        [$Package::|$Project::|$ServerOption::]parameter_name[(data
_type)];literal_value
/P[assword]         密碼
/Proj[ect]          要使用的專案檔案
/Rem[ark]           [文字]
/Rep[orting]        Level[;EventGUIDOrName[;EventGUIDOrName[...]]
                    Level = N 或 V 或 E、W、I、C、D 或 P 的其中一個或多個。
/Res[tart]          [{Deny | Force | IfPossible}] (Force 是預設值)
/Set                PropertyPath;Value
/Ser[ver]           ServerInstance
/SQ[L]              PackagePath
/Su[m]
/U[ser]             使用者名稱
/Va[lidate]
/VerifyB[uild]      Major[;Minor[;Build]]
/VerifyP[ackageid]  PackageID
/VerifyS[igned]
/VerifyV[ersionid]  VersionID
/VLog               [Filespec]
/W[arnAsError]
/X86

PS SQLSERVER:\> 
'
$t1=get-date
dtexec.exe /f C:\SSIS\P2.dtsx
$t2=get-date; ($t2-$t1)

dtexec.exe /f C:\SSIS\myLog.dtsx /consolelog

dtexec.exe /s  /consolelog



#---------------------------------------------------------------
#  575    SSDT for VS2013
#---------------------------------------------------------------
onenote  : https://onedrive.live.com/edit.aspx/%e6%96%87%e4%bb%b6/SQL^_W?cid=2135d796bd51c0fa&id=documents&wd=target%28SSIS.one%7C0376D714-B5D6-4331-9746-1CBED614BA7D%2FSSDT%20for%20VS2013%7CF245D20E-50F2-4B07-AE60-7BAD21BC37E2%2F%29
onenote:https://d.docs.live.net/2135d796bd51c0fa/文件/SQL_W/SSIS.one#SSDT%20for%20VS2013&section-id={0376D714-B5D6-4331-9746-1CBED614BA7D}&page-id={F245D20E-50F2-4B07-AE60-7BAD21BC37E2}&end


33 _ D:\software2015\SQL2014_ENT_TW_X64\Tools\SSDTBI_x86_ENU






lodctr      c:\"program files"\"microsoft sql server"\100\dts\binn\perf-DTSPipeline100DTSPERF.INI
   lodctr         C:\Program Files\Microsoft SQL Server\120\DTS\Binn\perf-DTSPipeline100DTSPERF.INI
            C:\Program Files\Microsoft SQL Server\100\DTS\Binn\perf-DTSPipeline100DTSPERF.INI
#---------------------------------------------------------------
# 1   Listing items in your SSRS Report Server  p386
#---------------------------------------------------------------
##Getting ready
Identify your SSRS 2012 Report Server URL. 
We will need to reference the ReportService2010 web service, and you can reference it using <ReportServer URL>/ReportService2010.asmx


##PS
1. Open the PowerShell console by going to Start | Accessories | Windows PowerShell | Windows PowerShell ISE.
2. Add the following script and run:
$ReportServerUri = "http://localhost/ReportServer/ReportService2010.asmx"
$proxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
#list all children
$proxy.ListChildren("/", $true) |Select Name, TypeName, Path, CreationDate | Format-Table -AutoSize

#if you want to list only reports
#note this is using PowerShell V3 Where-Object syntax
$proxy.ListChildren("/", $true) | Where TypeName -eq "Report" | Select Name, TypeName, Path, CreationDate | Format-Table -AutoSize


#---------------------------------------------------------------
# 2   Listing SSRS report properties   p388
#---------------------------------------------------------------

##PS
(1).Open the PowerShell console by going to Start | Accessories | Windows
PowerShell | Windows PowerShell ISE.
(2). Add the following script and run:
$ReportServerUri = "http://localhost/ReportServer/
ReportService2010.asmx"
$proxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
$reportPath = "/Customers/Customer Contact Numbers"
#using PowerShell V3 Where-Object syntax
$proxy.ListChildren("/", $true) | Where-Object Path -eq $reportPath


#---------------------------------------------------------------
# 3   Using ReportViewer to view your SSRS report   391
#---------------------------------------------------------------

##Getting Ready
'
First, you need to download ReportViewer redistributable and install it on your machine.
At the time of writing of this book, the download link is at:
'
http://www.microsoft.com/en-us/download/details.aspx?id=6442
'Identify your SSRS 2012 Report Server URL. We will need to reference the
ReportService2010 web service, and you can reference it using:
'
<ReportServer URL>/ReportService2010.asm
Pick a report you want to display using the ReportViewer control. Identify the full path, and
replace the value of the variable $reportViewer.ServerReport.ReportPath in the script.

##

(2). Load the assembly for ReportViewer as follows:
#load the ReportViewer WinForms assembly
Add-Type -AssemblyName "Microsoft.ReportViewer.WinForms,Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
#load the Windows.Forms assembly
Add-Type -AssemblyName "System.Windows.Forms"
(3). Add the following script and run:
$reportViewer = New-Object Microsoft.Reporting.WinForms.
ReportViewer
$reportViewer.ProcessingMode = "Remote"
$reportViewer.ServerReport.ReportServerUrl = "http://localhost/
ReportServer"
$reportViewer.ServerReport.ReportPath = "/Customers/Customer
Contact Numbers"
#if you need to provide basic credentials, use the following
#$reportViewer.ServerReport.ReportServerCredentials.
NetworkCredentials= New-Object System.Net.
NetworkCredential("sqladmin", "P@ssword");
$reportViewer.Height = 600
$reportViewer.Width = 800
$reportViewer.RefreshReport()
#create a new Windows form
$form = New-Object Windows.Forms.Form
#we're going to make the form just slightly bigger
#than the ReportViewer
$form.Height = 610
$form.Width= 810
#form is not resizable
$form.FormBorderStyle = "FixedSingle"
#do not allow user to maximize
$form.MaximizeBox = $false
$form.Controls.Add($reportViewer)
#show the report in the form
$reportViewer.Show()
#show the form
$form.ShowDialog()



#---------------------------------------------------------------
# 4  150  Downloading an SSRS report in Excel and PDF  p396
#---------------------------------------------------------------

2. Load the ReportViewer assembly:
Add-Type -AssemblyName "Microsoft.ReportViewer.WinForms,
Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080
cc91"
3. Add the following script and run:
$reportViewer = New-Object Microsoft.Reporting.WinForms.
ReportViewer
$reportViewer.ProcessingMode = "Remote"
$reportViewer.ServerReport.ReportServerUrl = "http://localhost/
ReportServer"
$reportViewer.ServerReport.ReportPath = "/Customers/Customer
Contact Numbers"
#required variables for rendering
$mimeType = $null
$encoding = $null
$extension = $null
$streamids = $null
$warnings = $null
#export to Excel
$excelFile = "C:\Temp\Customer Contact Numbers.xls"
$bytes = $reportViewer.ServerReport.Render("Excel", $null,
[ref] $mimeType,
[ref] $encoding,
[ref] $extension,
[ref] $streamids,
[ref] $warnings)
$fileStream = New-Object System.IO.FileStream($excelFile, [System.IO.FileMode]::OpenOrCreate)
$fileStream.Write($bytes, 0, $bytes.Length)
$fileStream.Close()
#let's open up our Excel document
$excel = New-Object -comObject Excel.Application
$excel.visible = $true
$excel.Workbooks.Open($excelFile) | Out-Null
#export to PDF
$pdfFile = "C:\Temp\Customer Contact Numbers.pdf"
$bytes = $reportViewer.ServerReport.Render("PDF", $null,
[ref] $mimeType,
[ref] $encoding,
[ref] $extension,
[ref] $streamids,
[ref] $warnings)
$fileStream = New-Object System.IO.FileStream($pdfFile, [System.
IO.FileMode]::OpenOrCreate)
$fileStream.Write($bytes, 0, $bytes.Length)
$fileStream.Close()
#let's open up up our PDF application
[System.Diagnostics.Process]::Start($pdfFile)


#---------------------------------------------------------------
# 5  200  Creating an SSRS folder  p400
#---------------------------------------------------------------


##
2. Add the following script and run:
$ReportServerUri = "http://localhost/ReportServer/
ReportService2010.asmx"
$proxy = New-WebServiceProxy -Uri $ReportServerUri
-UseDefaultCredential
#A workaround we have to do to ensure
#we don't get any namespace clashes is to
#capture the auto-generated namespace, and
#create our objects based on this namespace
#capture automatically generated namespace
#this is a workaround to avoid namespace clashes
#resulting in using –Class with New-WebServiceProxy
$type = $Proxy.GetType().Namespace
#formulate data type we need
$datatype = ($type + '.Property')
#display datatype, just for our reference
$datatype
#create new Property
#if we were using –Class SSRS, this would be similar to
#$property = New-Object SSRS.Property
$property = New-Object ($datatype)
$property.Name = "Description"
$property.Value = "SQLSaturdays Rock! Attendees are cool!"
$folderName = "SQLSat 114 " + (Get-Date -format "yyyy-MMM-ddhhmmtt")
#Report SSRS Properties
#http://msdn.microsoft.com/en-us/library/ms152826.aspx
$numProperties = 1
$properties = New-Object ($datatype + '[]')$numProperties
$properties[0] = $property
$proxy.CreateFolder($folderName, "/", $properties)
#display new folder in IE
Set-Alias ie "$env:programfiles\Internet Explorer\iexplore.exe"
ie "http://localhost/Reports"

#---------------------------------------------------------------
#  6 Creating an SSRS data source  p404
#---------------------------------------------------------------

##
Property Value
Data source name :Sample
Data source type :SQL
Connection string :Data Source=KERRIGAN;Initial Catalog=AdventureWorks2008R2 Credentials Integrated
Parent (that is, folder where this data source will be placed; must exist already)/Data Sources

##
Add the following script and run:
$ReportServerUri = "http://localhost/ReportServer/
ReportService2010.asmx"
$proxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
$type = $Proxy.GetType().Namespace
#create a DataSourceDefinition
$dataSourceDefinitionType = ($type + '.DataSourceDefinition')
$dataSourceDefinition = New-Object($dataSourceDefinitionType)
$dataSourceDefinition.CredentialRetrieval = "Integrated"
$dataSourceDefinition.ConnectString = "Data
Source=KERRIGAN;Initial Catalog=AdventureWorks2008R2"
$dataSourceDefinition.extension = "SQL"
$dataSourceDefinition.enabled = $true
$dataSourceDefinition.Prompt = $null
$dataSourceDefinition.WindowsCredentials = $false
#NOTE this is SSRS native mode
#CreateDataSource method accepts the following parameters:
#datasource name
#parent (data folder) – must already exist
#overwrite
#data source definition
#properties
$dataSource = "Sample"
$parent = "/Data Sources"
$overwrite = $true
$newDataSource = $proxy.CreateDataSource($dataSource, $parent, $overwrite,$dataSourceDefinition, $null)


#---------------------------------------------------------------
#  7 
#---------------------------------------------------------------

gsv -displayname *sql*

ping FC2

ping 172.16.220.161


gsv -DisplayName '*sql*'