$resp =Invoke-WebRequest http://www.mit.edu/~ecprice/wordlist.10000 -UseBasicParsing
$wordList = $resp.content.split("`n")

for ($a = 0; $a -lt 35; $a++) {
    $RandomWord =  Get-Random $wordList
    $RandomQuestion = Get-Random -InputObject("What+is+","Definition+of+","Pronunciation+of+","Thesaurus+","Examples+of+","prefixes+for+","suffixes+for+")
    Start-Process microsoft-edge:http://www.bing.com/search?q=$RandomQuestion$RandomWord -WindowStyle Minimized
    start-sleep -Milliseconds 1500
}
start-sleep -Milliseconds 2000
start-process microsoft-edge:https://www.bing.com/rewards/dashboard