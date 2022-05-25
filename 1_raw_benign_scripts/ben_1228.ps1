<#
found this site which has all of the soundtrack to MH4 for free
BUT, you can't click downlaod and save each one, instead each link takes you to a new page with it's own DL link embedded within the site
Solution?  

Wou write a short powershell script to find all the links we want, then load each page, find any downloadable MP3 links within that page and save them all
#>

$u = 'http://downloads.khinsider.com/game-soundtracks/album/monster-hunter-4'

$l = (Invoke-WebRequest –Uri $u).Links | ? href -like *mp3* 

$l | select -Unique href | % { 
#get file name
$name = $l | ? href -eq $_.href  | select -First 1 -ExpandProperty innerHtml 
        
        
        "going to DL $name"
        
        #get actual DL link

         $mp3 =  Invoke-WebRequest $_.href  | select -ExpandProperty Links | ? href -Like *mp3 | select -ExpandProperty href
        #$mp3 = (Invoke-WebRequest ($_.href  | select -Unique href | select -First 1 -ExpandProperty href)).Links | ? href -like *mp3* | select -ExpandProperty href
        "real file is $mp3, downloading..."
        timeout 5
        
        Invoke-WebRequest -Uri $mp3  -OutFile c:\temp\$name -Verbose 
        
        
        
     }