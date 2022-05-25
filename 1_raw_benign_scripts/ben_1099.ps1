#prerequire config ssh public key

$dateStamp = Get-Date -UFormat "%Y-%m-%d_%H-%M-%S"

$host_destination = "~/web/WebApp/bin/Release/net5.0"
$host_name = "hostname.com"

$Host.PrivateData.ErrorBackgroundColor = "Red"
$Host.PrivateData.ErrorForegroundColor = "White"
echo '>>Deploy'


echo "(1/5) - Build"
dotnet publish --configuration Release

$dir0 = $pwd
cd $pwd\bin\Release
ls

$zip = "$pwd/publish.zip"
echo "(2/5) - Zip"
Compress-Archive -Path "$pwd/net5.0/publish" -DestinationPath "$zip" -CompressionLevel Optimal -Force
echo "(3/5) - Copy to server"
scp -C $zip hostname.com:$host_destination
echo "(4/5) - Unzip | copy"
# С аргументами -zlo не работает замена файлов
ssh $host_name "cd $host_destination;ls *.zip;unzip -oq publish.zip"
echo "(5/5) - Restart App"
ssh $host_name "pm2 restart WebApp"

cd $dir0
echo '<<Finish'
# pause