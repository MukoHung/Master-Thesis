if ($env:APPVEYOR_BUILD_WORKER_IMAGE -eq "Visual Studio 2015") {
  cmd.exe /c "call `"C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd`" /x64 && call `"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat`" x86_amd64 && set > %temp%\vcvars.txt"
} else {
  cmd.exe /c "call `"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat`" && set > %temp%\vcvars.txt"
}

Get-Content "$env:temp\vcvars.txt" | Foreach-Object {
  if ($_ -match "^(.*?)=(.*)$") {
    Set-Content "env:\$($matches[1])" $matches[2]
  }
}