# PowerShell 2.0+
# Description: Powershell script to add Event Consumer 
# Original Template (Eventlog Consumer) attributed to @mattifestation: https://gist.github.com/mattifestation/aff0cb8bf66c7f6ef44a

# Set Variables
$Name = 'StagingLocation_Example'
$Query = 'SELECT * FROM __InstanceCreationEvent WITHIN 30 WHERE TargetInstance ISA "CIM_DataFile" AND TargetInstance.Drive = "C:" AND TargetInstance.Path = "\\Windows\\VSS\\"'
$EventNamespace = 'root/cimv2'
$Class = 'ActiveScriptEventConsumer'

# Define the signature - i.e. __EventFilter
$EventFilterArgs = @{
    EventNamespace = $EventNamespace
    Name = $Name
    Query = $Query
    QueryLanguage = 'WQL'
}

$InstanceArgs = @{
    Namespace = 'root/subscription'
    Class = '__EventFilter'
    Arguments = $EventFilterArgs
}

$Filter = Set-WmiInstance @InstanceArgs


# Define the Event Consumer - ACTION
$EventConsumerArgs = @{
    Name = $Name
    ScriptingEngine = 'VBScript'
    ScriptText = '
Option Explicit
Dim strDate,strTime,strWmiPath,strWmiResultsPath,strFilePath,strFileTarget,strComputerName
Dim objWmiResultsFile,objFilePath,objSysInfo
Dim objFSO,dateTime
Set dateTime = CreateObject("WbemScripting.SWbemDateTime")    
dateTime.SetVarDate (now())
strDate = YEAR(dateTime.GetVarDate (false)) & "-" & Right(String(2,"0") & Month(dateTime.GetVarDate (false)), 2) & "-" & Right(String(2, "0") & DAY(dateTime.GetVarDate (false)), 2)
strTime = FormatDateTime(dateTime.GetVarDate (false),vbShortTime)
Set objSysInfo = CreateObject("WinNTSystemInfo")
strComputerName = objSysInfo.ComputerName
strWMIPath = "<ADD PATH with trailing \ >"
strWmiResultsPath = strWMIPath & "results.log"
strFilePath = TargetEvent.TargetInstance.Name
Set objFSO = CreateObject("Scripting.Filesystemobject")
Set objWmiResultsFile = objFSO.OpenTextFile(strWmiResultsPath,8,True,0)
objWmiResultsFile.WriteLine strDate & "T" & strTime & "Z|" & strComputerName & "|Staging Location activity|"& strFilePath
objWmiResultsFile.Close
Set objFilePath = objFSO.GetFile(strFilePath)
strFileTarget = strWmiPath & strDate & "\" & objFSO.GetFileName(objFilePath)
If(Not objFSO.FolderExists(strWmiPath & strDate)) Then
    objFSO.CreateFolder(strWmiPath & strDate)
End If
objFSO.CopyFile strFilePath, strFileTarget
'
}

$InstanceArgs = @{
    Namespace = 'root/subscription'
    Class = $Class
    Arguments = $EventConsumerArgs
}

$Consumer = Set-WmiInstance @InstanceArgs

$FilterConsumerBingingArgs = @{
    Filter = $Filter
    Consumer = $Consumer
}

$InstanceArgs = @{
    Namespace = 'root/subscription'
    Class = '__FilterToConsumerBinding'
    Arguments = $FilterConsumerBingingArgs
}

# Register the alert
$Binding = Set-WmiInstance @InstanceArgs