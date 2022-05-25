#search latest files
$dir = "C:\Users\Admin\Documents"
$latest = Get-ChildItem -Path $dir | Sort-Object LastAccessTime -Descending | Select-Object -First 1

#we specify the directory where all files that we want to upload  
$Dir="C:/Users/Admin/Documents/"+ $latest.name
 
#ftp server 
$ftp = "ftp://ftp.someaddress.com/dir/" 
$user = "login" 
$pass = "password"  
 
$webclient = New-Object System.Net.WebClient 
 
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)  
 
#list every sql server trace file 
foreach($item in (dir $Dir "*.trc")){ 
    "Uploading $item..." 
    $uri = New-Object System.Uri($ftp+$item.Name) 
    $webclient.UploadFile($uri, $item.FullName) 
 }