Split-Path -parent $dte.Solution.FileName | cd
New-Item -ItemType Directory -Force -Path ".\licenses"
@( Get-Project -All | ? { $_.ProjectName } | % { Get-Package -ProjectName $_.ProjectName } ) | Sort -Unique Id | % { $pkg = $_ ; Try { (New-Object System.Net.WebClient).DownloadFile($pkg.LicenseUrl, (Join-Path (pwd) 'licenses\') + $pkg.Id + ".html") } Catch [system.exception] { Write-Host "Could not download license for $($pkg.Id)" } }