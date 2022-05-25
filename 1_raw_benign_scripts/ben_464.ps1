#Requires -RunAsAdministrator

function Get-InstalledPackageCount($Name) {
  if ((clist -l $Name | Select-Object -Last 1) -match "\d*") {
    [int]($matches[0])
  } else {
    0
  }
}

function Test-InstalledPackage($Name) {
  [bool](Get-InstalledPackageCount $Name)
}

function Update-Package($Name, [string]$InstallArguments) {
  if (Test-InstalledPackage $Name) {
    Invoke-Expression "choco upgrade $Name $(if ($InstallArguments) { "-InstallArguments $InstallArguments" })"
  } else {
    Invoke-Expression "choco install $Name $(if ($InstallArguments) { "-InstallArguments $InstallArguments" })"
  }
}

Update-ExecutionPolicy 'Unrestricted'
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
try {
  Enable-RemoteDesktop
} catch {
  Write-Warning 'Unable to enable remote desktop.'
}

#if (Test-PendingReboot) { Invoke-Reboot }

#Install-WindowsUpdate -AcceptEula
#if (Test-PendingReboot) { Invoke-Reboot }

# Install Visual Studio 2015 Professional
#Update-Package VisualStudio2015Professional -InstallArguments WebTools
#if (Test-PendingReboot) { Invoke-Reboot }

# VS extensions
#Install-ChocolateyVsixPackage PowerShellTools http://visualstudiogallery.msdn.microsoft.com/c9eb3ba8-0c59-4944-9a62-6eee37294597/file/112013/6/PowerShellTools.vsix
#Install-ChocolateyVsixPackage WebEssentials2013 http://visualstudiogallery.msdn.microsoft.com/56633663-6799-41d7-9df7-0f2a504ca361/file/105627/31/WebEssentials2013.vsix
#Install-ChocolateyVsixPackage T4Toolbox http://visualstudiogallery.msdn.microsoft.com/791817a4-eb9a-4000-9c85-972cc60fd5aa/file/116854/1/T4Toolbox.12.vsix
#Install-ChocolateyVsixPackage StopOnFirstBuildError http://visualstudiogallery.msdn.microsoft.com/91aaa139-5d3c-43a7-b39f-369196a84fa5/file/44205/3/StopOnFirstBuildError.vsix

#Other dev tools
#cinstm fiddler4
#cinstm beyondcompare
#cinstm ProcExp #cinstm sysinternals
#cinstm NugetPackageExplorer
#cinstm windbg
#cinstm Devbox-Clink
#cinstm TortoiseHg
#cinstm VisualHG # Chocolatey package is corrupt as of Feb 2014 
#cinstm linqpad4
#cinstm TestDriven.Net
#cinstm ncrunch2.vs2013

#Browsers
#cinstm googlechrome
#cinstm firefox

#Other essential tools
#cinstm 7zip
#cinstm adobereader
#cinstm javaruntime

#cinst Microsoft-Hyper-V-All -source windowsFeatures
#cinst IIS-WebServerRole -source windowsfeatures
#cinst IIS-HttpCompressionDynamic -source windowsfeatures
#cinst IIS-ManagementScriptingTools -source windowsfeatures
#cinst IIS-WindowsAuthentication -source windowsfeatures

#Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
#Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"

Update-Package git
Update-Package git-credential-winstore
Update-Package poshgit
Update-Package dotpeek
Update-Package docfx
Update-Package notepad2
Update-Package NuGet.CommandLine
Update-Package sysinternals
Update-Package scriptcs