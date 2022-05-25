$acert =(dir Cert:\CurrentUser\My -CodeSigningCert)[0]
Set-AuthenticodeSignature .\hello.ps1 -Certificate $acert