$CimSession = New-CimSession -ComputerName 10.0.0.2

$FilePath = 'C:\Windows\System32\notepad.exe'

# PS_ModuleFile only implements GetInstance (versus EnumerateInstance) so this trick below will force a "Get" operation versus the default "Enumerate" operation.
$PSModuleFileClass = Get-CimClass -Namespace ROOT/Microsoft/Windows/Powershellv3 -ClassName PS_ModuleFile -CimSession $CimSession
$InMemoryModuleFileInstance = New-CimInstance -CimClass $PSModuleFileClass -Property @{ InstanceID= $FilePath } -ClientOnly
$FileContents = Get-CimInstance -InputObject $InMemoryModuleFileInstance -CimSession $CimSession
$FileLengthBytes = $FileContents.FileData[0..3]
[Array]::Reverse($FileLengthBytes)

$FileLength = [BitConverter]::ToUInt32($FileLengthBytes, 0)
$FileBytes = $FileContents.FileData[4..($FileLength - 1)]