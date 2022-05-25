Add-Type -Path "C:\Program Files (x86)\AWS SDK for .NET\bin\AWSSDK.dll"

$region="ap-northeast-1"
$accesskey="ACCESSKEY"
$secretkey="SECRETKEY"
$vaultname="myvault"
$description="some binary file"
$file="c:\hoge\target.bin"

$endpoint = [Amazon.RegionEndpoint]::GetBySystemName($region)

$manager = New-Object -TypeName Amazon.Glacier.Transfer.ArchiveTransferManager($accesskey,$secretkey,$endpoint)
$manager.Upload($vaultname, $description, $file).ArchiveId