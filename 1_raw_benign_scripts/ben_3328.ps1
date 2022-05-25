# Running  code that needs to be elevated here
Stop-Service -Name @("bits","wuauserv","appidsvc","cryptsvc")
del "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.*"
if(Test-Path variable:global:errs) {Remove-Variable -Name @("errs") -ErrorAction SilentlyContinue } #$err = $null
$errs = [System.Collections.ArrayList](@{})
function Start-Backup {
	param([string[]]$paths = @("$env:SystemRoot\system32\catroot2","$env:SystemRoot\SoftwareDistribution"))
	foreach($path in $paths){
		$bak = "$($path).bak"
		if((Test-Path -PathType Any $bak) -and (Test-Path -PathType Any $path)){
			try {
				$action = "delete"
				del $bak -Recurse -Force -ErrorAction Stop
				$action = "rename"
				ren $path $bak -ErrorAction Stop
				if($errs.Values.Contains($path)) {
					$errs.RemoveAt([math]::Round(($errs.Values.IndexOf($path))/$errs.Values.Count))
				}
				return $true
			} catch {
				if(-not ($errs.Values.Contains($path))){
					$errs.Add( @(@{Message=$_.Exception.Message;Item=$_.Exception.ItemName;Path=$bak;Action=$action;tries=3}))
				}
				return $false
			}
		}	else {return $true}
	}
	return $null
}
Start-Backup
cmd.exe /c "sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
cmd.exe /c "sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
cd C:\WINDOWS\System32\
$processes = New-Object -TypeName System.Collections.ArrayList
$dlls = @("atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll", "jscript.dll", "vbscript.dll", "scrrun.dll", "msxml.dll", "msxml3.dll", "msxml6.dll", "actxprxy.dll", "softpub.dll", "wintrust.dll", "dssenh.dll", "rsaenh.dll", "gpkcsp.dll", "sccbase.dll", "slbcsp.dll", "cryptdlg.dll", "oleaut32.dll", "ole32.dll", "shell32.dll", "initpki.dll", "wuapi.dll", "wuaueng.dll", "wuaueng1.dll", "wucltui.dll", "wups.dll", "wups2.dll", "wuweb.dll", "qmgr.dll", "qmgrprxy.dll", "wucltux.dll", "muweb.dll", "wuwebv.dll")
foreach ($dll in $dlls) {
   Write-Progress -Activity "Registering DLL's" -status "Registering $dll" -percentComplete (((1+$dlls.IndexOf($dll))/ $dlls.Count)*100)
   if(Test-Path -Path "$($env:windir)\System32\$($dll)" -PathType Leaf){
	   $startInfo = New-Object Diagnostics.ProcessStartInfo
	   $startInfo.Filename = "regsvr32.exe"
	   $startInfo.Arguments = "/s " + $dll
	   $startInfo.RedirectStandardError = $true
	   $startInfo.CreateNoWindow = $true
	   ## Start the process
	   $startInfo.UseShellExecute = $false
	   $processes.Add(@([Diagnostics.Process]::Start($startInfo),$startInfo)) | Out-Null
	   #if($processes.Item($processes.Count-1).ExitCode -eq 3) {$codeThree += @($processes.Item($processes.Count-1).Replace("/s ","")) } elseif($processes.Item($processes.Count-1).ExitCode -eq 4) {$codeFour += @($processes.Item($processes.Count-1).Arguments.Replace("/s ","")) }
	}
}
.\netsh winsock reset 
#the old way to reset proxy is below
#.\cmd.exe /c "proxycfg.exe -d"
.\netsh.exe winhttp reset proxy
foreach($err in $errs){
	Write-Host "Could not $($err.Action) ``$($err.Path)`` because $($err.Message.ToLower())`nGoing to try {0} more times" -f $($err.tries--)
	while(($err.tries > 0) -and (-not (Start-Backup $err.Path))) {		
		Write-Host "Going to try {0} more time{1}" -f $($err.tries--),(&{If($err.tries>1) {"s"} Else {""}}) 
		}
	}
foreach($err in $errs){Write-Host "Could not $($err.Action) ``$($err.Path)`` because $($err.Message.ToLower())`nTry restarting your computer then running the script again." -ForegroundColor Red}
#foreach ($process in $processes){ if ( -not ($process.ExitCode -ceq 0 )) {if($process.ExitCode -eq 3) {$codeThree += @($process.Arguments.Replace("/s ","")) } elseif($process.ExitCode -eq 4) {$codeFour += @($process.Arguments.Replace("/s ","")) } }}
#$regsvr32err = ($codeThree -join "`", `"")
#Write-Host "The modules `"$($regsvr32err)`" failed to load. Make sure the binaries are stored at the specified path or debug it to check for problems with the binary or dependent .DLL files. The specified module could not be found." -ForegroundColor DarkMagenta
#$regsvr32err = ($codeFour -join "`", `"")
#Write-Host "The modules `"$($regsvr32err)`" was loaded but the entry-point DllRegisterServer was not found. Make sure that `"$($regsvr32err)`" are a valid DLL or OCX file and then try again." -ForegroundColor DarkGreen