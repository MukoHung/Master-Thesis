param(
      $domain
      ) #end param

# Begin Functions

Function funWhoIs()
{
 "Obtaining WhoIs $domain ..."
 $strQuery="http://reports.internic.net/cgi/whois?whois_nic=$domain&type=domain"
 $text = (new-object System.Net.WebClient).DownloadString($StrQuery)

 $startIndex = $text.IndexOf('Domain Name:')
 $endIndex = $text.IndexOf('Expiration Date:')

 if(($startIndex -ge 0) -and ($endIndex -ge 0))
    {
       $partialText = $text.Substring($startIndex, $endIndex - $startIndex)
       ""
       $partialText
    }
    else
    {
       ""
       "No answer found."
    }
 exit
} #End Functions

funWhoIs