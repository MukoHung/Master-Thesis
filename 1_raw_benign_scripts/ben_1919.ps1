## About

### Install-AppOnRemoteMachine.ps1
Demonstrates how to install an app on another machine via Powershell Remoting. `Send-FileToRemoteMachine` (see below) is invoked to transfer an app from the local machine to the remote. Then, the installer is run silently, with its error code returned to the local machine.

### Send-FileToRemoteMachine.ps1
*** DEPRECATED *** Use the `Copy-Item` cmdlet, with a PSSessionConfiguration that can handle large data transfers, instead

This function sends a file from the local machine to another via Powershell Remoting. Although the [Copy-Item](https://richardspowershellblog.wordpress.com/2015/05/28/copy-files-over-ps-remoting-sessions/) cmdlet can copy files to a remote session, Powershell Remoting sessions are configured by default to cap command and data object sizes to 50 and 10MB. This function works around those limitations by sending data in 1MB chunks.

Usage:
```powershell
$vmsession = New-PSSession ...
Send-FileToRemoteMachine -Source C:\Users\joesixpack\SomeFile.txt -TargetDirectory C:\Temp -Session $vmsession
```