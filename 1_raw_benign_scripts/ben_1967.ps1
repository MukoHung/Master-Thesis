1.Download Visual Studio 2012 WebInstaller
----------------------------
Visual Studio 2012 <http://www.microsoft.com/visualstudio/eng/downloads>
Visual Studio 2012 Update 2 <http://www.microsoft.com/en-us/download/details.aspx?id=38188>

2. Download offline install image
----------------------------------
Run following command to extract offline install image. and copy files to network share.
``` cmd
vs_professional.exe /layout "C:\Temp\VS2012Pro" /Passive /Log %Temp%\VS2012_Extract.log
VS2012.2.exe /layout "C:\Temp\VS2012_Update2" /Passive /Log %Temp%\VS2012Update2_Extract.log
```

3. Install
---------------------
Run following command to install packages.
```powershell
$sw = [Diagnostics.Stopwatch]::StartNew()
Install-VisualStudio -ImagePath "\\172.16.0.1\Shared\Images\VS2012Pro" -InstallPath $null -ProductKey $null
Write-Host ("Install Visual Studio 2012 : Elapsed {0} [minutes]." -f $sw.Elapsed.TotalMinutes)

$sw.Restart()
Install-VisualStudioUpdate -ImagePath "\\172.16.0.1\Shared\Images\VS2012_Update2" 
Write-Host ("Install Visual Studio 2012 Update2 : Elapsed {0} [minutes]." -f $sw.Elapsed.TotalMinutes)
```
*Note: The local path name should not exceed 70 characters, and the network path name should not exceed 39 characters*
  <http://msdn.microsoft.com/en-us/library/vstudio/ee225237.aspx>





