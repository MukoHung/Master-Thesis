<#
This is a workaround for "node-gyp is unable to find msbuild if VS2019 is installed"
  https://github.com/nodejs/node-gyp/issues/1663
It create a shim EXE as "MSBuild\15.0\Bin\MSBuild.exe" to target "MSBuild\Current\Bin\MSBuild.exe"
By noseratio - MIT license - use at your own risk!
It requires admin mode, I use wsudo/wsudox (https://chocolatey.org/packages/wsudo) for that:
  wsudo powershell -f make-msbuild-shim.ps1 
#>

#Requires -RunAsAdministrator 
#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$vsBasePath = . "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" `
  -latest `
  -requires Microsoft.Component.MSBuild `
  -property installationPath -format value

if (!$vsBasePath) { 
  throw "VS2017+ must be installed" 
}

$msbuildSimPath = [System.IO.Path]::Combine($vsBasePath, "MSBuild\15.0\Bin\MSBuild.exe")
if ([System.IO.File]::Exists($msbuildSimPath)) {
  Write-Host "Already exists: $msbuildSimPath"
  exit 0;
}

# Create the shim .EXE using C#
$code = @"
  using System;
  using System.Diagnostics;
  using System.IO;
  using System.Linq;

  static class MSBuildShim
  {
    static void Main()
    {
      var thisExe = Process.GetCurrentProcess().MainModule.FileName;
      var thisExeDir = Path.GetDirectoryName(thisExe);
      var newExe = Path.GetFullPath(Path.Combine(thisExeDir, "..\\..\\Current\\Bin", "MSBuild.exe"));
      if (!File.Exists(newExe))
        throw new FileNotFoundException(newExe);

      var process = new Process();
      process.StartInfo.FileName = newExe;
      process.StartInfo.Arguments = String.Join("\u0020", Environment.GetCommandLineArgs().Skip(1));
      process.StartInfo.UseShellExecute = false;
      if (!process.Start())
        throw new InvalidOperationException(newExe);

      process.WaitForExit();
      Environment.ExitCode = process.ExitCode;
    }
  }
"@

Add-Type -TypeDefinition $code `
  -OutputType ConsoleApplication `
  -OutputAssembly "$msbuildSimPath" `
  -ReferencedAssemblies "System.Core.dll"

Write-Host "Shim created at: $msbuildSimPath"
