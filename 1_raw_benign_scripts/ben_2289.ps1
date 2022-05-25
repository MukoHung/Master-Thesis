#disable Chrome's pwd manager
$chromeRegKey = "HKCU:\SOFTWARE\Policies\Google\Chrome"
Set-ItemProperty -Path $chromeRegKey -Name PasswordManagerEnabled -Value 0

# set home button URL
Set-ItemProperty -Path $chromeRegKey -Name HomepageLocation -Value "http://www.trello.com"
 
#set your start URLs
$chromeUrlsKey = "$ChromeRegKey\RestoreOnStartupURLs"
$startUrls = 
 "https://tweetdeck.twitter.com",
 "https://trello.com",
 "https://github.com"
 
$urlNumber=1
foreach ($url in $startUrls) {
    Set-ItemProperty -Path $chromeUrlsKey -Name $urlNumber -Value $url
    $urlNumber++
}

#set date and time 
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortDate -value "dd-MMM-yyyy"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortTime -value "HH:mm"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sTimeFormat -value "HH:mm:ss"
