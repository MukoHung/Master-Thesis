$cert = (get-childitem cert:\localmachine\my -dnsname code.mattridgway.co.uk)
set-authenticodesignature .\test.ps1 $cert