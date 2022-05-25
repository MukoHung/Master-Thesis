Param(
  [string]$DestPath = "C:/Tests/",
  [switch]$Robo
)

if (!(Test-Path -Path "$DestPath/TestDir")) {
  New-Item -Path "$DestPath/TestDir" -Type Directory | Out-Null
}

for ($i = 0; $i -lt 10; $i++) {
  if (Test-Path -Path "$DestPath/TestDir/keawade.github.io") {
    Remove-Item -Path "$DestPath/TestDir/keawade.github.io" -Recurse -Force
  }
  if ($Robo) {
    New-Item -Path "$DestPath/TestDir/keawade.github.io" -Type Directory | Out-Null
    Measure-Command {
      C:\Windows\System32\Robocopy.exe .\keawade.github.io\ $DestPath\TestDir\keawade.github.io /E
    } | Select-Object TotalMilliseconds
  } else {
    Measure-Command {
      Copy-Item -Path "./keawade.github.io" -Destination "$DestPath/TestDir" -Recurse
    } | Select-Object TotalMilliseconds
  }
  if (Test-Path -Path "$DestPath/TestDir/keawade.github.io") {
    Remove-Item -Path "$DestPath/TestDir/keawade.github.io" -Recurse -Force
  }
}

if (Test-Path -Path "$DestPath/TestDir") {
  Remove-Item -Path "$DestPath/TestDir" -Recurse -Force
}
