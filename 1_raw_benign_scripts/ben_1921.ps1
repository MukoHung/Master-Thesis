# https://docs.aws.amazon.com/cli/latest/userguide/awscli-install-windows.html
$dlurl = "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi"
$installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
Invoke-WebRequest $dlurl -OutFile $installerPath
Start-Process -FilePath msiexec -Args "/i $installerPath /passive" -Verb RunAs -Wait
Remove-Item $installerPath
$env:Path += ";C:\Program Files\Amazon\AWSCLI\bin"